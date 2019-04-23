# This creates a dose-response graph with all the trimmings, just like grandma used to make.  

ResponseAtConc <- function(the.model, conc, fixed) {
  # get the response at a value, given the model
  # this extracts the calculated parameters from the model
  parms <- unlist(the.model[10])
  if (length(parms) == 2) {
    # this indicates that we have fixed the top and bottom
    Bottom <- fixed[2]
    Top <- fixed[3]
    Curvature <- parms[1]
    X50 <- parms[2]
  } else {
    # this indicates a 4 parameter fit
    Curvature <- parms[1]
    Bottom <- parms[2]
    Top <- parms[3]
    X50 <- parms[4]
  }
  return ((((Top-Bottom)/(1+(conc/X50)^Curvature))+Bottom)[[1]])
}

doseResponseGraph <- function(dr, x.name, y.name, series.name,
                              ed.y = 50, 
                              compound.name="Compound", 
                              x.axis.label="Concentration(uM)", 
                              y.axis.label="% Activity", 
                              y.axis.lim=c(-50,150), 
                              y.axis.autorange = FALSE,
                              dev="screen", 
                              size=c(320,240),
                              show.abs.intcept = FALSE,
                              show.rel.intcept = FALSE,
                              fixed = c(NA, NA, NA, NA),
															font.size = 0.6) {
    # create a dose-response graph, optimized for display on screen
    library(drc)
    library(Hmisc)
        
    params.fixed = fixed
    # construct the dr curves
    if (series.name == "NA") {
      try(my.model <- multdrc(dr[,c(y.name, x.name)], fct = LL.4(fixed = params.fixed)), TRUE)
    } else {
      try(my.model <- multdrc(Pct.Activity ~ Concentration, Series, data = dr, fct = LL.4(fixed = params.fixed)), TRUE)
    }

    # construct error bars
    # split dr into individual concentrations
    drConcs <- split(dr, dr[,x.name])

    x <- as.numeric(names(drConcs))
    y.cent <- unlist(lapply(drConcs, function(x)mean(x[[y.name]])))
    names(y.cent) <- NULL
    y.up <- unlist(lapply(drConcs, function(x)mean(x[[y.name]]) + 0.5*sd(x[[y.name]])))
    names(y.up) <- NULL
    y.down <- unlist(lapply(drConcs, function(x)mean(x[[y.name]]) - 0.5*sd(x[[y.name]])))
    names(y.down) <- NULL
    
    # calculate E/IC50
    # absolute
    try(ed.x <- ED(my.model, c(ed.y), type="absolute")[1,1], TRUE)
    # relative
    try(ed.x.rel <- ED(my.model, c(ed.y), type="relative")[1,1], TRUE)
    # y value of relative ic50
    try(ed.y.rel <- ResponseAtConc(my.model, ed.x.rel, params.fixed), TRUE)
    
    
    # plot the curve
    if (dev == "png") {
        png(paste(compound.name, ".png", sep=""), width=size[1], height=size[2]) 
        oldpar <- par(omi=c(0,0,0,0), mai=c(0.45,0.45,0.3,0.1), cex=font.size)
    }
    
    # allow the plot engine to pick its own colors if we are plotting multiple series    
    # TODO - must be a better way to do this...    
    # check to see if model exists              
    if (exists("my.model")) {    
      if (y.axis.autorange) {
        if (series.name == "NA") {
          plot(my.model, main=compound.name, xlab=x.axis.label, ylab=y.axis.label, pch=19, col=c("blue", "grey62"))
        } else {
          plot(my.model, main=compound.name, xlab=x.axis.label, ylab=y.axis.label, col=TRUE)
        }
      } else {
        if (series.name == "NA") {
          plot(my.model, main=compound.name, xlab=x.axis.label, ylab=y.axis.label, pch=19, col=c("blue", "grey62"), ylim=y.axis.lim)
        } else {
          plot(my.model, main=compound.name, xlab=x.axis.label, ylab=y.axis.label, ylim=y.axis.lim, col=TRUE)
        }
      }
    } else {
      # case for when the model does not exist (couldn't be fit)
      # in this case we fall back to plotting the individual data points
      if (series.name != "NA") {
        # split on series
        drseries <- split(dr, dr[,series.name])
        mypch <- c(1,2,3)
        mycolors = c(1,2,3)
        k = 1
        dr1 <- as.data.frame(drseries[k])
        plot(dr1[,2], dr1[,3], main=compound.name, xlab=x.axis.label, ylab=y.axis.label, pch=mypch[k], col=mycolors[k], ylim=y.axis.lim, log="x")
        for (k in 2:length(drseries)) {
          dr1 <- as.data.frame(drseries[k])
          points(dr1[,2], dr1[,3], col=mycolors[k], pch=mypch[k])
        }
      } else {
        # just plot the one
        plot(dr, main=compound.name, xlab=x.axis.label, ylab=y.axis.label, col=TRUE, ylim=y.axis.lim, log="x")
      }
    }
    

    if (series.name == "NA") {
     # show individual points
     points(dr[[x.name]], dr[[y.name]], pch=16, col="grey62")

      # show error bars
      errbar(x, y.cent, y.up, y.down, add=TRUE, col="darkgreen")
    }

    # show E/IC50
    # show lines for absolute E/IC50 if one exists
    if (show.abs.intcept) {
      if (exists("ed.x") && exists("ed.y")) {
        points(ed.x, ed.y, pch=15, col="darkgreen")    
        if (dev != "png") {
            text(ed.x, ed.y, label=paste(round(ed.x, 3), " uM"), pos=4, cex=0.7)
        }
        lines(c(min(x), ed.x), c(ed.y, ed.y), lty="dashed", col="grey62")
        lines(c(ed.x, ed.x), c(ed.y, -100), lty="dashed", col="grey62")
      }
    }

    # show lines for relative E/IC50 if one exists
    if (show.rel.intcept) {
      if (exists("ed.x.rel") && exists("ed.y.rel")) {
        points(ed.x.rel, ed.y.rel, pch=15, col="darkgreen")    
        if (dev != "png") {
            text(ed.x.rel, ed.y.rel, label=paste(round(ed.x.rel, 3), " uM"), pos=4, cex=0.7)
        }
        lines(c(min(x), ed.x.rel), c(ed.y.rel, ed.y.rel), lty="dashed", col="grey62")
        lines(c(ed.x.rel, ed.x.rel), c(ed.y.rel, -100), lty="dashed", col="grey62")
      }
    }
        
    # clear device if we are using png
    if (dev == "png") {
        par <- oldpar
        dev.off()
    }
    # return the model for future use
    return (my.model)
}

