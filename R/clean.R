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

#' Clean Up Text to UTF-8
#'
#' Text cleaning works best if the encoding is known. This function attempts to
#' convert text to UTF-8 encoding, and provides an informative error if that is
#' not possible.
#'
#' @param text A character vector to attempt to convert.
#'
#' @return The text with formal UTF-8 encoding, if possible.
#' @export
#'
#' @examples
#' validate_utf8("fa\xE7ile")
validate_utf8 <- function(text) {
  if (all(validUTF8(text))) {
    Encoding(text) <- "UTF-8"
    return(text)
  } else {
    converted <- iconv(text, "latin1", "UTF-8")
    if (all(converted == text)) {
      return(converted)
    } else {
      rlang::abort(
        message = "Unsupported string type.",
        class = "encoding_error"
      )
    }
  }
}
