test_that("Simple tokenization works.", {
  to_tokenize <- c("This is some text.", "So is this!")

  expect_identical(
    tokenize_space(to_tokenize),
    list(
      c("This", "is", "some", "text."),
      c("So", "is", "this!")
    )
  )

  expect_identical(
    prepare_and_tokenize(to_tokenize),
    list(
      c("This", "is", "some", "text", "."),
      c("So", "is", "this", "!")
    )
  )

  expect_identical(
    prepare_and_tokenize(to_tokenize, space_punctuation = FALSE),
    list(
      c("This", "is", "some", "text."),
      c("So", "is", "this!")
    )
  )
})
