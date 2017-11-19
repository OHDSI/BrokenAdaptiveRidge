library("testthat")

#
# BAR regression
#

test_that("Find covariate by name and number", {
  counts <- c(18,17,15,20,10,20,25,13,12)
  outcome <- gl(3,1,9)
  treatment <- gl(3,3)
  tolerance <- 1E-4

  glmFit <- glm(counts ~ outcome + treatment, family = poisson()) # gold standard

  dataPtr <- Cyclops::createCyclopsData(counts ~ outcome + treatment,
                               modelType = "pr")

  test1 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                           exclude = c("(Intercept)", "outcome2", "outcome3"),
                                           forceIntercept = FALSE)
  expect_equal(test1$types, c(rep("none",3), rep("normal", 2)))
  expect_equal(test1$excludeIndices, c(1:3))

  expect_warning(test2 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c("outcome2", "outcome3"),
                                                    forceIntercept = FALSE))
  expect_equal(test2$types, c(rep("none",3), rep("normal", 2)))
  expect_equal(test2$excludeIndices, c(1:3))

  test3 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c("outcome2", "outcome3"),
                                                    forceIntercept = TRUE)
  expect_equal(test3$types, c("normal", rep("none",2), rep("normal", 2)))
  expect_equal(test3$excludeIndices, c(2:3))


  expect_warning(test4 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c(2:3),
                                                    forceIntercept = FALSE))
  expect_equal(test4$types, c(rep("none",3), rep("normal", 2)))
  expect_equal(test4$excludeIndices, c(1:3))
})

test_that("Handle intercept with convertToCyclopsData", {

  set.seed(123)
  sim <- simulateCyclopsData(nstrata = 1, nrows = 10000, ncovars = 10,
                             zeroEffectSizeProp = 0.9,
                             model = "logistic")
  cyclopsData <- convertToCyclopsData(sim$outcomes, sim$covariates, modelType = "lr",
                                      addIntercept = TRUE)

  prior1 <- createBarPrior(penalty = "bic", exclude = c("(Intercept)"))

  expect_silent(
    fit1 <- fitCyclopsModel(cyclopsData, prior = prior1)
  )

  prior2 <- createBarPrior(penalty = "bic", exclude = c(0))

  expect_silent(
    fit2 <- fitCyclopsModel(cyclopsData, prior = prior2)
  )

  expect_equal(coef(fit1), coef(fit2))

  prior3 <- createBarPrior(penalty = "bic")
  expect_warning(
    fit3 <- fitCyclopsModel(cyclopsData, prior = prior3)
  )

  expect_equal(coef(fit1), coef(fit2))

  prior4 <- createBarPrior(penalty = "bic", forceIntercept = TRUE)
  expect_silent(
    fit4 <- fitCyclopsModel(cyclopsData, prior = prior4)
  )

  expect_gt(abs(coef(fit3)[1]), abs(coef(fit4)[1]))
})

