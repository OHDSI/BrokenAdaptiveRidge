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
 
pbc.cc        <- pbc[complete.cases(pbc), ] #Extract only complete cases
pbc.cc$sex    <- ifelse(pbc.cc$sex == "f", 1, 0) #Change sex to a numeric
pbc.cc$trt    <- ifelse(pbc.cc$trt == 2, 1, 0) #Change trt from (1, 2) to (0, 1)
pbc.cc$status <- ifelse(status == 2, 1, 0) #Change censoring definition to transplant/dead (1) vs. censored (0)
time          <- pbc.cc$time 
status        <- pbc.cc$status
X             <- pbc.cc[, 4:20]
X             <- scale(as.matrix(X)) #Standardize the covariate matrix, X.

#Run CoxBAR w/ lambda = log(n) and xi = 1
dataFit  <- createCyclopsData(Surv(time, status) ~ X, modelType = "cox")
barPrior <- createBarPrior(penalty = log(dim(X)[1]) / 2, initialRidgeVariance = 0.5) 
fit      <- fitCyclopsModel(dataFit, prior = barPrior)
coef(fit) #Extract coefficients
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
  barPrior    <- createBarPrior(penalty = lambda/2, initialRidgeVariance = 2/xi) 
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


