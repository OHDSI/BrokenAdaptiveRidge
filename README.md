BrokenAdaptiveRidge
===================

[![Build Status](https://github.com/ohdsi/BrokenAdaptiveRidge/workflows/R-CMD-check/badge.svg)](https://github.com/OHDSI/BrokenAdaptiveRidge/actions?query=workflow%3AR-CMD-check)
[![codecov.io](https://codecov.io/github/OHDSI/BrokenAdaptiveRidge/coverage.svg?branch=main)](https://app.codecov.io/github/OHDSI/BrokenAdaptiveRidge?branch=main)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/BrokenAdaptiveRidge)](https://cran.r-project.org/package=BrokenAdaptiveRidge)
[![CRAN_Status_Badge](http://cranlogs.r-pkg.org/badges/BrokenAdaptiveRidge)](https://cran.r-project.org/package=BrokenAdaptiveRidge)

BrokenAdaptiveRidge is part of [HADES](https://ohdsi.github.io/Hades/).


Introduction
============

`BrokenAdaptiveRidge` is an `R` package for performing L_0-based regressions using `Cyclops`

Examples
========

* Generalized Linear Model
 ```r
library(Cyclops)
library(BrokenAdaptiveRidge)

## data dimension
p <- 30    # number of covariates
n <- 200   # sample size

## logistic model parameters 
itcpt     <- 0.2 # intercept
true.beta <- c(1, 0, 0, -1, 1, rep(0, p - 5))

## simulate data from logistic model
set.seed(100)

x <- matrix(rnorm(p * n, mean = 0, sd = 1), ncol = p)
x <- ifelse(abs(x) > 1., 1, 0)
y <- rbinom(n, 1, 1 / (1 + exp(-itcpt - x%*%true.beta)))


# fit BAR model
cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
barPrior    <- createBarPrior(penalty = 0.1, exclude = c("(Intercept)"), 
                              initialRidgeVariance = 1) 

cyclopsFit <- fitCyclopsModel(cyclopsData,
                              prior = barPrior)
fit1 <- coef(cyclopsFit) 

# fit BAR using sparse-represented covariates
tmp <- apply(x, 1, function(x) which(x != 0))

y.df <- data.frame(rowId = 1:n, y = y)
x.df <- data.frame(rowId = rep(1:n, lengths(tmp)), covariateId = unlist(tmp), covariateValue = 1)

cyclopsData <- convertToCyclopsData(outcomes = y.df, covariates = x.df, modelType = "lr")
barPrior    <- createFastBarPrior(penalty = 0.1, exclude = c("(Intercept)"), 
                                  initialRidgeVariance = 1) 

fit2 <- coef(cyclopsFit) 

# fit BAR using cyclic algorithm
cyclopsData <- createCyclopsData(y ~ x, modelType = "lr")
barPrior    <- createFastBarPrior(penalty = 0.1, exclude = c("(Intercept)"), 
                              initialRidgeVariance = 1) 

cyclopsFit <- fitCyclopsModel(cyclopsData,
                              prior = barPrior)
fit3 <- coef(cyclopsFit) 

fit1
fit2
fit3
 ```

Technology
==========

BrokenAdaptiveRidge is an R package.

System Requirements
===================

Requires `R` (version 3.2.0 or higher).

Dependencies
============

 * `Cyclops`

Installation
============

To install the latest stable version, install from CRAN:

```r
install.packages("BrokenAdaptiveRidge")
```

User Documentation
==================

Documentation can be found on the [package website](https://ohdsi.github.io/BrokenAdaptiveRidge/).

PDF versions of the documentation are also available:

* Package manual: [BrokenAdaptiveRidge manual](https://raw.githubusercontent.com/OHDSI/BrokenAdaptiveRidge/master/extras/BrokenAdaptiveRidge.pdf) 

Support
=======

* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="https://github.com/OHDSI/BrokenAdaptiveRidge/issues">GitHub issue tracker</a> for all bugs/issues/enhancements 

License
=======

`BrokenAdaptiveRidge` is licensed under Apache License 2.0.  

Development
===========

`BrokenAdaptiveRidge` is being developed in R Studio.

Acknowledgements
================

- This project is supported in part through the National Institutes of Health grant R01 HG006139.
