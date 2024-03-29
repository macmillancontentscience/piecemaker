% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenize.R
\name{prepare_and_tokenize}
\alias{prepare_and_tokenize}
\title{Split Text on Spaces}
\usage{
prepare_and_tokenize(text, prepare = TRUE, ...)
}
\arguments{
\item{text}{A character vector to clean.}

\item{prepare}{Logical; should the text be passed through
\code{\link{prepare_text}}?}

\item{...}{
  Arguments passed on to \code{\link[=prepare_text]{prepare_text}}
  \describe{
    \item{\code{squish_whitespace}}{Logical scalar; squish whitespace characters (using
\code{\link[stringr]{str_squish}})?}
    \item{\code{remove_control_characters}}{Logical scalar; remove control characters?}
    \item{\code{remove_replacement_characters}}{Logical scalar; remove the "replacement
character", \code{U-FFFD}?}
    \item{\code{remove_diacritics}}{Logical scalar; remove diacritical marks (accents,
etc) from characters?}
    \item{\code{space_cjk}}{Logical scalar; add spaces around Chinese/Japanese/Korean
ideographs?}
    \item{\code{space_punctuation}}{Logical scalar; add spaces around punctuation (to
make it easier to keep punctuation during tokenization)?}
    \item{\code{remove_terminal_hyphens}}{Logical; should hyphens at the end of lines
after a word be removed? For example, "un-\\nbroken" would become
"unbroken".}
    \item{\code{space_hyphens}}{Logical; treat hyphens between letters and at the
start/end of words as punctuation? Other hyphens are always treated as
punctuation.}
    \item{\code{space_abbreviations}}{Logical; treat apostrophes between letters as
punctuation? Other apostrophes are always treated as punctuation.}
  }}
}
\value{
The text as a list of character vectors. Each element of each vector
is roughly equivalent to a word.
}
\description{
This is an extremely simple tokenizer that simply splits text on spaces. It
also optionally applies the cleaning processes from
\code{\link{prepare_text}}.
}
\examples{
prepare_and_tokenize("This is some text.")
prepare_and_tokenize("This is some text.", space_punctuation = FALSE)
}
