library("testthat")

#
# BAR regression
#

test_that("BAR simulated logistic regression - no intercept", {
    set.seed(666)
    p <- 20
    n <- 1000

    beta1 <- c(0.5, 0, 0, -1, 1.2)
    beta2 <- seq(0, 0, length = p - length(beta1))
    beta <- c(beta1,beta2)

    x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)

    exb <- exp(x %*% beta)
    prob <- exb / (1 + exb)
    y <- rbinom(n, 1, prob)

    cyclopsData <- createCyclopsData(y ~ x - 1,modelType = "lr")

    bar <- fitCyclopsModel(cyclopsData, prior = createBarPrior("bic", fitBestSubset = TRUE),
                               control = createControl(noiseLevel = "silent"))

    expect_equivalent(which(coef(bar) != 0.0), which(beta != 0.0))

    # Determine MLE
    non_zero <- which(beta != 0.0)
    glm <- glm(y ~ x[,non_zero] - 1, family = binomial())
    expect_equal(as.vector(coef(bar)[which(coef(bar) != 0.0)]), as.vector(coef(glm)), tolerance = 1E-6)
})

test_that("BAR simulated logistic regression - with intercept", {
  set.seed(666)
  p <- 20
  n <- 1000

  beta1 <- c(0.5, 0, 0, -1, 1.2)
  beta2 <- seq(0, 0, length = p - length(beta1))
  beta <- c(beta1,beta2)

  x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)

  exb <- exp(x %*% beta)
  prob <- exb / (1 + exb)
  y <- rbinom(n, 1, prob)

  cyclopsData <- createCyclopsData(y ~ x,modelType = "lr")

  expect_warning(
    bar <- fitCyclopsModel(cyclopsData, prior = createBarPrior("bic", fitBestSubset = TRUE),
                           control = createControl(noiseLevel = "silent"))
  )

  expect_equivalent(which(coef(bar) != 0.0), c(1, 1 + which(beta != 0.0)))

  # Determine MLE
  non_zero <- which(beta != 0.0)
  glm <- glm(y ~ x[,non_zero], family = binomial())
  expect_equal(as.vector(coef(bar)[which(coef(bar) != 0.0)]), as.vector(coef(glm)), tolerance = 1E-6)
})

test_that("BAR simulated logistic regression - no convergence", {
  set.seed(666)
  p <- 20
  n <- 1000

  beta1 <- c(0.5, 0, 0, -1, 1.2)
  beta2 <- seq(0, 0, length = p - length(beta1))
  beta <- c(beta1,beta2)

  x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)

  exb <- exp(x %*% beta)
  prob <- exb / (1 + exb)
  y <- rbinom(n, 1, prob)

  cyclopsData <- createCyclopsData(y ~ x,modelType = "lr")

  expect_error(
    bar <- fitCyclopsModel(cyclopsData, prior = createBarPrior("bic", exclude = "(Intercept)", fitBestSubset = TRUE,
                                                               maxIterations = 1),
                           control = createControl(noiseLevel = "silent")),
    "Algorithm did not converge"
  )
})
