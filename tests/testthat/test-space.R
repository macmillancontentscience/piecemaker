test_that("space_cjk works.", {
  text <- intToUtf8(
    c(
      13312, 19903,
      19968, 40959,
      63744, 64255,
      131072, 173791,
      173824, 177983,
      177984, 178207,
      178208, 183983,
      194560, 195103
    )
  )
  Encoding(text) <- "UTF-8"
  text <- validate_utf8(text)
  test_result <- space_cjk(text)
  # I intentionally included some characters that are in the proper range but
  # likely won't render. I have to be careful how the result is saved so
  # encoding doesn't catch us again.
  expected_result <- paste0(
    " ",
    paste(
      intToUtf8(
        c(
          13312, 19903,
          19968, 40959,
          63744, 64255,
          131072, 173791,
          173824, 177983,
          177984, 178207,
          178208, 183983,
          194560, 195103
        ),
        multiple = TRUE
      ),
      collapse = "  "
    ),
    " "
  )
  # The individual spacer functions create noisy spacing, the things str_squish
  # fixes. That will be fixed in a master wrapper.
  expect_identical(
    test_result,
    expected_result
  )
})

test_that("Regex helper works.", {
  expect_error(
    .make_unicode_block_regex("fake"),
    regexp = "No unicode blocks found",
    class = "unicode_block_name_error"
  )
})

test_that("Can space punctuation.", {
  input_text <- "Have some 'gosh-darn' $5 text. Isn't it lovely?"
  expected_text1 <- "Have some ' gosh - darn ' $ 5 text . Isn ' t it lovely ?"
  expected_text2 <- "Have some ' gosh-darn ' $ 5 text . Isn ' t it lovely ?"
  expected_text3 <- "Have some ' gosh-darn ' $ 5 text . Isn't it lovely ?"

  test_result <- stringr::str_squish(
    space_punctuation(input_text)
  )
  expect_identical(test_result, expected_text1)

  test_result <- stringr::str_squish(
    space_punctuation(input_text, hyphens = FALSE)
  )
  expect_identical(test_result, expected_text2)

  test_result <- stringr::str_squish(
    space_punctuation(
      input_text, hyphens = FALSE, abbreviations = FALSE
    )
  )
  expect_identical(test_result, expected_text3)
})
