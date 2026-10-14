#ifndef XIANXIA_TEXT_CODEC_H
#define XIANXIA_TEXT_CODEC_H
#include <stddef.h>
#include <stdint.h>

/* 0 complete; 1 incomplete input; 2 output full; 3 invalid input;
   4 codec/system unavailable; 5 non-reversible conversion. Never IGNORE/TRANSLIT. */
int xr_gb18030_to_utf8(const uint8_t *input, size_t input_count,
                     uint8_t *output, size_t output_capacity,
                     size_t *consumed, size_t *produced);
#endif
