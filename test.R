library(ggplot2)

makeartificialgoal <- function(dta,mu,sigma,op,noise,
                               randomfeaturecount,
                               factorfeaturecount,factorlevels) {
  goalcol <- rep(0,nrow(dta))
  for (col in 1:length(mu)) {
    xformedcol <- gaussian(1,dta[,col],mu[col],sigma)
    goalcol <- goalcol + xformedcol
  }
  
  fno <- 1
  for (colno in (length(mu) + randomfeaturecount + 1):ncol(dta)) {
    for (attrno in 1:factorlevels[fno]) {
      attr <- levels(dta[,colno])[attrno]
      idxs <- which(dta[,colno] == attr)
      goalcol[idxs] <- goalcol[idxs] + 2*runif(1)
    }
    
    fno <- fno + 1
  }
  goalcol <- goalcol + runif(length(goalcol))
  return(goalcol)
}

makeartificialdataset <- function(featurecount,randomfeaturecount,
                                  factorfeaturecount,factorlevels,factorlevelcount,
                                  rowcount,sigma,op,noise,
                                  factorgoal,goallevels,
                                  naproportion) {
  numericfeaturecount <- featurecount + randomfeaturecount
  for (featureno in 1:numericfeaturecount) {
    col <- runif(rowcount)
    naidxs <- sample(rowcount,round(naproportion*rowcount))
    col[naidxs] <- NA
    if (featureno == 1)
      dta <- data.frame(col)
    else
      dta <- cbind(dta,col)
  }

  for (featureno in 1:factorfeaturecount) {
    vals <- sample(1:factorlevelcount,rowcount,replace = TRUE)
    factorfeature <- paste0('a',vals)
    dta <- cbind(dta,as.factor(factorfeature))
  }
  
  mu <- runif(featurecount)

  goalcol <- makeartificialgoal(dta,mu,sigma,op,noise,randomfeaturecount,
                                factorfeaturecount,factorlevels)
  if (factorgoal) {
    mx <- max(goalcol,na.rm = TRUE)
    for (i in 1:length(goalcol)) {
      lvl <- round((as.numeric(goalcol[i])/mx)*(goallevels - 1)) + 1
      if (!is.na(lvl))
        goalcol[i] <- paste0('a',lvl)
    }
    goalcol <- as.factor(goalcol)
  }
  dta <- cbind(dta,goalcol)
  
  colnames(dta) <- c(paste0('v',1:(numericfeaturecount + factorfeaturecount)),'goal')
  return(dta)
}

testartificial <- function(rowcount,percent,measure,factorgoal = FALSE) {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               rowcount,.25,'add',.0,
                               factorgoal,5,
                               .1)
  if (factorgoal) 
    profile <- makeprofile(dta,'goal',percent,measure = measure,targetlevel = 'a5')
  else
    profile <- makeprofile(dta,'goal',percent,measure = measure)
  
  return(profile)
}



testmtcars <- function(percent,measure) {
  profile<- makeprofile(mtcars,'mpg',percent,measure = measure)
  
  return(profile)
}

testiris <- function(measure) {
  makeprofile(iris,'Species',targetlevel = 'versicolor',measure = measure)
}

setfactors <- function(dta,factorcols) {
  for (colname in factorcols) {
    idx <- which(colnames(dta) == colname) 
    if (length(idx) == 0)
      browser()
    else 
      dta[,idx] <- as.factor(dta[,idx])
  }
  
  return(dta)
}

testhouseprices <- function(percent,measure) {
  dta <- read.csv('Data/houseprices.csv')
  factorcols <- c('MSSubClass','MSZoning','Street','Alley','LotShape','LandContour',
    'Utilities','LotConfig','LandSlope','Neighborhood','Condition1','Condition2','BldgType','HouseStyle',
    'RoofStyle','RoofMatl','Exterior1st','Exterior2nd','MasVnrType',
    'ExterQual','ExterCond','Foundation','BsmtQual','BsmtCond',
    'BsmtExposure','BsmtFinType1', 'BsmtFinType2','Heating','HeatingQC',
    'CentralAir','Electrical','KitchenQual','Functional','Fireplaces',
    'FireplaceQu','GarageType','GarageFinish','GarageQual','GarageCond',
    'PavedDrive','PoolQC','Fence','MiscFeature','YrSold','SaleType','SaleCondition')
  dta <- setfactors(dta,factorcols)
  
  profile <- makeprofile(dta,'SalePrice',percent,measure = measure,ignorena = 'cols')
  return(profile)
}

testdiamonds <- function(percent,measure) {
  dta <- data.frame(ggplot2::diamonds)
  profile <- makeprofile(dta,'price',percent = percent,measure = measure)
  
  return(profile)
}

testwinequality <- function(measure) {
  dta <- read.csv('Data/winequality.csv')
  dta[,ncol(dta)] <- as.factor(dta[,ncol(dta)])
  
  profile <- makeprofile(dta,'quality',targetlevel = '8',measure = measure)
  
  return(profile)
}

testpaddy <- function(percent,measure) {
  dta <- read.csv('Data/paddy.csv')
  factorcols <- c('Agriblock','Variety','Soil.Types','Nursery',
                  'Wind.Direction_D1_D30','Wind.Direction_D31_D60','Wind.Direction_D61_D90')
  dta <- setfactors(dta,factorcols)
  profile <- makeprofile(dta,'yield',percent = percent,measure = measure)
  
  return(profile)
}

