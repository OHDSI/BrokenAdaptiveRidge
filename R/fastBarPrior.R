# @file fastBarPrior.R
#
# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of BrokenAdaptiveRidge
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Marc A. Suchard
# @author Ning Li
# @author Eric S. Kawaguchi

#' @title Create a fastBAR Cyclops prior object
#'
#' @description
#' \code{createFastBarPrior} creates a fastBAR Cyclops prior object for use with \code{\link[Cyclops]{fitCyclopsModel}}.
#'
#' @param penalty        Specifies the BAR penalty
#' @param exclude        A vector of numbers or covariateId names to exclude from prior
#' @param forceIntercept Logical: Force intercept coefficient into regularization
#' @param fitBestSubset  Logical: Fit final subset with no regularization
#' @param initialRidgeVariance Numeric: variance used for algorithm initiation
#' @param tolerance Numeric: maximum abs change in coefficient estimates from successive iterations to achieve convergence
#' @param maxIterations Numeric: maximum iterations to achieve convergence
#' @param threshold Numeric: absolute threshold at which to force coefficient to 0
#'
#' @examples
#' nobs = 500; ncovs = 100
#' prior <- createFastBarPrior(penalty = log(ncovs), initialRidgeVariance = 1 / log(ncovs))
#'
#' @return
#' A BAR Cyclops prior object of class inheriting from
#' \code{"cyclopsPrior"} for use with \code{fitCyclopsModel}.
#'
#' @import Cyclops
#'
#' @export
createFastBarPrior <- function(penalty = 0,
                           exclude = c(),
                           forceIntercept = FALSE,
                           fitBestSubset = FALSE,
                           initialRidgeVariance = 1E4,
                           tolerance = 1E-8,
                           maxIterations = 1E4,
                           threshold = 1E-6) {

  # TODO Check that penalty (and other arguments) is valid

  fitHook <- function(...) {
    # closure to capture BAR parameters
    fastBarHook(fitBestSubset, initialRidgeVariance, tolerance,
            maxIterations, threshold, ...)
  }

  structure(list(penalty = penalty,
                 exclude = exclude,
                 forceIntercept = forceIntercept,
                 fitHook = fitHook),
            class = "cyclopsPrior")
}

# Below are package-private functions

fastBarHook <- function(fitBestSubset,
                    initialRidgeVariance,
                    tolerance,
                    maxIterations,
                    delta,
                    cyclopsData,
                    barPrior,
                    control,
                    weights,
                    forceNewObject,
                    returnEstimates,
                    startingCoefficients,
                    fixedCoefficients) {

  # Getting starting values
  startFit <- Cyclops::fitCyclopsModel(cyclopsData, prior = createBarStartingPrior(cyclopsData,
                                                                                   exclude = barPrior$exclude,
                                                                                   forceIntercept = barPrior$forceIntercept,
                                                                                   initialRidgeVariance = initialRidgeVariance),
                                       control, weights, forceNewObject, returnEstimates, startingCoefficients, fixedCoefficients)

  priorType <- createFastBarPriorType(cyclopsData, barPrior$exclude, barPrior$forceIntercept)
  include <- setdiff(c(1:Cyclops::getNumberOfCovariates(cyclopsData)), priorType$excludeIndices)

  working_coef <- coef(startFit)
  penalty <- getPenalty(cyclopsData, barPrior)

  futile.logger::flog.trace("Initial penalty: %f", penalty)

  continue <- TRUE
  count <- 0
  converged <- FALSE
  variance <- rep(1 / penalty, getNumberOfCovariates(cyclopsData)) #Create penalty for each covariate.

  while (continue) {
    count <- count + 1

    #Note: Don't fix zeros as zero for next iteration.
    #fixed <- working_coef == 0.0
    if (!is.null(priorType$excludeIndices)) {
      working_coef[priorType$excludeIndices]
      #fixed[priorType$excludeIndices] <- FALSE
      variance[priorType$excludeIndices] <- 0
    }

    prior <- Cyclops::createPrior(priorType$types, variance = variance,
                                  forceIntercept = barPrior$forceIntercept)
    #Fit fastBAR for one epoch
    fit <- Cyclops::fitCyclopsModel(cyclopsData,
                                    prior = prior,
                                    control = createControl(convergenceType = "onestep"),
                                    weights, forceNewObject,
                                    startingCoefficients = working_coef)

    coef <- coef(fit)

    end <- min(10, length(variance))
    futile.logger::flog.trace("Itr: %d", count)
    futile.logger::flog.trace("\tVar : ", variance[1:end], capture = TRUE)
    futile.logger::flog.trace("\tCoef: ", coef[1:end], capture = TRUE)
    futile.logger::flog.trace("")

    #Check for convergence
    if (max(abs(coef - working_coef)) < tolerance) {
      converged <- TRUE
    } else {
      working_coef <- coef
    }

    if (converged || count >= maxIterations) {
      continue <- FALSE
    }
  }

  if (count >= maxIterations) {
    stop(paste0('Algorithm did not converge after ',
                maxIterations, ' iterations.',
                ' Estimates may not be stable.'))
  }

  if (fitBestSubset) {
    fit <- Cyclops::fitCyclopsModel(cyclopsData, prior = createPrior("none"),
                                    control, weights, forceNewObject, fixedCoefficients = (working_coef == 0))
  }

  class(fit) <- c(class(fit), "cyclopsFastBarFit")
  fit$barConverged <- converged
  fit$barIterations <- count
  fit$penalty <- penalty
  fit$barFinalPriorVariance <- variance

  return(fit)
}

createFastBarPriorType <- function(cyclopsData,
                                   exclude,
                                   forceIntercept) {

  exclude <- Cyclops:::.checkCovariates(cyclopsData, exclude)

  if (Cyclops:::.cyclopsGetHasIntercept(cyclopsData) && !forceIntercept) {
    interceptId <- bit64::as.integer64(Cyclops:::.cyclopsGetInterceptLabel(cyclopsData))
    warn <- FALSE
    if (is.null(exclude)) {
      exclude <- c(interceptId)
      warn <- TRUE
    } else {
      if (!interceptId %in% exclude) {
        exclude <- c(interceptId, exclude)
        warn <- TRUE
      }
    }
    if (warn) {
      warning("Excluding intercept from regularization")
    }
  }

  indices <- NULL
  if (!is.null(exclude)) {
    covariateIds <- Cyclops::getCovariateIds(cyclopsData)
    indices <- which(covariateIds %in% exclude)
  }

  # "Unpenalize" excluded covariates
  types <- rep("barupdate", Cyclops::getNumberOfCovariates(cyclopsData))
  if (!is.null(exclude)) {
    types[indices] <- "none"
  }

  list(types = types,
       excludeCovariateIds = exclude,
       excludeIndices = indices)
}



#Same as Prior.R
#createBarStartingPrior <- function(cyclopsData,
#                                   exclude,
#                                   forceIntercept,
#                                   initialRidgeVariance) {
#
#  Cyclops::createPrior("normal", variance = initialRidgeVariance, exclude = exclude, forceIntercept = forceIntercept)
#}

