Concentration <- c(0.7, 1.5625,3.125,6.25,12.5,25,50)
Pct.Activity <- c(0.199667, 0.148667, 0.149333, 0.150667, 0.209667, 0.195, 0.149667)

y.min <- -10
y.max <- 150
x.label <- "Concentration"
y.label <- "Pct Activity"
graph.width <- 320
graph.height <- 240
show.abs.intcept <- TRUE
show.rel.intcept <- TRUE
lock.bottom <- "NA"
lock.top <- "NA"
lock.slope <- "NA"
use.series <- FALSE

dr <- data.frame(Concentration, Pct.Activity)

model <- PerformDRAnalysis('AB-1')