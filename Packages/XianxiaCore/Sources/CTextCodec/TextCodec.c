#include "TextCodec.h"
#if defined(__APPLE__)
#include <CoreFoundation/CoreFoundation.h>
#include <limits.h>
#include <stdbool.h>

/* Keep complete legacy sequences together. The SDK supplies mappings except
   Windows-936's documented standalone 0x80 euro extension on Apple. */
static int complete_prefix(int encoding, const uint8_t *input, size_t count, size_t *prefix) {
    size_t index = 0;
    while (index < count) {
        *prefix = index;
        uint8_t first = input[index];
        if (encoding == XR_TEXT_WINDOWS1252) {
            if (first == 0x81 || first == 0x8D || first == 0x8F || first == 0x90 || first == 0x9D) return 3;
            index++; continue;
        }
        if (first <= 0x7F) { index++; continue; }
        if (encoding == XR_TEXT_WINDOWS936 && first == 0x80) { index++; continue; }
        if (first < 0x81 || first > 0xFE) return 3;
        if (count - index < 2) return 1;
        uint8_t second = input[index + 1];
        if (encoding == XR_TEXT_BIG5) {
            if ((second >= 0x40 && second <= 0x7E) || (second >= 0xA1 && second <= 0xFE)) { index += 2; continue; }
            return 3;
        }
        if ((second >= 0x40 && second <= 0x7E) ||
            (second >= 0x80 && second <= 0xFE)) { index += 2; continue; }
        if (encoding != XR_TEXT_GB18030 || second < 0x30 || second > 0x39) return 3;
        if (count - index < 3) return 1;
        if (input[index + 2] < 0x81 || input[index + 2] > 0xFE) return 3;
        if (count - index < 4) return 1;
        if (input[index + 3] < 0x30 || input[index + 3] > 0x39) return 3;
        index += 4;
    }
    *prefix = index;
    return 0;
}

static int convert_cf(CFStringEncoding encoding, const uint8_t *input, size_t count,
                      uint8_t *output, size_t capacity, size_t *produced) {
    *produced = 0;
    if (count == 0) return 0;
    CFStringRef text = CFStringCreateWithBytes(kCFAllocatorDefault, input, (CFIndex)count, encoding, false);
    if (text == NULL) return 3;
    CFIndex length = CFStringGetLength(text), used = 0;
    /* lossByte=0 forbids replacement. Only complete output is published. */
    CFIndex converted = CFStringGetBytes(text, CFRangeMake(0, length), kCFStringEncodingUTF8,
                                        0, false, output, (CFIndex)capacity, &used);
    CFRelease(text);
    if (converted != length) return 2;
    *produced = (size_t)used;
    return 0;
}

int xr_legacy_to_utf8(int encoding, const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced) {
    *consumed = 0;
    *produced = 0;
    if (input_count > LONG_MAX || output_capacity > LONG_MAX) return 4;
    size_t prefix = 0;
    CFStringEncoding cf_encoding;
    switch (encoding) {
        case XR_TEXT_GB18030: cf_encoding = kCFStringEncodingGB_18030_2000; break;
        case XR_TEXT_WINDOWS936: cf_encoding = CFStringConvertWindowsCodepageToEncoding(936); break;
        case XR_TEXT_BIG5: cf_encoding = CFStringConvertWindowsCodepageToEncoding(950); break;
        case XR_TEXT_WINDOWS1252: cf_encoding = CFStringConvertWindowsCodepageToEncoding(1252); break;
        default: return 4;
    }
    int status = complete_prefix(encoding, input, input_count, &prefix);
    if (status == 3) { *consumed = prefix; return status; }
    if (prefix == 0) return status;
    if (!CFStringIsEncodingAvailable(cf_encoding)) return 4;
    size_t total = 0, span = 0;
    if (encoding == XR_TEXT_WINDOWS936) {
        /* Microsoft CP936.TXT: standalone 0x80 -> U+20AC. Walk complete
           character boundaries so a legal 0x80 trail (e.g. 0x8180) stays intact. */
        size_t cursor = 0;
        while (cursor < prefix) {
            if (input[cursor] == 0x80) {
                size_t used = 0;
                int failure = convert_cf(cf_encoding, input+span, cursor-span, output+total, output_capacity-total, &used);
                if (failure != 0) { *consumed = span; return failure; }
                total += used;
                if (output_capacity-total < 3) return 2;
                output[total++] = 0xE2; output[total++] = 0x82; output[total++] = 0xAC;
                cursor++; span = cursor;
            } else { cursor += input[cursor] <= 0x7F ? 1 : 2; }
        }
    }
    size_t used = 0;
    int failure = convert_cf(cf_encoding, input+span, prefix-span, output+total, output_capacity-total, &used);
    if (failure != 0) { *consumed = span; return failure; }
    total += used;
    *consumed = prefix;
    *produced = total;
    return status;
}
#else
#include <errno.h>
#include <iconv.h>

int xr_legacy_to_utf8(int encoding, const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced) {
    *consumed = 0;
    *produced = 0;
    /* These code pages are stateless. Swift retains only incomplete trailing bytes. */
    const char *name;
    switch (encoding) {
        case XR_TEXT_GB18030: name = "GB18030"; break;
        case XR_TEXT_WINDOWS936: name = "CP936"; break;
        case XR_TEXT_BIG5: name = "CP950"; break;
        case XR_TEXT_WINDOWS1252: name = "WINDOWS-1252"; break;
        default: return 4;
    }
    iconv_t codec = iconv_open("UTF-8", name);
    if (codec == (iconv_t)-1) return 4;
    char *in = (char *)input;
    char *out = (char *)output;
    size_t input_left = input_count;
    size_t output_left = output_capacity;
    errno = 0;
    size_t result = iconv(codec, &in, &input_left, &out, &output_left);
    int saved_errno = errno;
    *consumed = input_count - input_left;
    *produced = output_capacity - output_left;
    int status = 0;
    if (result == (size_t)-1) {
        if (saved_errno == EINVAL) status = 1;
        else if (saved_errno == E2BIG) status = 2;
        else if (saved_errno == EILSEQ) status = 3;
        else status = 4;
    } else if (result != 0) status = 5;
    if (iconv_close(codec) != 0 && status == 0) status = 4;
    return status;
}
#endif

int xr_gb18030_to_utf8(const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced) {
    return xr_legacy_to_utf8(XR_TEXT_GB18030, input, input_count, output, output_capacity, consumed, produced);
}
