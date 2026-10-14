#ifndef XIANXIA_TEXT_CODEC_H
#define XIANXIA_TEXT_CODEC_H
#include <stddef.h>
#include <stdint.h>

/* 0 complete; 1 incomplete input; 2 output full; 3 invalid input;
   4 codec/system unavailable; 5 non-reversible conversion. Never IGNORE/TRANSLIT. */
#define XR_TEXT_GB18030 0
#define XR_TEXT_WINDOWS936 1
#define XR_TEXT_BIG5 2
#define XR_TEXT_WINDOWS1252 3
int xr_legacy_to_utf8(int encoding, const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced);
int xr_gb18030_to_utf8(const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced);
#endif
