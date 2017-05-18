coxbar <- function(t, delta, X, sparseX = FALSE, COO = NULL, cyclopsForm = NULL, exclude = NULL,
                   lambda = 1, xi = 2, d = 0, max.iter = 1E4, tol = 1E-6, eps = 1E-6, scale = F){

  if(scale == T) {
    beta.sd <- apply(X, 2, sd, na.rm = TRUE)
    X <- scale(X, center = FALSE, scale = apply(X, 2, sd, na.rm = TRUE))
    }
  
  # ----- Values of 0 for xi and lambda:
  lambda <- ifelse(lambda == 0, 1E-8, lambda)
  xi     <- ifelse(xi == 0, 1E-8, xi)
  
  # ----- If the data is already a Cyclops Env. via createCyclopsData
  if(is.null(cyclopsForm) == TRUE) {
    if(is.null(COO) == FALSE) {
      # ----- If data matrix is in COO form (rowId, covariateId, covariateValue): 
      outcomes <- data.frame(rowId = 1:length(t), time = t, y = delta)
      barData  <- convertToCyclopsData(outcomes, COO, modelType = "cox")
    } else if(sparseX == FALSE) {
      # ----- If X is a sparse matrix (Note: not sparseMatrix type, just sparse in entries)
      barData  <- createCyclopsData(Surv(t, delta) ~ 1, sparseFormula = ~ X, modelType = "cox")
    } else {
      # ----- If X is a dense matrix. (Good for moderate/small n and p)
      barData  <- createCyclopsData(Surv(t, delta) ~ X, modelType = "cox")
      }
  } else {
    # ----- If data is already a Cyclops Object
    barData <- cyclopsForm
  }
  
  
  ridge.prior <- createPrior("normal", variance = 1/xi)
  if(is.null(exclude) == FALSE) {
    ridge.prior$exclude = exclude
  }
  
  ridgeFit <- fitCyclopsModel(barData, prior = ridge.prior) #fit initial ridge regression 
  beta0    <- coef(ridgeFit) #store beta0
  
  #----- Run iterative BAR method
  full.fit <- bar_fit(barData, beta0, lambda = lambda, d = d, exclude = exclude, 
                      max.iter = max.iter, tol = tol, eps = eps, scale = scale, 
                      sd = beta.sd)
  
  
  # ----- RESULTS TO BE STORED
  bar_results       <- full.fit 
  bar_results$xi    <- xi
  #bar_results$delta <- 1 - mean(delta) 
  return(bar_results)
}

# ----
# bar_results store:
# beta: Coefficient estimates from BAR
# loglik: The log-likelihood
# lambda: Value of lambda (BAR) tuning parameter
# iter: Number of iterations until convergence
# conv: Logical. If convergence was achieved
# ridge: Initial Ridge Estimates
# xi: Value of xi (ridge) tuning parameter 

