library("testthat")
library("survival")

test_that("fastBAR prior is the same as old BAR implementation", {

  skip_on_cran()
  skip_on_travis()


  p <- 100    # number of covariates
  n <- 300   # sample size


  ## Cox model parameters
  true.beta <- c(1, 0, 0, -1, 1, rep(0, p - 5))

  set.seed(12345)
  ## simulate data from an exponential model
  x        <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)
  ti       <- rweibull(n, shape = 1, scale = exp(-x%*%true.beta))
  ui       <- runif(n, 0, 10) # Controls censoring
  ci       <- rweibull(n, shape = 1, scale = ui * exp(-x%*%true.beta))
  survtime <- pmin(ti, ci)
  delta    <- ti == survtime; mean(delta)

  cyclopsData <- createCyclopsData(Surv(survtime, delta) ~ x, modelType = "cox")
  barPrior    <- createBarPrior(penalty = log(p), initialRidgeVariance =  1 / log(p))
  cyclopsFit <- fitCyclopsModel(cyclopsData,
                                prior = barPrior, fixedCoefficients = NULL)

  cyclopsData <- createCyclopsData(Surv(survtime, delta) ~ x, modelType = "cox")
  fastBarPrior <- createFastBarPrior(penalty = log(p), initialRidgeVariance = 1 / log(p))
  cyclopsFit2 <- fitCyclopsModel(cyclopsData,
                                 prior = fastBarPrior)


  expect_equal(coef(cyclopsFit), coef(cyclopsFit2))
})
