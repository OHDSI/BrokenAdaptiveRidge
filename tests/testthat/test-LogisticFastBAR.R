library("testthat")
test_that("fastBAR prior is the same as old BAR implementation for logistic model", {

  skip_on_cran()
  skip_on_travis()


  p <- 100    # number of covariates
  n <- 300   # sample size


  ## Cox model parameters
  true.beta <- c(1, 0, 0, -1, 1, rep(0, p - 5))

  set.seed(12345)
  ## simulate data for logistic model
  itcpt <- 0.5
  x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)
  y <- rbinom(n, 1, 1 / (1 + exp(-itcpt - x %*% true.beta)))

  cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
  barPrior    <- createBarPrior(penalty = log(p), initialRidgeVariance =  1 / log(p),
                                exclude = c("(Intercept)"))
  cyclopsFit <- fitCyclopsModel(cyclopsData,
                                prior = barPrior)

  cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
  fastBarPrior <- createFastBarPrior(penalty = log(p), initialRidgeVariance = 1 / log(p),
                                     exclude = c("(Intercept)"))
  cyclopsFit2 <- fitCyclopsModel(cyclopsData,
                                 prior = fastBarPrior)

  expect_equal(coef(cyclopsFit), coef(cyclopsFit2))
  expect_equal(class(cyclopsFit2)[1], "cyclopsFit")
  expect_equal(class(cyclopsFit2)[2], "cyclopsFastBarFit")

  #Omitting the exclude intercept command.
  cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
  fastBarPrior <- createFastBarPrior(penalty = log(p), initialRidgeVariance = 1 / log(p))
  expect_warning(cyclopsFit3 <- fitCyclopsModel(cyclopsData,
                                 prior = fastBarPrior))

  expect_equal(coef(cyclopsFit2), coef(cyclopsFit3))
})
