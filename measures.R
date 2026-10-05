getaccuracy <- function(tp,fp,tn,fn) {
  val <- (tp + tn)/(tp + tn + fp + fn)
  
  return(val)
}

getprecision <- function(tp,fp,tn,fn) {
  if ((tp + fp) == 0)
    return(0)
  
  val <- tp/(tp + fp)
  
  return(val)
}

getrecall <- function(tp,fp,tn,fn) {
  if ((tp + fn) == 0)
    return(0)
  
  val <- tp/(tp + fn)
  
  return(val)
}

getmatthews <- function(tp,fp,tn,fn) {
  #print(paste(tp,fp,tn,fn))
  denom1 <- sqrt(tp + fp)
  denom2 <- sqrt(tp + fn)
  denom3 <- sqrt(tn + fp)
  denom4 <- sqrt(tn + fn)
  denom <- denom1*denom2*denom3*denom4
  if (denom == 0)
    return(-1)
  
  val <- (tp*tn - fp*fn)/denom
  
  return(val)
}

getweighted <- function(tp,fp,tn,fn) {
  weight <- parameters$weight
  val <- weight*(tp/(tp + fn)) + (1 - weight)*(tn/(tn + fp))
 
  return(val)
}

getf1 <- function(tp,fp,tn,fn) {
  precision <- getprecision(tp,fp,tn,fn)
  recall <- getrecall(tp,fp,tn,fn)
  
  if ((precision + recall) == 0)
    return(0)
  
  f1 <- 2*(precision*recall)/(precision + recall)
  return(f1)
}

evaluate <- function(targetcount,targethits,nontargetcount,nontargethits,measure) {
  tp <- targethits
  fp <- nontargethits
  tn <- nontargetcount - nontargethits
  fn <- targetcount - targethits
  
  if (measure == 'accuracy') 
    eval <- getaccuracy(tp,fp,tn,fn)
  else if (measure == 'matthews')
    eval <- getmatthews(tp,fp,tn,fn)
  else if (measure == 'precision')
    eval <- getprecision(tp,fp,tn,fn)
  else if (measure == 'recall')
    eval <- getrecall(tp,fp,tn,fn)
  else if (measure == 'weighted') 
    eval <- getweighted(tp,fp,tn,fn)
  else if (measure == 'f1') 
    eval <- getf1(tp,fp,tn,fn)
 
  return(c(round(eval,digits = parameters$sigdigits),tp,tn))
}

evaluatebymeasure <- function(conjunction,targetdta,nontargetdta,measure) {
  targetrowcount <- nrow(targetdta)
  nontargetrowcount <- nrow(nontargetdta)
  for (featureno in 1:conjunction$featurecount) {
    fno <- as.numeric(conjunction[1,featurecolstart + 3*(featureno -1)])
    mn <- conjunction[1,featurecolstart + 3*(featureno -1) + 1]
    mx <- conjunction[1,featurecolstart + 3*(featureno -1) + 2]
    #print(paste(fno,mn,mx))
    if (mn == 'level') {
      targetdta <- targetdta[(targetdta[,fno] == mx),]
      nontargetdta <- nontargetdta[(nontargetdta[,fno] == mx),]
      #browser()
    }
    else {
      targetdta <- targetdta[(targetdta[,fno] >= as.numeric(mn)) & (targetdta[,fno] <= as.numeric(mx)),]
      nontargetdta <- nontargetdta[(nontargetdta[,fno] >= as.numeric(mn)) & (nontargetdta[,fno] <= as.numeric(mx)),]
    }
  }
  eval <- evaluate(targetrowcount,nrow(targetdta),nontargetrowcount,nrow(nontargetdta),measure)
  
  return(eval)
}