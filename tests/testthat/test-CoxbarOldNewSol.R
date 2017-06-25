library("testthat")
library("survival")

test_that("CoxBAR old and new code same solution", {

  skip_on_cran()
  skip_on_travis()

  source("../../extras/coxbar.R")
  source("../../extras/bar_fit.R")

  test <- read.table(header=T, sep = ",", text = "
start, length, event, x1, x2
0, 4, 1,0,0
0, 3.5,1,2,0
0, 3, 0,0,1
0, 2.5,1,0,1
0, 2, 1,1,1
0, 1.5,0,1,0
0, 1, 1,1,0
")

  fit.old <- coxbar(test$length, test$event, cbind(test$x1, test$x2), lambda = 0.1, xi = 0.1, old = TRUE)
  fit.new <- coxbar(test$length, test$event, cbind(test$x1, test$x2), lambda = 0.1, xi = 0.1, old = FALSE)

  expect_equal(fit.old$beta,  fit.new$beta)
})
