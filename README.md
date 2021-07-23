
<!-- README.md is generated from README.Rmd. Please edit that file -->

# piecemaker

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Tokenizers break text into pieces that are more usable by machine
learning models. While writing
[wordpiece](https://github.com/jonathanbratt/wordpiece) and
[morphemepiece](https://github.com/jonathanbratt/morphemepiece), we
found that many steps were shared between those package. This package
provides those shared steps.

## Installation

You can install the released version of piecemaker from
[CRAN](https://CRAN.R-project.org) with:

``` r
# Not yet.
#install.packages("piecemaker")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("macmillancontentscience/piecemaker")
```

## Example

{piecemaker} helps to prepare text for tokenization. For example, it can
help you clean out strange encoding, whitespace, and special characters.

``` r
library(piecemaker)

piece1 <- " This is a    \n\nfa\xE7ile\n\n    example.\n"
# Specify encoding so this example behaves the same on all systems.
Encoding(piece1) <- "latin1"
example_text <- paste(
  piece1,
  "It has the bell character, \a, and the replacement character,",
  intToUtf8(65533)
)
prepare_text(example_text)
#> [1] "This is a facile example . It has the bell character , , and the replacement character ,"
prepare_text(example_text, squish_whitespace = FALSE)
#> [1] " This is a    facile    example .  It has the bell character ,   ,  and the replacement character ,  "
prepare_text(example_text, remove_control_characters = FALSE)
#> [1] "This is a facile example . It has the bell character , \a , and the replacement character ,"
prepare_text(example_text, remove_replacement_characters = FALSE)
#> [1] "This is a facile example . It has the bell character , , and the replacement character , <U+FFFD>"
prepare_text(example_text, remove_diacritics = FALSE)
#> [1] "This is a façile example . It has the bell character , , and the replacement character ,"
```

## Code of Conduct

Please note that the piecemaker project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Disclaimer

This is not an officially supported Macmillan Learning product.

## Contact information

Questions or comments should be directed to Jonathan Bratt
(<jonathan.bratt@macmillan.com>) and Jon Harmon
(<jonthegeek@gmail.com>).
