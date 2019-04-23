library('Hmisc')
library('drc')
setwd('c:/r/drexcel')
source('doseResponseGraph.R')

# function to do dr plotting
PerformDRAnalysis <- function(sampleid) {

    # create data frame
    x.name <- "Concentration"
    y.name <- "Pct.Activity"
    series.name <- "NA"
    # set up the data frame with the vectors passed in
    if (use.series) { 
      series.name <- "Series"
      dr <- data.frame(Series, Concentration, Pct.Activity)
    } else {
      dr <- data.frame(Concentration, Pct.Activity)
    }
    # set the parameters for the 4 parameter logistic fit
    if (lock.bottom == "NA") { lock.bottom <- NA }
    if (lock.top == "NA") { lock.top <- NA }
    if (lock.slope == "NA") { lock.slope <- NA }
    params.fixed = c(NA, lock.bottom, lock.top, lock.slope)
    
    # make the graph and generate the model
    my.model <- doseResponseGraph(dr, x.name, y.name, series.name, dev="png", compound.name = paste(sampleid), y.axis.lim = c(y.min, y.max), x.axis.label = x.label, y.axis.label = y.label, size = c(graph.width, graph.height), show.rel.intcept = show.rel.intcept, show.abs.intcept = show.abs.intcept, fixed = params.fixed, font.size = font.size) 
    return (my.model)
}