testdefault <- function(measure) {
  dta <- read.csv('Data/default.csv')
  factorcols <- c('SEX','EDUCATION','MARRIAGE',
                  'PAY_0','PAY_2','PAY_3','PAY_4','PAY_5','PAY_6',
                  'default')
  dta <- setfactors(dta,factorcols)
  profile <- makeprofile(dta,'default',targetlevel = '1',measure = measure)
 
  return(profile)
}

testtargetnameerror <- function(rowcount,percent,measure,factorgoal = FALSE) {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,FALSE,5,.1)
  profile <- makeprofile(dta,'xxxx')
  
  return(NULL)
}

testtargetnameerror <- function(rowcount,percent,measure,factorgoal = FALSE) {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,FALSE,5,.1)
  profile <- makeprofile(dta,'xxxx')
  
  return(NULL)
}

testtargetnonfactorerror <- function(rowcount,percent,measure,factorgoal = FALSE) {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,FALSE,5,.1)
  profile <- makeprofile(dta,'goal',targetlevel = 'a6')
  
  return(NULL)
}

testtargetlevelerror <- function() {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,TRUE,5,.1)
  profile <- makeprofile(dta,'goal',targetlevel = 'a6')
  
  return(NULL)
}

testmaxsderror <- function() {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,TRUE,5,.1)
  profile <- makeprofile(dta,'goal',maxsd = 0)
  
  return(NULL)
}

testsddeltaerror <- function() {
  dta <- makeartificialdataset(3,3,3,c(1,1,0),5,100,.25,'add',.0,FALSE,5,.1)
  profile <- makeprofile(dta,'goal',sddelta = 0)
  
  return(NULL)
}

testsddeltadifferenceerror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',percent = .1,maxsd = 1,sddelta = 2.5)

  return(NULL)
}

testtoperror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',top = 7)
  
  return(NULL)
}

testbeamsizeerror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',beamsize = 32.1)
  
  return(NULL)
}

testmaxfeatureserror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',maxfeatures = 3.4)
  
  return(NULL)
}

testmeasureerror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',measure = 'xxx')
  
  return(NULL)
}

testweighterror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',measure = 'weighted',weight = -0.1)

  return(NULL)
}

testignorenaerror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',ignorena = 'xxx')
  
  return(NULL)
}

testsigdigitserror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               10000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',sigdigits = 3.1)
  browser()
  
  return(NULL)
}

testinsufficienttargetrowserror <- function() {
  dta <- makeartificialdataset(3,3,
                               3,c(1,1,0),5,
                               1000,.25,'add',.0,
                               FALSE,5,
                               .1)
  profile <- makeprofile(dta,'goal',percent = .002)
  browser()
  
  return(NULL)
}

testinsufficienttargetcolserror<- function() {
  dta <- makeartificialdataset(1,1,
                               1,c(1),5,
                               1000,.25,'add',.0,
                               FALSE,5,
                               .05)
  profile <- makeprofile(dta,'goal',percent = .1,ignorena = 'cols',maxfeatures = 4)
  browser()
  
  return(NULL)
}

testnumeric <- function() {
  percents <- c(.05,.1,.25)
  for (percent in percents) {
    for (measure in measures) {
      print(paste('Test artificial:',percent,measure))
      profile <- testartificial(100000,percent,measure)
      print(profile[1,])
      
      print(paste('Test mtcars:',percent,measure))
      profile <- testmtcars(percent,measure)
      print(profile[1,])
      
      print(paste('Test houseprices:',percent,measure))
      profile <- testhouseprices(percent,measure)
      print(profile[1,])
      
      print(paste('Test diamonds:',percent,measure))
      profile <- testdiamonds(percent,measure)
      print(profile[1,])
      
      print(paste('Test paddy:',percent,measure))
      profile <- testpaddy(percent,measure)
      print(profile[1,])
    }
  }
}

testfactor <- function() {
  for (measure in measures) {
    print(paste('Test artificial factor:',measure))
    profile <- testartificial(100000,.1,measure,TRUE)
    print(profile[1,])
    
    print(paste('Test iris:',measure))
    profile <- testiris(measure)
    print(profile[1,])
    
    print(paste('Test winequality:',measure))
    profile <- testwinequality(measure)
    print(profile[1,])
    
    print(paste('Test default:',measure))
    profile <- testdefault(measure)
    print(profile[1,])
  }
}

testerrors <- function() {
  errortype = 'targetname'
  switch(errortype,
         # argument errors
         'targetname' = testtargetnameerror(),
         'targetfactor' = testtargetnonfactorerror(),
         'targetlevel' = testtargetlevelerror(),
         'maxsd' = testmaxsderror(),
         'sddelta' = testsddeltaerror(),
         'sddeltadifference' = testsddeltadifferenceerror(),
         'top' = testtoperror(),
         'beamsize' = testbeamsizeerror(),
         'maxfeatures' = testmaxfeatureserror(),
         'measure' = testmeasureerror(),
         'weight' = testweighterror(),
         'ignorena' = testignorenaerror(),
         'sigdigits' = testsigdigitserror(),
         # runtime errors
         'targetrows' = testinsufficienttargetrowserror(),
         'targetcols' = testinsufficienttargetcolserror()
  )
}

