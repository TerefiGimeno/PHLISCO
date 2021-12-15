library(tidyverse)
# create a vector with all the zip files
# enter your the name of the fodler where you have the data accordingly
zipFileNames <- paste0("phlData/AquaZip/" , list.files('phlData/AquaZip/'))

# create a vector with only the names of the *.csv (what we want)
csvFileNames <- map(zipFileNames, ~ unzip(zipfile = .x, list = T)[1, 1])

# extract the files onto a newly created folder within the data folder

# with tidyverse
map(zipFileNames, csvFileNames, ~unzip(zipfile = .x, files = .y, exdir = 'phlData/AquaUnzipped'))
# doesn't work, I try
walk(zipFileNames, csvFileNames, ~unzip(zipfile = .x, files = .y, exdir = 'phlData/AquaUnzipped'))
# doesn't work either! Don't know why

# I do it the old way
for (i in 1:length(zipFileNames)){
  unzip(zipfile = zipFileNames[i], file = csvFileNames[[i]], exdir = 'phlData/AquaUnzipped')
}
