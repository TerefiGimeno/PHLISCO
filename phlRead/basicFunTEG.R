max2 <- function(x){
  sb <- sort(x)[length(sort(x))-1]
  return(sb)
}

max.na <- function(x){
  mm <- max(x, na.rm = T)
  return(mm)
}

median.na <- function(x){
  mm <- median(x, na.rm = T)
  return(mm)
}

min.na <- function(x){
  mm <- min(x, na.rm=T)
  return(mm)
}

countNA <- function(x){
  l <- length(x)-length(which(is.na(x)))
  return(l)
}

lengthWithoutNA <- function(x){
  l <- length(which(!is.na(x)))
  return(l)
}

basalArea <- function(DBH){
  BA <- pi*(DBH/2)^2
  return(BA)
}
rmDup <- function(dfr, whichvar){
  dfr <- dfr[!duplicated(dfr[,whichvar]),]
  return(dfr)
}
s.err <- function(x){sd(x)/sqrt(length(x))}

s.err.na <- function(x){sd(x, na.rm = TRUE)/sqrt(lengthWithoutNA(x))}

coef.var <- function(x){sd(x)/mean(x)}

calcVPD <- function(temp, RH){0.61365 * exp(17.502 * temp/(240.97 + temp)) * (1 -(RH/100))}

sum.na <- function(x){sum(x, na.rm = TRUE)}

mean.na <- function(x){mean(x, na.rm = T)}