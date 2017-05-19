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
  cyclopsData <- createCyclopsDataFrame(formula) ## TODO: Update
  cyclopsFit <- fitCyclopsModel(cyclopsData)
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


