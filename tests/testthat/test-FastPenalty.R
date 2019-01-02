library("testthat")

test_that("Numeric penalty", {
  prior <- createFastBarPrior(penalty = 10)
  expect_equal(BrokenAdaptiveRidge:::getPenalty(NULL, prior), 10)
})

test_that("Unhandled penalty", {
  prior <- createFastBarPrior(penalty = "ucla")
  expect_error(BrokenAdaptiveRidge:::getPenalty(NULL, prior))
})

