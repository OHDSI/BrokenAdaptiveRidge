#' @importFrom Cyclops createPrior

bar_fit <- function(barData, beta0, lambda = 1, d = 0, exclude = NULL, w = NULL, max.iter = 1E6, tol = 1E-6, eps = 1E-6, scale = F, sd = NULL){

  pre_coef   <- beta0
  converge   <- FALSE
  iter       <- 0
  bar_result <- list() #Listing results

  prior.type <- rep("normal", length(pre_coef)) #For reweighting the BAR penalty

  while(converge == FALSE | iter > max.iter){
    iter <- iter + 1

    #To prevent arithmetic overflow (fix small coefficients to eps)
    pre_coef <- ifelse(abs(pre_coef) <= eps, eps*sign(pre_coef), pre_coef)

    #Creating BAR prior
    bar.prior      <- createPrior(prior.type, variance = abs(pre_coef)^(2-d)/lambda)

    if(is.null(exclude) == FALSE) {
      bar.prior$exclude = exclude
    }

    barFit         <- fitCyclopsModel(barData, weights = w, prior = bar.prior) #Fitting BAR method

    #Stopping Criterion
    #ifelse(sum((coef(barFit) - pre_coef)^2) < tol, converge <- TRUE, pre_coef <- coef(barFit))
    ifelse(max(abs(coef(barFit) - pre_coef)) < tol, converge <- TRUE, pre_coef <- coef(barFit))

    if(iter > max.iter){stop(paste0('Algorithm did not converge after ', max.iter, ' iterations.', ' Estimates may not be stable.'))}
  } #End optimization

  beta.hat <- ifelse(abs(coef(barFit)) > eps, coef(barFit), 0)

  if(scale == F){
    beta.hat <- beta.hat
  } else {
    beta.hat <- beta.hat/sd
  }

  # ----- Results
  bar_result$beta   <- beta.hat
  bar_result$loglik <- barFit$log_likelihood
  bar_result$lambda <- lambda
  bar_result$iter   <- iter
  bar_result$conv   <- converge
  bar_result$ridge  <- beta0
  return(bar_result)
}

# -----
# bar_results store:
# beta: Coefficient estimates from BAR
# loglik: The log-likelihood
# lambda: Value of lambda tuning parameter
# iter: Number of iterations until convergence
# conv: Logical. If convergence was achieved
# ridge: Initial Ridge Estimates
