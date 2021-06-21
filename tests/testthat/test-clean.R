test_that("Can validate UTF8", {
  non_utf8_text <- c("fa\xE7ile", "no fancy characters")
  utf8_text <- c("façile", "no fancy characters")

  expect_identical(
    validate_utf8(utf8_text),
    utf8_text
  )
  expect_identical(
    validate_utf8(non_utf8_text),
    utf8_text
  )

  # From ?validUTF8
  bad_character <- "\xfa\xb4\xbf\xbf\x9f"

  expect_error(
    validate_utf8(bad_character),
    regexp = "Unsupported string type",
    class = "encoding_error"
  )

  # Ideally the error message should be updated to help us find where this
  # fails.
  mixed <- c(utf8_text, bad_character)
  expect_error(
    validate_utf8(mixed),
    regexp = "Unsupported string type",
    class = "encoding_error"
  )

  # We could also try coercing things more surgically. I don't care about that
  # yet. Er, it seemed like it worked, but it fails when I run the test suite
  # automatically, so I'm keeping this here to sort out.

  # expect_identical(
  #   validate_utf8(c(utf8_text, non_utf8_text)),
  #   c(utf8_text, utf8_text)
  # )
})

test_that("validate_utf8 fails gracefully for non-text.", {
  expect_error(
    validate_utf8(1L),
    regexp = "text must be a character vector",
    class = "non_text_error"
  )
  expect_error(
    validate_utf8(TRUE),
    regexp = "text must be a character vector",
    class = "non_text_error"
  )
  expect_error(
    validate_utf8(2.1),
    regexp = "text must be a character vector",
    class = "non_text_error"
  )

  # We MIGHT want to add an explicit NULL method that allows NULL through.
  # stringi is ok with NULLs, and treats them as character(0).
  expect_error(
    validate_utf8(NULL),
    regexp = "text must be a character vector",
    class = "non_text_error"
  )
})

test_that("clean_text cleans text.", {
  example_text <- paste(
    " text    \n\nfa\xE7ile\n\n    text.\n",
    "text, \a, text,",
    intToUtf8(65533)
  )

  expect_identical(
    clean_text(example_text),
    "text facile text. text, , text,"
  )

  expect_identical(
    clean_text(example_text, whitespace = FALSE),
    " text    facile    text. text, , text, "
  )

  expect_identical(
    clean_text(example_text, control_characters = FALSE),
    "text facile text. text, \a, text,"
  )

  expect_identical(
    clean_text(example_text, replacement_characters = FALSE),
    "text facile text. text, , text, \uFFFD"
  )

  expect_identical(
    clean_text(example_text, diacritics = FALSE),
    "text façile text. text, , text,"
  )
})
