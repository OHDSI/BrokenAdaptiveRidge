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
  expect_equal(test1$exclude, c(1:3))

  expect_warning(test2 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c("outcome2", "outcome3"),
                                                    forceIntercept = FALSE))
  expect_equal(test2$types, c(rep("none",3), rep("normal", 2)))
  expect_equal(test2$exclude, c(1:3))

  test3 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c("outcome2", "outcome3"),
                                                    forceIntercept = TRUE)
  expect_equal(test3$types, c("normal", rep("none",2), rep("normal", 2)))
  expect_equal(test3$exclude, c(2:3))


  expect_warning(test4 <- BrokenAdaptiveRidge:::createBarPriorType(dataPtr,
                                                    exclude = c(2:3),
                                                    forceIntercept = FALSE))
  expect_equal(test4$types, c(rep("none",3), rep("normal", 2)))
  expect_equal(test4$exclude, c(1:3))
})

