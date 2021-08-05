# Copyright 2021 Bedford Freeman & Worth Pub Grp LLC DBA Macmillan Learning.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Unicode block names and ranges from
# https://en.wikipedia.org/wiki/Unicode_block#List_of_blocks. Consider scraping
# that to get all of them.

# I create this as a tribble then simplify so it's easy to read when created but
# doesn't require an additional package.
.unicode_blocks <- tibble::tribble(
  ~block_name, ~start, ~end,
  "CJK Unified Ideographs",                  0x4E00,  0x9FFF,
  "CJK Unified Ideographs Extension A",      0x3400,  0x4DBF,
  "CJK Unified Ideographs Extension B",      0x20000, 0x2A6DF,
  "CJK Unified Ideographs Extension C",      0x2A700, 0x2B73F,
  "CJK Unified Ideographs Extension D",      0x2B740, 0x2B81F,
  "CJK Unified Ideographs Extension E",      0x2B820, 0x2CEAF,
  "CJK Unified Ideographs Extension F",      0x2CEB0, 0x2EBEF,
  "CJK Unified Ideographs Extension G",      0x30000, 0x3134F,
  "CJK Compatibility Ideographs",            0xF900,  0xFAFF,
  "CJK Compatibility Ideographs Supplement", 0x2F800, 0x2FA1F
)

.unicode_blocks <- as.data.frame(.unicode_blocks)

usethis::use_data(.unicode_blocks, overwrite = TRUE, internal = TRUE)
rm(.unicode_blocks)
