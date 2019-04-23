library('multcomp')
setwd('c:/r/anova')

all.pairs <- function(r)
  list(first = rep(1:r,rep(r,r))[lower.tri(diag(r))],
       second = rep(1:r, r)[lower.tri(diag(r))])

bonferroniCI <- function(fitted, nis, df, MSE, conf.level=.95){
  ## fitted is a sequence of means
  ## nis is a corresponding sequence of sample sizes for each mean
  ## df is the residual df from the ANOVA table
  ## MSE = mean squared error from the ANOVA table
  ## conf.level is the family-wise confidence level, defaults to .95
  r <- length(fitted)
  pairs <- all.pairs(r)
  diffs <- fitted[pairs$first] - fitted[pairs$second]
  T <- qt(1-(1-conf.level)/(2*r*(r-1)),df)
  hwidths <-  T*sqrt(MSE*(1/nis[pairs$first] + 1/nis[pairs$second]))
  val <- cbind(diffs - hwidths, diffs, diffs + hwidths)
  dimnames(val) <- list(paste("mu",pairs$first," - mu", pairs$second,
  sep=""), c("Lower", "Diff","Upper"))
  val
}

selectedBonferroniCI <- function(fitted, nis, df, MSE, conf.level=.95, pairs){
  ## fitted is a sequence of means
  ## nis is a corresponding sequence of sample sizes for each mean
  ## df is the residual df from the ANOVA table
  ## MSE = mean squared error from the ANOVA table
  ## conf.level is the family-wise confidence level, defaults to .95
  r <- length(fitted)
  diffs <- fitted[pairs$first] - fitted[pairs$second]
  T <- qt(1-(1-conf.level)/(2*r*(r-1)),df)
  hwidths <-  T*sqrt(MSE*(1/nis[pairs$first] + 1/nis[pairs$second]))
  val <- cbind(diffs - hwidths, diffs, diffs + hwidths)
  dimnames(val) <- list(paste("mu",pairs$first," - mu", pairs$second,
  sep=""), c("Lower", "Diff","Upper"))
  val
}       
                     
performAnovaAnalysis <- function(groups, values) {
  # perform analysis and return the aov model
  groups = factor(groups)
  return (aov(values ~ groups))
}                    

createFrame <- function(groups, values) {
  return (data.frame(cbind(groups, values)))
}

subsetFrame <- function(theframe, groupId) {
  return (subset(theframe, Groups == groupId)[,2])
}

meanDiff <- function(values1, values2) {
  return (mean(values1) - mean(values2))
}
                     
performBonferroniTest <- function(groups, values, model) {
  values.means <- tapply(values, groups, mean)
  values.len <- tapply(values, groups, length)
  dfMSE <- model$df.residual
  MSE <- sum(model$residuals^2)/dfMSE
  return (bonferroniCI(values.means, values.len, dfMSE, MSE, conf=.95))
}                    

performSelectedBonferroniTest <- function(groups, values, model, pairs) {
  values.means <- tapply(values, groups, mean)
  values.len <- tapply(values, groups, length)
  dfMSE <- model$df.residual
  MSE <- sum(model$residuals^2)/dfMSE
  return (selectedBonferroniCI(values.means, values.len, dfMSE, MSE, conf=.95, pairs))
}                    
                     
performDunnettTest <- function(model) {
  return (glht(model, linfct = mcp(groups = "Dunnett")))
}

performTukeyTest <- function(model) {
  return (glht(model, linfct=mcp(groups = "Tukey")))
}

