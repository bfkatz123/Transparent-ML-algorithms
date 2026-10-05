
gaussian <- function(a,x,mu,sigma) {
  arg <- ((x - mu)^2)/(2*sigma^2)
  val <- a*exp(-arg)
  
  return(val)
}

getcolstats <- function(dta) {
  stats <- data.frame()
  for (col in 1:ncol(dta)) {
    if (is.numeric(dta[,col])) {
      stats <- rbind(stats,
                     c(colnames(dta)[col],
                       mean(dta[,col]),
                       sd(dta[,col]),
                       min(dta[,col]),
                       max(dta[,col])))
      row.names(stats)[nrow(stats)] <- col
    }
  }
 
  for (col in 2:5)
    stats[,col] <- as.numeric(stats[,col])
  colnames(stats) <- c('fname','mean','sd','min','max')
  return(stats)
}

getfiltereddta <- function(dta,percent,top,goallevel) {
  if (is.factor(dta[,ncol(dta)])) {
    targetidxs <- which(dta[,ncol(dta)] == goallevel)
    nontargetidxs <- setdiff(1:nrow(dta),targetidxs)
    targetdta <- dta[targetidxs,]
    nontargetdta <- dta[nontargetidxs,]
  }
  else {
    dta <- dta[order(dta[,ncol(dta)],decreasing = top),]
    topn <- round(percent*nrow(dta))
    targetdta <- dta[1:topn,]
    nontargetdta <- dta[(topn + 1):nrow(dta),]
  }
 
  return(list(targetdta,nontargetdta))
}

makeintervals <- function(maxsd,sddelta) {
 intervals <- list()
 sd1 <- - maxsd
 while (sd1 < maxsd) {
   sd2 <- sd1 + sddelta
   while (sd2 <= maxsd) {
     intervals <- append(intervals,list(c(sd1,sd2)))
     sd2 <- sd2 + sddelta
   }
   sd1 <- sd1 + sddelta
 }
  
 return(intervals)
}

formconjunction <- function(conjunctiondf,combination) {
  conjdf <- NULL
  for (row in combination) {
    for (fno in 1:parameters$maxfeatures) {
      idx <- featurecolstart + 3*(fno - 1)
      featno <- conjunctiondf[row,idx]
      if (featno > 0) {
        conjdf <- rbind(conjdf,conjunctiondf[row,idx:(idx + 2)])
      }
    }
  }
  
  if (!any(duplicated(conjdf[,1]))) {
    conjdf <- conjdf[order(conjdf[,1]),]
    newconjunction <- rep(0,featurecolstart - 1)
    newconjunction[1] <- length(combination)
    for (row in 1:nrow(conjdf)) {
      newconjunction <- c(newconjunction,unlist(conjdf[row,]))
    }
    newconjunction <- fillout(newconjunction,featurecolstart - 1 + 3*parameters$maxfeatures)
    return(newconjunction)
  }
  
  return(NULL)
}

allowedconjunction <- function(conjunction) {
  features <- NULL
  for (fno in 1:parameters$maxfeatures) {
    feature <- conjunction[featurecolstart + 3*(fno - 1)]
    #print(paste(fno,feature))
    if ((!is.na(feature)) && (feature > 0))
      features <- c(features,feature)
  }
 
  return(length(unique(features)) == length(features))
}

sortconjunction <- function(conjunction) {
  conjdf <- data.frame()
  for (fno in 1:parameters$maxfeatures) {
    idx <- featurecolstart + 3*(fno - 1)
    featno <- as.numeric(conjunction[idx])
    if ((!is.na(featno)) && (featno > 0)) {
      conjdf <- rbind(conjdf,conjunction[idx:(idx + 2)])
      }
  }
 
  conjdf <- conjdf[order(conjdf[,1]),]
  for (row in 1:nrow(conjdf)) {
    idx <- featurecolstart + 3*(row - 1)
    conjunction[idx] <- conjdf[row,1]
    conjunction[idx + 1] <- conjdf[row,2]
    conjunction[idx+ 2] <- conjdf[row,3]
  }
  
  return(conjunction)
}

addsingletons <- function(conjunctiondf,singletondf,featurecount,maxfeatures) {
  newconjunctiondf <- data.frame()
  for (row1 in 1:nrow(conjunctiondf)) {
    for (row2 in 1:nrow(singletondf)) {
      col <- featurecolstart + 3*(featurecount)
      newrow <- unlist(conjunctiondf[row1,])
      newrow[col] <- singletondf[row2,featurecolstart]
      newrow[col + 1] <- singletondf[row2,featurecolstart + 1]
      newrow[col + 2] <- singletondf[row2,featurecolstart + 2]
      if (allowedconjunction(newrow)) {
        newrow <- sortconjunction(newrow)
        newrow[1] <- featurecount + 1
        newrow[2:4] <- c(0,0,0)
        newconjunctiondf <- rbind(newconjunctiondf,newrow)
      }
    }
  }
  
  if (nrow(newconjunctiondf) == 0)
    return(NULL)
  
  newconjunctiondf <- unique(newconjunctiondf)
  colnames(newconjunctiondf) <- getconjunctiondfcolnames(maxfeatures)

  return(newconjunctiondf)
}

getnconjunctionsatatime <- function(conjunctiondf,featurecount) {
  if (featurecount == 1)
    return(conjunctiondf)
  
  newconjunctiondf <- NULL
  combinations <- combn(1:nrow(conjunctiondf),featurecount)
  for (col in 1:ncol(combinations)) {
    combination <- combinations[,col]
    conjunction <- formconjunction(conjunctiondf,combination)
    newconjunctiondf <- rbind(newconjunctiondf,conjunction)
  }
  
  colnames(newconjunctiondf) <- getconjunctiondfcolnames()
  return(data.frame(newconjunctiondf))
}

fillout <- function(v,len) {
  v <- c(v,rep(0,len - length(v)))
  
  return(v)
}

getconjunctiondfcolnames <- function(maxfeatures) {
  cnames <- evalnames
  for (fno in 1:maxfeatures) {
    cnames <- c(cnames,paste0(featurecolnames,fno))
  }

  return(cnames)
}

makegoallastcol <- function(dta,goalname) {
  idx <- which(colnames(dta) == goalname)
  goalcol <- dta[,idx]
  dta <- dta[,-idx]
  dta <- cbind(dta,goalcol)
  colnames(dta)[ncol(dta)] <- goalname
  
  return(dta)
}

removenarowscols <- function(dta,ignorena) {
  # always remove from goal
  idxs <- which(is.na(dta[,ncol(dta)]))
  if (length(idxs) > 0)
    dta <- dta[-idxs,]
  
  if (ignorena == 'rows') {
    ignorerows <- NULL
    for (row in 1:nrow(dta)) {
      idxs <- which(is.na(dta[row,]))
      if (length(idxs) > 0) 
        ignorerows <- c(ignorerows,row)
    }
    if (length(ignorerows) > 0) 
      dta <- dta[-ignorerows,]
  }
  
  if (ignorena == 'cols') {
    ignorecols <- NULL
    for (col in 1:(ncol(dta) - 1)) {
      idxs <- which(is.na(dta[,col]))
      if (length(idxs) > 0) 
        ignorecols <- c(ignorecols,col)
    }
   
    if (length(ignorecols) > 0) 
      dta <- dta[,-ignorecols]
  }
  
  return(dta)
}

isnumericinteger <- function(x) {
  return(x == floor(x))
}