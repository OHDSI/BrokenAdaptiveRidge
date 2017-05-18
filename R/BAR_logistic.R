.hide <- function() {

  rm( list = ls(all = TRUE))

  library(devtools)
  library(Cyclops)


  # set up effect size and related parameters

  nrows = 70000
  ncovars = 20000
  zeroEffectSizeProp = 1 - 0.003
  eCovarsPerRow = ncovars/100
  itcpt=-1  # intercept
  effect_low <- 0.6
  effect_up <- 1


  sd <- rbinom(ncovars, 1, 1 - zeroEffectSizeProp)
  eDirection <- rbinom(ncovars,1,prob=0.5)
  eDirection[eDirection == 0] <- -1
  xbeta <- runif(ncovars,effect_low,effect_up)*eDirection*sd
  effectSizes <- data.frame(covariateId=1:ncovars,rr=exp(xbeta))


  ptm <- proc.time()
  set.seed(2359)

  nsim <- 40
  mab <- NULL
  msb <- NULL
  nonzero <- NULL
  c_nonzero <- NULL
  c_zero <- NULL
  percent_c <- rep(0,nsim)

  cutoff <- 1E-10
  tol <- 1E-5
  threshold_beta <- 1E-5

  p <- ncovars+1
  n <- nrows

  lambda_r <- 0.0001
  lambda <- log(n)/2


  sim_i <- 0
  while(sim_i < nsim)  {

    sim_i <- sim_i + 1
    cat(paste("simulation #", sim_i, "\n"))

    ## simulate date

    covarsPerRow <- rpois(nrows,eCovarsPerRow)
    covarsPerRow[covarsPerRow > ncovars] <- ncovars
    covarsPerRow <- data.frame(covarsPerRow = covarsPerRow)
    covarRows <- sum(covarsPerRow$covarsPerRow)
    covariates <- data.frame(rowId = rep(0,covarRows), covariateId = rep(0,covarRows), covariateValue = rep(1,covarRows))

    cursor <- 1
    for (i in 1:nrow(covarsPerRow)){
      n <- covarsPerRow$covarsPerRow[i]
      if (n != 0){
        covariates$rowId[cursor:(cursor+n-1)] <- i
        covariates$covariateId[cursor:(cursor+n-1)] <- sample.int(size=n,ncovars)
        cursor = cursor+n
      }
    }

    outcomes <- data.frame(rowId = 1:nrows, y=0)
    #covariates <- merge(covariates,outcomes[,c("rowId")])
    rowId_to_rr <- aggregate(rr ~ rowId, data=merge(covariates,effectSizes),prod)
    outcomes <- merge(outcomes,rowId_to_rr,all.x=TRUE)
    outcomes$rr[is.na(outcomes$rr)] <- 1
    outcomes$y <- rbinom(nrows,1,exp(itcpt)*outcomes$rr/(1+exp(itcpt)*outcomes$rr))


    #sparseness <- 1-(nrow(covariates)/(nrows*ncovars))
    #writeLines(paste("Sparseness =",sparseness*100,"%"))

    cat(paste("generated simulation dataset #", sim_i, "\n"))

    # fit BAR model

    cyclopsData <- convertToCyclopsData(outcomes, covariates, modelType = "lr", quiet = TRUE)

    cyclopsFit <- fitCyclopsModel(cyclopsData, prior = createPrior("normal",
                                                                   exclude = c(0), # Do not regularize intercept
                                                                   variance = 1/lambda_r,
                                                                   useCrossValidation = FALSE))

    pre_coef <- coef(cyclopsFit)
    continue <- TRUE
    count <- 0

    while(continue)
    {
      count <- count+1
      cat(paste("in iteration #", count, "\n"))

      for (i in 2:p) {
        if (abs(pre_coef[i]) < cutoff){
          if (pre_coef[i]>0) pre_coef[i] <- cutoff
          else  {
            pre_coef[i] <- -cutoff
          }
        }
      }

      cyclopsFit <- fitCyclopsModel(cyclopsData, prior = createPrior(c("none", rep("normal",p-1)),
                                                                     #exclude = c(0), # Do not regularize intercept
                                                                     variance = (pre_coef)^2/lambda,
                                                                     useCrossValidation = FALSE),
                                    startingCoefficients = pre_coef)

      if(max(abs(coef(cyclopsFit)-pre_coef)) < tol)  {
        continue <- FALSE
      }
      pre_coef <- coef(cyclopsFit)

      nonzero_simulate_i <- 0
      for (i in 2:p) {
        if (abs(pre_coef[i]) > threshold_beta){
          nonzero_simulate_i <- nonzero_simulate_i + 1
        }
      }
      cat(paste("number of nonzero beta", nonzero_simulate_i,"\n"))

    }

    nonzero_i <- 0
    c_nonzero_i <- 0
    c_zero_i <-0

    for (i in 2:p) {
      if (abs(pre_coef[i]) < threshold_beta){
        pre_coef[i] <- 0
      } else  {
        nonzero_i <- nonzero_i + 1
      }
    }

    for (i in 2:p) {
      if (xbeta[i-1] == 0 & pre_coef[i] == 0)  {
        c_zero_i <- c_zero_i + 1
      }

      if (xbeta[i-1] != 0 & pre_coef[i] != 0)  {
        c_nonzero_i <- c_nonzero_i + 1
      }
    }

    nonzero <- c(nonzero, nonzero_i)
    c_nonzero <- c(c_nonzero, c_nonzero_i)
    c_zero <- c(c_zero, c_zero_i)

    if (c_nonzero_i == sum(sd) & c_zero_i == p-1-sum(sd))  {
      percent_c[sim_i] <- 1
    }

    mab <- c(mab, sum(abs(pre_coef[2:p]-xbeta))/(p-1))
    msb <- c(msb, sqrt(sum((pre_coef[2:p]-xbeta)^2))/(p-1))

  }

  all_results<-cbind(mab,msb,nonzero,c_nonzero,c_zero,percent_c)
  proc.time() - ptm



  write.csv(all_results,file="C:\\Cyclops\\simulation_n70kp20k.csv")

}
