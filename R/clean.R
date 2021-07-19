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
  text[!in_encoding_status] <- purrr::map_chr(
    text[!in_encoding_status],
    function(this_text) {
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
  )

  return(text)
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

#' Prepare Text for Tokenization
#'
#' This function combines the other functions in this package to prepare text
#' for tokenization. The text gets converted to valid UTF-8 (if possible), and
#' then various cleaning functions are applied.
#'
#' @inheritParams remove_control_characters
#' @param whitespace Logical scalar; should we squish whitespace characters
#'   (using \code{\link[stringr]{str_squish}})?
#' @param control_characters Logical scalar; should we remove control
#'   characters?
#' @param remove_replacement_characters Logical scalar; should we remove the
#'   "replacement character", \code{U-FFFD}?
#' @param diacritics Logical scalar; should we remove diacritical marks
#'   (accents, etc) from characters?
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
#' clean_text(example_text)
#' clean_text(example_text, whitespace = FALSE)
#' clean_text(example_text, control_characters = FALSE)
#' clean_text(example_text, replacement_characters = FALSE)
#' clean_text(example_text, diacritics = FALSE)
clean_text <- function(text,
                       whitespace = TRUE,
                       control_characters = TRUE,
                       replacement_characters = TRUE,
                       diacritics = TRUE) {
  text <- validate_utf8(text)
  if (whitespace) {
    text <- stringr::str_squish(text)
  }
  if (control_characters) {
    text <- remove_control_characters(text)
  }
  if (replacement_characters) {
    text <- remove_replacement_characters(text)
  }
  if (diacritics) {
    text <- remove_diacritics(text)
  }

  # Some of those processes can introduce hanging whitespace, so re-squish.
  if (whitespace) {
    text <- stringr::str_squish(text)
  }

  return(text)
}
