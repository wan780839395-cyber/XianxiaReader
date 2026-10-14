#include "TextCodec.h"
#include <errno.h>
#include <iconv.h>

int xr_gb18030_to_utf8(const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced) {
    *consumed = 0;
    *produced = 0;
    /* GB18030 is stateless. The Swift caller retains only incomplete trailing bytes. */
    iconv_t codec = iconv_open("UTF-8", "GB18030");
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
