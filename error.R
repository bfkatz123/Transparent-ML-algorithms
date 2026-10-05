
errorcheckdata <- function(dta,targetname,targetlevel) {
  idx <- which(colnames(dta) == targetname)
  if (length(idx) == 0)
    stop('Target name not found in data columns',call. = FALSE)
  if ((targetlevel != '') && (!is.factor(dta[,idx])))
    stop('Target level supplied but target column is not a factor',call. = FALSE)
  targetidxs <- which(dta[,idx] == targetlevel)
  if ((targetlevel != '') && (length(targetidxs) == 0))
    stop('Level not found in target column',call. = FALSE)
}

errorcheckparameters <- function(maxsd,sddelta,top,beamsize,maxfeatures,measure,weight,ignorena,sigdigits) {
  if (maxsd <= 0)
    stop('maxsd must be greater than 0',call. = FALSE)
  if (sddelta <= 0)
    stop('sddelta must be greater than 0',call. = FALSE)
  if (sddelta > 2*maxsd)
    stop('sdelta must be less than 2*maxsd',call. = FALSE)
  if (!is.logical(top))
    stop('top must be logical',call. = FALSE)
  if ((beamsize <= 0) || (!isnumericinteger(beamsize)))
    stop('beamsize must be a positive integer',,call. = FALSE)
  if ((maxfeatures <= 0) || (!isnumericinteger(maxfeatures)))
    stop('maxfeatures must be a positive integer',call. = FALSE)
  if (!(measure %in% measures)) 
    stop(paste('measure must be one of',toString(measures)),call. = FALSE)
  if ((weight < 0) || (weight > 1))
    stop('weight must be between 0 and 1',call. = FALSE)
  if (!(ignorena %in% ignorenas)) 
    stop(paste('ignorena must be one of',toString(ignorenas)),call. = FALSE)
  if ((sigdigits <= 0) || (!isnumericinteger(sigdigits)))
    stop('sigdigits must be a positive integer',call. = FALSE)
}

errorcheckfilter <- function(targetdta,nontargetdta,maxfeatures) {
  if (nrow(targetdta) < 2) 
    stop('insufficent rows in target data',call. = FALSE)
  if (ncol(targetdta) < maxfeatures) 
    stop('insufficent columns in target data',call. = FALSE)
}