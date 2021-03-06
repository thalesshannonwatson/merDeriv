\name{llcont.lmerMod}
\alias{llcont.lmerMod}
\title{Extract Case-wise Log Likelihoods for Linear Mixed Effects Models}
\description{A function for extracting the case-wise log likelihoods
  of a linear mixed effects model fitted via \pkg{lme4}. 
  This function returns the case-wise log likelihoods, evaluated at the
  ML estimates.
}
\usage{
\method{llcont}{lmerMod}(object, \dots)
}
\arguments{
  \item{object}{An object of class \code{\linkS4class{lmerMod}}.}
  \item{\dots}{additional arguments.}
}
\value{A vector of length \emph{n}, containing log-likelihoods for the \emph{n} observations. }
\references{
  Wang, T. & Merkle, E. C. (2016). Derivative Computations and Robust Standard
  Errors for Linear Mixed Effects Models in lme4. 
  \url{https://arxiv.org/abs/1612.04911}
  
  Merkle, E. C., You, D. and Preacher, K. J., 2016. Testing Nonnested Structural 
  Equation Models. \emph{Psychological Methods}, \bold{21}(2), 151. 
  \url{https://arxiv.org/pdf/1402.6720v3}
}
\examples{
\dontrun{
    # The sleepstudy example
    lme4fit <- lmer(Reaction ~ Days + (Days|Subject), sleepstudy, REML = FALSE)

    # casewise log likelihood
    llcont(lme4fit)
}  
}