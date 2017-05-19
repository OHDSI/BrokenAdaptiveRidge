library("testthat")

#
# BAR regression
#

test_that("Numeric penalty", {
  prior <- createBarPrior(penalty = 10)
  expect_equal(BrokenAdaptiveRidge:::getPenalty(NULL, prior), 10)
})

test_that("Unhandled penalty", {
  prior <- createBarPrior(penalty = "aic")
  expect_error(BrokenAdaptiveRidge:::getPenalty(NULL, prior))
})
