# Code to prepare internal data.

# Unicode block names and ranges from
# https://en.wikipedia.org/wiki/Unicode_block#List_of_blocks. Consider scraping
# that to get all of them.
.unicode_blocks <- data.frame(
  block_name = c(
    "CJK Unified Ideographs",
    "CJK Unified Ideographs Extension A",
    "CJK Unified Ideographs Extension B",
    "CJK Unified Ideographs Extension C",
    "CJK Unified Ideographs Extension D",
    "CJK Unified Ideographs Extension E",
    "CJK Unified Ideographs Extension F",
    "CJK Unified Ideographs Extension G",
    "CJK Compatibility Ideographs",
    "CJK Compatibility Ideographs Supplement"
  ),
  start = c(
    0x4E00,
    0x3400,
    0x20000,
    0x2A700,
    0x2B740,
    0x2B820,
    0x2CEB0,
    0x30000,
    0xF900,
    0x2F800
  ),
  end = c(
    0x9FFF,
    0x4DBF,
    0x2A6DF,
    0x2B73F,
    0x2B81F,
    0x2CEAF,
    0x2EBEF,
    0x3134F,
    0xFAFF,
    0x2FA1F
  ),
  stringsAsFactors = FALSE
)

usethis::use_data(.unicode_blocks, overwrite = TRUE, internal = TRUE)
rm(.unicode_blocks)
