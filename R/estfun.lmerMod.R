estfun.lmerMod <- function(object, level = 2, ...) {
  if (!is(object, "lmerMod")) stop("estfun.lmerMod() only works for lmer() models.")
    
  ## get all elements by getME and exclude multiple random effect models.
  parts <- getME(object, "ALL")
  if (length(parts$l_i) > 1 & level == 2) stop("Multiple cluster variables detected. Supply 'level=1' argument to estfun.lmerMod().")
  
  ## prepare shortcuts
  yXbe <- parts$y - tcrossprod(parts$X, t(parts$beta))
  Zlam <- tcrossprod(parts$Z, parts$Lambdat)
  V <- (tcrossprod(Zlam, Zlam) + diag(1, parts$n)) * (parts$sigma)^2
  M <- solve(chol(V))
  invV <- tcrossprod(M, M)
  yXbesoV <- crossprod(yXbe, invV)
  LambdaInd <- parts$Lambda
  LambdaInd@x[] <- as.double(parts$Lind)
  invVX <- crossprod(parts$X, invV)
  Pmid <- solve(crossprod(parts$X, t(invVX)))
  P <- invV - tcrossprod(crossprod(invVX, Pmid), t(invVX))
  
  ## adapt from Stroup book page 131, last eq,
  ## score for fixed effects parameter: score_beta=XR^{-1}(y-Zb-X\beta)
  score_beta <- t(crossprod(parts$X, invV)) * (yXbe)
  
  ## prepare for score of variance covariance parameters. 
  ## get d(G)/d(sigma), faciliated by d(Lambda).
  uluti <- length(parts$theta)
  devLambda <- vector("list", uluti)
  score_varcov <- matrix(NA, nrow = length(parts$y), ncol = uluti)
  devV <- vector ("list", (uluti + 1))
  
  for (i in 1:uluti) {
    devLambda[[i]] <- forceSymmetric(LambdaInd==i, uplo = "L")
    devV[[i]] <- tcrossprod(tcrossprod(parts$Z, t(devLambda[[i]])), parts$Z)
  }
  devV[[(uluti+1)]] <- diag(1,nrow(parts$X))
  
  ## score for variance covariance parameter
  score_varcov <- matrix(NA, nrow = nrow(parts$X), ncol = (uluti + 1))
  
  ## ML estimates. 
  if (object@devcomp$dims[10] == 0) {
    for (j in 1:length(devV)) {
      score_varcov[,j] <- as.vector(-(1/2) * diag(crossprod(invV, devV[[j]])) +
      t((1/2) * tcrossprod(tcrossprod(yXbesoV, t(devV[[j]])), invV)) *
      (yXbe))
    }
  }

  ## REML estimates
   if (object@devcomp$dims[10] == 2|object@devcomp$dims[10] == 1) {
    for (j in 1:length(devV)) {
      score_varcov[,j] <- as.vector(-(1/2) * diag(crossprod(P, devV[[j]])) +
      t((1/2) * tcrossprod(tcrossprod(yXbesoV, t(devV[[j]])), invV)) *
      (yXbe))
    }
  }
  
  ## Organize score matrix
  score <- cbind(as.matrix(score_beta), score_varcov)
  colnames(score) <- c(names(parts$fixef),
                       paste("cov", names(parts$theta), sep="_"), "residual")
  
  ## Clusterwise scores if level==2
  if (level == 2) {
    index <- parts$flist[[1]]
    index <- index[order(index)]
    score <- aggregate(x = score, by = list(index), FUN = sum)[,-1]
  }

  return(score)
}
