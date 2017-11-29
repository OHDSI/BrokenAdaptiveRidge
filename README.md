BrokenAdaptiveRidge
=======

<!--
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/Cyclops)](https://CRAN.R-project.org/package=Cyclops)
-->

Introduction
============

BrokenAdaptiveRidge is an `R` package for performing L_0-based regressions using `Cyclops`

Features
========

Examples
========
 * Cox's Proportional Hazards Model
 ```r
library(Cyclops)
library(BrokenAdaptiveRidge)
library(survival)

## data dimension
p <- 20    # number of covariates
n <- 300   # sample size

## tuning parameters
lambda <- log(n)  # BAR penalty (BIC)
xi     <- 0.1     # initial ridge penalty

## Cox model parameters 
true.beta <- c(1, 0, 0, -1, 1, rep(0, p - 5))

## simulate data from an exponential model
x        <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)
ti       <- rweibull(n, shape = 1, scale = exp(-x%*%true.beta))
ui       <- runif(n, 0, 10) # Controls censoring
ci       <- rweibull(n, shape = 1, scale = ui * exp(-x%*%true.beta))
survtime <- pmin(ti, ci)
delta    <- ti == survtime; mean(delta) 
 
cyclopsData <- createCyclopsData(Surv(survtime, delta) ~ x, modelType = "cox")
barPrior    <- createBarPrior(penalty = lambda / 2, initialRidgeVariance = 2 / xi) 

cyclopsFit <- fitCyclopsModel(cyclopsData,
                              prior = barPrior)
coef(cyclopsFit) 
 ```

* Generalized Linear Model
 ```r
library(Cyclops)
library(BrokenAdaptiveRidge)

## data dimension
p <- 20    # number of covariates
n <- 300   # sample size

## tuning parameters
lambda <- log(n)  # BAR penalty (BIC)
xi     <- 0.1     # initial ridge penalty

## logistic model parameters 
itcpt     <- 0.2 # intercept
true.beta <- c(1, 0, 0, -1, 1, rep(0, p - 5))

## simulate data from logistic model
x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)
y <- rbinom(n, 1, 1 / (1 + exp(-itcpt - x%*%true.beta)))


# fit BAR model
cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
barPrior    <- createBarPrior(penalty = lambda / 2, exclude = c("(Intercept)"), 
                              initialRidgeVariance = 2 / xi) 

cyclopsFit <- fitCyclopsModel(cyclopsData,
                              prior = barPrior)
coef(cyclopsFit) 
 ```
Technology
============

System Requirements
===================
Requires `R` (version 3.2.0 or higher). Installation on Windows requires [RTools]( https://CRAN.R-project.org/bin/windows/Rtools/) (`devtools >= 1.12` required for RTools34, otherwise RTools33 works fine).

Dependencies
============
 * `Cyclops`

Getting Started
===============
1. On Windows, make sure [RTools](https://CRAN.R-project.org/bin/windows/Rtools/) is installed.
2. In R, use the following commands to download and install BrokenAdaptiveRidge:

  ```r
  install.packages("devtools")
  library(devtools)
  install_github("ohdsi/Cyclops") 
  install_github("ohdsi/BrokenAdaptiveRidge") 
  ```

3. To perform a L_0-based Cyclops model fit, use the following commands in R:

  ```r
  library(BrokenAdaptiveRidge)
  cyclopsData <- createCyclopsData(formula, modelType = "modelType") ## TODO: Update
  barPrior    <- createBarPrior(penalty = lambda / 2, initialRidgeVariance = 2 / xi) 
  cyclopsFit  <- fitCyclopsModel(cyclopsData, prior = barPrior)
  coef(cyclopsFit) #Extract coefficients
  ```
 
Getting Involved
================
* Package manual: [BrokenAdaptiveRidge manual](https://raw.githubusercontent.com/OHDSI/BrokenAdaptiveRidge/master/extras/BrokenAdaptiveRidge.pdf) 
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements
 
License
=======
BrokenAdaptiveRidge is licensed under Apache License 2.0.  

Development
===========
BrokenAdaptiveRidge is being developed in R Studio.

### Development status

[![Build Status](https://travis-ci.org/OHDSI/BrokenAdaptiveRidge.svg?branch=master)](https://travis-ci.org/OHDSI/BrokenAdaptiveRidge)
[![codecov.io](https://codecov.io/github/OHDSI/BrokenAdaptiveRidge/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/BrokenAdaptiveRidge?branch=master)

Beta

Acknowledgements
================
- This project is supported in part through the National Science Foundation grants IIS 1251151 and DMS 1264153.


