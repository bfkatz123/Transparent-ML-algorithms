featurecolstart <- 5
evalnames <- c('featurecount','eval','truepos','trueneg')
featurecolnames <- c('feature','attr1','attr2')
measures <- c('accuracy','precision','recall','f1','matthews','weighted')
ignorenas <- c('rows','cols')


setparameters <- function(maxsd,sddelta,beamsize,maxfeatures,measure,weight,ignorena,sigdigits) {
  parameters <-
    list(maxsd = maxsd,
         sddelta = sddelta,
         beamsize = beamsize,
         maxfeatures = maxfeatures,
         measure = measure,
         weight = weight,
         ignorena = ignorena,
         sigdigits = sigdigits)
  
  return(parameters)
}