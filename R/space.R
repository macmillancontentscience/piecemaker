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

#' Add Spaces Around CJK Ideographs
#'
#' To tokenize Chinese, Japanese, and Korean (CJK) characters, it's convenient
#' to add spaces around the characters.
#'
#' @inheritParams validate_utf8
#'
#' @return A character vector the same length as the input text, with spaces
#'   added between ideographs.
#' @export
#'
#' @examples
#' to_space <- intToUtf8(13312:13320)
#' to_space
#' space_cjk(to_space)
space_cjk <- function(text) {
  return(
    .space_regex_selector(
      text,
      .make_unicode_block_regex(
        c(
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
        )
      )
    )
  )
}

#' Space Text by a Regex Selector
#'
#' @param text Character; text to space.
#' @param regex_selector A regular expression that selects the blocks of text
#'   you want to space.
#'
#' @return A character vector the same length as text, with spaces around the
#'   specified blocks.
#' @keywords internal
.space_regex_selector <- function(text, regex_selector) {
  return(
    unlist(
      stringr::str_replace_all(
        text,
        # I'm building the pattern with paste0 for easier labeling.
        pattern = paste0(
          "(", # Capture any matched character.
          regex_selector,
          ")" # Close out the group capture.
        ),
        replacement = " \\1 "
      )
    )
  )
}

#' Make Regex for Unicode Blocks
#'
#' @param unicode_block_name The name of the unicode block as it appears in
#'   \href{https://en.wikipedia.org/wiki/Unicode_block#List_of_blocks}{the
#'   Wikipedia list of Unicode blocks}.
#'
#' @return A regex wildcard box in square brackets.
#' @keywords internal
.make_unicode_block_regex <- function(unicode_block_name) {
  # Note: If you pass one bad name among many, the error will be silent.
  these_rows <- .unicode_blocks[
    .unicode_blocks$block_name %in% unicode_block_name,
  ]
  if (nrow(these_rows)) {
    return(
      paste0(
        "[",
        paste(
          paste0(
            intToUtf8(these_rows$start, multiple = TRUE),
            "-",
            intToUtf8(these_rows$end, multiple = TRUE)
          ),
          collapse = ""
        ),
        "]"
      )
    )
  }
  rlang::abort(
    message = "No unicode blocks found.",
    class = "unicode_block_name_error"
  )
}

#' Add Spaces Around Punctuation
#'
#' To keep punctuation during tokenization, it's convenient to add spacing
#' around punctuation. This function does that, with options to keep certain
#' types of punctuation together as part of the word.
#'
#' @inheritParams validate_utf8
#' @param hyphens Logical; should hyphens be treated as punctuation?
#' @param abbreviations Logical; should ' between letters be treated as
#'   punctuation?
#'
#' @return A character vector the same length as the input text, with spaces
#'   added around punctuation characters.
#' @export
#'
#' @examples
#' to_space <- "This is some 'gosh-darn' $5 text. Isn't it lovely?"
#' to_space
#' space_punctuation(to_space)
#' space_punctuation(to_space, hyphens = FALSE)
#' space_punctuation(to_space, abbreviations = FALSE)
space_punctuation <- function(text, hyphens = TRUE, abbreviations = TRUE) {
  # This feels hacky but I can't find a better way than to protect the things I
  # want to preserve.
  if (!hyphens) {
    hyphen_string <- "PIEC4EMAK2ERHYP4HENZ2XZ"
    text <- stringr::str_replace_all(
      text,
      "((?<=\\w)-(?=\\w))|((?<=\\w)-(?=\\s))|((?<=\\s)-(?=\\w))",
      hyphen_string
    )
  }

  if (!abbreviations) {
    # We *attempt* to protect abbreviations, but there will be cases where we
    # miss, or treat apostrophes that were meant to be used as single quotes as
    # if they're part of an abbreviation.
    apostrophe_string <- "PIEC4EMAK2ERAPOS4TROPHEZ2XZ"
    text <- stringr::str_replace_all(
      text,
      "(?<=\\w)'(?=\\w)",
      apostrophe_string
    )
  }

  # Some punctuation-ish characters aren't actually in the Unicode "punctuation"
  # character class, so explicitly check for those characters. Specifically,
  # these are not: $+<=>^`|~
  punctuation_regex <- "\\p{P}|[$+<=>^`|~]"
  text <- .space_regex_selector(
    text,
    punctuation_regex
  )

  # Clean up the protections.
  if (!hyphens) {
    text <- stringr::str_replace_all(
      text,
      hyphen_string,
      "-"
    )
  }
  if (!abbreviations) {
    text <- stringr::str_replace_all(
      text,
      apostrophe_string,
      "'"
    )
  }

  return(text)
}
