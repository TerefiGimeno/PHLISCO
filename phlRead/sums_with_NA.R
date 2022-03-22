# create a blanck data frame
df <- data.frame(row.names = 1:10)
# add variables with random numbers to the data frame
df$A <- rnorm(10, 0, 1)
df$B <- rnorm(10, 0, 1)
# add a column with NA's
df$C <- c(rep(NA, 10))
# calculate the sum of of A + B + C for each row getting rid of NA's
df$theSum <- rowSums(df[, c('A', 'B', 'C')], na.rm = T)