Concentration <- c(0.7,1.5625,3.125,6.25,12.5,25,50,0.7,1.5625,3.125,6.25,12.5,25,50,0.7,1.5625,3.125,6.25,12.5,25,50)
Pct.Activity <- c(0.061,0.061333333,0.059,0.060666667,0.061666667,0.06,0.063666667,0.073,0.089,0.112666667,0.096333333,0.092,0.098666667,0.074,0.098333333,0.137,0.162,0.143,0.156666667,0.191333333,0.116)
Series <- c('A1','A1','A1','A1','A1','A1','A1','A2','A2','A2','A2','A2','A2','A2','A3','A3','A3','A3','A3','A3','A3')

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
use.series <- TRUE

dr <- data.frame(Concentration, Pct.Activity)

model <- PerformDRAnalysis('AB-1')