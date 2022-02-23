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
#' @param text A character vector to clean.
#'
#' @return The text with formal UTF-8 encoding, if possible.
#' @export
#'
#' @examples
#' text <- "fa\xE7ile"
#' # Specify the encoding so the example is the same on all systems.
#' Encoding(text) <- "latin1"
#' validate_utf8(text)
validate_utf8 <- function(text) {
  if (!is.character(text)) {
    rlang::abort(
      message = "text must be a character vector.",
      class = "non_text_error"
    )
  }

  # Figure out which ones are fine as-is:
  in_encoding_status <- validUTF8(text)

  # Make sure those ones are explicitly set.
  Encoding(text[in_encoding_status]) <- "UTF-8"

  # Now try to coerce the leftovers to UTF-8.
  text[!in_encoding_status] <- vapply(
    X = text[!in_encoding_status],
    FUN = .coerce_to_utf8,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )

  return(text)
}

#' Coerce to UTF8
#'
#' @param this_text Character scalar; a piece of text to attemp to coerce.
#'
#' @return The text as UTF8.
#' @keywords internal
.coerce_to_utf8 <- function(this_text) {
  converted <- enc2utf8(this_text)
  if (converted != this_text) {
    # I can't find a way to trigger this but let's keep it in case.
    error_message <- paste( # nocov start
      "Unsupported string type in",
      this_text
    )
    rlang::abort(
      message = error_message,
      class = "encoding_error"
    ) # nocov end
  }

  # Now check whether we've created a monster.
  if (!validEnc(converted)) {
    error_message <- paste(
      "Unsupported string type in",
      this_text
    )
    rlang::abort(
      message = error_message,
      class = "encoding_error"
    )
  }
  return(converted)
}

#' Remove Non-Character Characters
#'
#' Unicode includes several control codes, such as \code{U+0000} (NULL, used in
#' null-terminated strings) and \code{U+000D} (carriage return). This function
#' removes all such characters from text.
#'
#' Note: We highly recommend that you first condense all space-like characters
#' (including new lines) before removing control codes. You can easily do so
#' with \code{\link[stringr]{str_squish}}. We also recommend validating text at
#' the start of any cleaning process using \code{\link{validate_utf8}}.
#'
#' @inheritParams validate_utf8
#'
#' @return The character vector without control characters.
#' @export
#'
#' @examples
#' remove_control_characters("Line 1\nLine2")
remove_control_characters <- function(text) {
  return(
    stringi::stri_replace_all_charclass(
      text,
      "\\p{C}", # This means "control character."
      "" # Remove it.
    )
  )
}

#' Remove the Unicode Replacement Character
#'
#' The replacement character, \code{U+FFFD}, is used to mark characters that
#' could not be loaded. These characters might be a sign of encoding issues, so
#' it is advisable to investigate and try to eliminate any cases in your text,
#' but in the end these characters will almost definitely confuse downstream
#' processes.
#'
#' @inheritParams validate_utf8
#'
#' @return The character vector with replacement characters removed.
#' @export
#'
#' @examples
#' remove_replacement_characters(
#'   paste(
#'     "The replacement character:",
#'     intToUtf8(65533)
#'   )
#' )
remove_replacement_characters <- function(text) {
  return(
    stringi::stri_replace_all_regex(
      text,
      intToUtf8(0xfffd),
      ""
    )
  )
}

#' Remove Diacritical Marks on Characters
#'
#' Accent characters and other diacritical marks are often difficult to type,
#' and thus can be missing from text. To normalize the various ways a user might
#' spell a word that should have a diacritical mark, you can convert all such
#' characters to their simpler equivalent character.
#'
#' @inheritParams validate_utf8
#'
#' @return The character vector with simpler character representations.
#' @export
#'
#' @examples
#' # This text can appear differently between machines if we aren't careful, so
#' # we explicitly encode the desired characters.
#' sample_text <- "fa\u00e7ile r\u00e9sum\u00e9"
#' sample_text
#' remove_diacritics(sample_text)
remove_diacritics <- function(text) {
  return(
    stringi::stri_replace_all_regex(
      stringi::stri_trans_nfd(text),
      "\\p{Mn}",
      ""
    )
  )
}

