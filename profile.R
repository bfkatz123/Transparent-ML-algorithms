source('globals.R')
source('measures.R')
source('error.R')

addsingleton <- function(conjunctiondf,featureno,minval,maxval,maxfeatures) {
  conjunctionrow <- c(1,0,0,0,featureno,minval,maxval)
  for (fno in 1:(maxfeatures - 1))
    conjunctionrow <- c(conjunctionrow,c(0,0,0))
  conjunctiondf <- rbind(conjunctiondf,conjunctionrow)
  
  return(conjunctiondf)
}

# get all possible nueric features given parameeter values  
getsingletons <- function(targetstats,parameters) {
  intervals <- makeintervals(parameters$maxsd,parameters$sddelta)
  conjunctiondf <- data.frame(matrix(0,ncol = featurecolstart + 3*parameters$maxfeatures - 1))
  colnames(conjunctiondf) <- getconjunctiondfcolnames(parameters$maxfeatures)

  if (nrow(targetstats) == 1)
    return(conjunctiondf[-1,])
  
  for (featureno in 1:(nrow(targetstats) - 1)) {
    for (interval in intervals) {
      minval <- targetstats$mean[featureno] + interval[1]*targetstats$sd[featureno]
      minval <- max(minval,targetstats$min[featureno])
      minval <- round(minval,digits = parameters$sigdigits)
      maxval <- targetstats$mean[featureno] + interval[2]*targetstats$sd[featureno]
      maxval <- min(maxval,targetstats$max[featureno])
      maxval <- round(maxval,digits = parameters$sigdigits)
      if (maxval > minval) {
        conjunctiondf <- addsingleton(conjunctiondf,row.names(targetstats)[featureno],minval,maxval,parameters$maxfeatures)
      }
    }
  }
  conjunctiondf <- unique(conjunctiondf)
  
  return(conjunctiondf[2:nrow(conjunctiondf),])
}

# add factor singletons to list (one for each factor level for all factor features)
addfactorsingletons <- function(dta,singletondf) {
  for (col in 1:(ncol(dta) - 1)) {
    if (is.factor(dta[,col])) {
      for (level in levels(dta[,col])) {
        row <- singletondf[1,]
        row[featurecolstart] <- col
        row[featurecolstart + 1] <- 'level'
        row[featurecolstart + 2] <- level
        singletondf <- rbind(singletondf,row)
      }
    }
  }
  singletondf[,1] <- rep(1,nrow(singletondf))
  
  return(singletondf)
}

# evaluate each conjunction relative to current measure
# prune to beam count
evalandprune <- function(conjunctiondf,targetdta,nontargetdta,parameters) {
  for (row in 1:nrow(conjunctiondf)) {
    eval <- evaluatebymeasure(conjunctiondf[row,],targetdta,nontargetdta,parameters$measure)
    conjunctiondf$eval[row] <- eval[1]
    conjunctiondf$truepos[row] <- eval[2]
    conjunctiondf$trueneg[row] <- eval[3]
  }

  conjunctiondf <- conjunctiondf[order(as.numeric(conjunctiondf$eval),decreasing = TRUE),]
  rowcount <- min(nrow(conjunctiondf),parameters$beamsize)
  conjunctiondf <- conjunctiondf[1:rowcount,]
  
  return(conjunctiondf)
}

# fills out result with NAs if less than maxfeatures in each conjunction
# adds false neg and false pos count to each result row
cleanresult <- function(masterdf,dta,targetcount,nontargetcount,maxfeatures) {
  idxs <- which((masterdf$truepos == masterdf$truepos[1]) & (masterdf$trueneg == masterdf$trueneg[1]))
  masterdf <- masterdf[idxs,]
  row.names(masterdf) <- 1:nrow(masterdf)
  for (row in 1:nrow(masterdf)) {
    for (fno in 1:maxfeatures) {
      idx <- featurecolstart + 3*(fno - 1)
      featureno <- as.numeric(masterdf[row,idx])
      if ((is.na(featureno)) || featureno == 0) {
        masterdf[row,idx:(idx + 2)] <- NA
      }
      else {
        masterdf[row,idx] <- colnames(dta)[featureno]
      }
    }
  }
  
  falsenegcount <- targetcount - as.numeric(masterdf$truepos[1])
  falseposcount <- nontargetcount - as.numeric(masterdf$trueneg[1])
  falseneg <- rep(falsenegcount,nrow(masterdf))
  falsepos <- rep(falseposcount,nrow(masterdf))
  masterdf <- cbind(masterdf[,1:3],falseneg,masterdf[,4],falsepos,masterdf[,5:ncol(masterdf)])
  colnames(masterdf)[5] <- 'trueneg'
  
  return(masterdf)
}

# the main function call, takes data and produces a profile guided by argument values
# first produces all single feature conjunctions
# then adds features successively to this list, pruning at each stage by the designated measure
makeprofile <- function(dta,
                        targetname,
                        percent = .05,
                        top = TRUE,
                        targetlevel = '',
                        maxsd = 3,
                        sddelta = 1,
                        beamsize = 32,
                        maxfeatures = 3,
                        measure = 'matthews',
                        weight = .5,
                        ignorena = 'rows',
                        sigdigits = 4
                        ) {
  errorcheckdata(dta,targetname,targetlevel)
  errorcheckparameters(maxsd,sddelta,top,beamsize,maxfeatures,measure,weight,ignorena,sigdigits)

  parameters <- setparameters(maxsd,sddelta,beamsize,maxfeatures,measure,weight,ignorena,sigdigits)
  dta <- makegoallastcol(dta,targetname)
  dta <- removenarowscols(dta,parameters$ignorena)
  filtereddta <- getfiltereddta(dta,percent,top,targetlevel)
  targetdta <- filtereddta[[1]]
  nontargetdta <- filtereddta[[2]]
  errorcheckfilter(targetdta,nontargetdta,parameters$maxfeatures)
  targetstats <- getcolstats(targetdta)
 
  # get single feature conjunctions first
  print('Forming conjunction: 1')
  singletondf <- getsingletons(targetstats,parameters)
  singletondf <- addfactorsingletons(dta,singletondf)
  singletondf <- evalandprune(singletondf,targetdta,nontargetdta,parameters)

  # add features up to max features to each conjunction pruning by measure on each iteration
  masterdf <- singletondf
  if (parameters$maxfeatures > 1) {
    conjunctiondf <- singletondf
    for (featureno in 1:(parameters$maxfeatures - 1)) {
      print(paste('Forming conjunction:',(featureno + 1)))
      conjunctiondf <- addsingletons(conjunctiondf,singletondf,featureno,parameters$maxfeatures)
      if (!is.null(conjunctiondf)) {
        conjunctiondf <- evalandprune(conjunctiondf,targetdta,nontargetdta,parameters)
        masterdf <- rbind(masterdf,conjunctiondf)
      }
      else
        break
    }
  }
  
  # get evaluation over all produced conjunctions regardless of feature count
  masterdf <- masterdf[order(masterdf$eval,decreasing = TRUE),]
  masterdf <- cleanresult(masterdf,dta,nrow(targetdta),nrow(nontargetdta),parameters$maxfeatures)
  
  return(masterdf)
}