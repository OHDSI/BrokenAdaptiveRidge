for (priorName in c("createBarPrior", "createFastBarPrior")) {
  test_that(paste(priorName, "can restore a zero coefficient after a reset"), {
    x <- rep(c(-1, 1), each = 5)
    y <- c(0, 0, 0, 0, 1, 0, 1, 1, 1, 1)
    data <- createCyclopsData(y ~ x - 1, modelType = "lr")
    control <- createControl(noiseLevel = "silent")
    makePrior <- get(priorName)

    strong <- fitCyclopsModel(data, prior = makePrior(penalty = 100, fitBestSubset = TRUE),
                              control = control)
    weak <- fitCyclopsModel(data, prior = makePrior(penalty = 0.01, fitBestSubset = TRUE),
                            control = control, forceNewObject = TRUE)

    expect_equal(unname(coef(strong)), 0)
    expect_gt(unname(coef(weak)), 0)
  })
}