#' Remove Extra Whitespace
#'
#' This function is mostly a wrapper around \code{\link[stringr]{str_squish}},
#' with the additional option to remove hyphens at the ends of lines.
#'
#' @inheritParams validate_utf8
#' @param remove_terminal_hyphens Logical; should hyphens at the end of lines
#'   after a word be removed? For example, "un-\\nbroken" would become
#'   "unbroken".
#'
#' @return The character vector with spacing at the start and end removed, and
#'   with internal spacing reduced to a single space character each.
#' @export
#'
#' @examples
#' sample_text <- "This  had many space char-\\nacters."
#' squish_whitespace(sample_text)
squish_whitespace <- function(text, remove_terminal_hyphens = TRUE) {
  if (remove_terminal_hyphens) {
    text <- stringr::str_remove_all(text, "(?<=\\w)-\n")
  }

  return(stringr::str_squish(text))
}

#' Prepare Text for Tokenization
#'
#' This function combines the other functions in this package to prepare text
#' for tokenization. The text gets converted to valid UTF-8 (if possible), and
#' then various cleaning functions are applied.
#'
#' @inheritParams remove_control_characters
#' @inheritParams squish_whitespace
#' @inheritParams space_punctuation
#' @param squish_whitespace Logical scalar; squish whitespace characters (using
#'   \code{\link[stringr]{str_squish}})?
#' @param remove_control_characters Logical scalar; remove control characters?
#' @param remove_replacement_characters Logical scalar; remove the "replacement
#'   character", \code{U-FFFD}?
#' @param remove_diacritics Logical scalar; remove diacritical marks (accents,
#'   etc) from characters?
#' @param space_cjk Logical scalar; add spaces around Chinese/Japanese/Korean
#'   ideographs?
#' @param space_punctuation Logical scalar; add spaces around punctuation (to
#'   make it easier to keep punctuation during tokenization)?
#'
#' @return The character vector, cleaned as specified.
#' @export
#'
#' @examples
#' piece1 <- " This is a    \n\nfa\xE7ile\n\n    example.\n"
#' # Specify encoding so this example behaves the same on all systems.
#' Encoding(piece1) <- "latin1"
#' example_text <- paste(
#'   piece1,
#'   "It has the bell character, \a, and the replacement character,",
#'   intToUtf8(65533)
#' )
#' prepare_text(example_text)
#' prepare_text(example_text, squish_whitespace = FALSE)
#' prepare_text(example_text, remove_control_characters = FALSE)
#' prepare_text(example_text, remove_replacement_characters = FALSE)
#' prepare_text(example_text, remove_diacritics = FALSE)
prepare_text <- function(text,
                         squish_whitespace = TRUE,
                         remove_terminal_hyphens = TRUE,
                         remove_control_characters = TRUE,
                         remove_replacement_characters = TRUE,
                         remove_diacritics = TRUE,
                         space_cjk = TRUE,
                         space_punctuation = TRUE,
                         space_hyphens = TRUE,
                         space_abbreviations = TRUE) {
  text <- validate_utf8(text)
  if (squish_whitespace) {
    text <- squish_whitespace(text, remove_terminal_hyphens)
  }
  if (remove_control_characters) {
    text <- remove_control_characters(text)
  }
  if (remove_replacement_characters) {
    text <- remove_replacement_characters(text)
  }
  if (remove_diacritics) {
    text <- remove_diacritics(text)
  }
  if (space_cjk) {
    text <- space_cjk(text)
  }
  if (space_punctuation) {
    text <- space_punctuation(
      text,
      space_hyphens = space_hyphens,
      space_abbreviations = space_abbreviations
    )
  }

  # Some of those processes can introduce hanging whitespace, so re-squish.
  if (squish_whitespace) {
    text <- stringr::str_squish(text)
  }

  return(text)
}
