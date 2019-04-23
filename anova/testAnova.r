source('c:/r/anova/anova.r')

Groups <- c(1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4)
Values <- c(242.3,67.4,331.9,206,101.9,136.4,205.2,75.4,99.8,95,62.4,80.8,0.6,3.5,15.0,13.0,2.0,19.0,82.9,67.8,210.8,284.2,130.1,71.3)
my.frame <- createFrame(Groups, Values)
Value1 <- subsetFrame(my.frame, 1)
Value2 <- subsetFrame(my.frame, 2)

pairs <- list(first = c(1,1,2), second = c(3,4,4))
model <- performAnovaAnalysis(Groups, Values)
post.bonf <- performBonferroniTest(Groups, Values, model)
post.bonfsel <- performSelectedBonferroniTest(Groups, Values, model, pairs)
post.tukey <- performTukeyTest (model)
post.dunnett <- performDunnettTest (model)
post.t <- t.test(Value1, Value2)
mean.diff <- meanDiff(Value1, Value2)


                                                   