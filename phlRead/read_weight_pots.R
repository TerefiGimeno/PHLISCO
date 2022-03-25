### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(doBy)
# you will probably also need
library(readxl)

### run script to download, clean and process morpho and biomass data
source('phlRead/read_clean_morpho_biomass.R')
# get the columns with the different treatments
labels <- morpho[, c('id_plant', 'phyto', 'treatment_co2', 'treatment_h2o', 'water_treatment')]

#### read and pre-process the data ####
googledrive::drive_download(file = "weight_plants_clean",
                            path = "phlData/weight_plants_clean.csv", overwrite = TRUE)
googledrive::drive_download(file = "Weight_soils",
                            path = "phlData/weight_dry_soils.csv", overwrite = TRUE)
googledrive::drive_download(file = "labels_pots_with_soil",
                            path = "phlData/labels_pots_with_soil.csv", overwrite = TRUE)
potW <- read.csv("phlData/weight_plants_clean.csv")
potW[which(potW$weight_kg == 999), 'weight_kg'] <- NA
# rename, get rid of extra readings (plants 1 and 100 were only weighted once)
potW <- potW %>% rename(id_plant = plant_ID) %>% 
  filter(id_plant != 1 & id_plant != 100)
# make R understand dates
potW$date <- as.Date(ymd(as.character(potW$date)))
# make separate objects for pots with and without plants
soilPotW <- potW %>% filter(id_plant >= 121)
potW <- potW %>% filter(id_plant <= 120)

# read and process the file with the final dry weights of the soils
drySoils <- read.csv('phlData/weight_dry_soils.csv')
drySoils$dryW_kg <- rowSums(drySoils[, paste0('weight_', 1:4)], na.rm =T)*0.001
drySoils <- drySoils %>% select(c(ID, dryW_kg)) %>%
  rename(id_plant = ID)
# dry soils from pots with plants
drySoilsWithPlant <- drySoils %>% filter(id_plant <= 120) %>% 
  left_join(labels, by ='id_plant')

# merge objects
potW <- left_join(potW, drySoilsWithPlant, by = 'id_plant')
potW$plant_in_pot <- 'yes'
head(potW)
str(potW)
View(potW)

labelsSoilPots <- read.csv('phlData/labels_pots_with_soil.csv')
drySoilsOnly <- drySoils %>% filter(id_plant >= 121) %>% 
  left_join(labelsSoilPots, by = 'id_plant')

soilPotW <- left_join(soilPotW, drySoilsOnly, by = 'id_plant')
soilPotW$plant_in_pot <- 'no'
head(soilPotW)
str(soilPotW)
View(soilPotW)

# now merge the biomass data using similar code
# this time, let's take fresh and dry root weight into account

# put everything back into one database and get rid of certain columns
transp <- bind_rows(potW, soilPotW) %>% select(-c(water_plate, OBS_weight, treatment_h2o))
head(transp)
str(transp)

# order the file
transp <- doBy::orderBy(~ id_plant + date + timing, data = transp)
View(transp)
# make sure the order is what it should look like
# calculate weight loss in between dates
# the ifelse function runs a test and dependign on the results assings a value or another
# in this case the conditions (test) that have to be met are:
# (1) that reading are consecutive for the same plant and
# (2) the weight was measured before adding water
# this way we can calculate the increments for ALL pots (with and without plant) and from ALL treatments
# tip: the function lag looks at the value of the preceding line
transp$increment_g <- ifelse(test = transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                           yes = (lag(transp$weight_kg) - transp$weight_kg)*1000, no = NA)
hist(transp$increment_g)
# there are five negative estimates of transpiration
subset(transp, increment_g < 0)
# these are likely due to typos in the database that are not evident and  cannot be fixed
transp[which(transp$increment_g < 0), 'increment_g'] <- NA
# there is one reading that looks abnormably high and is likely a typo too
subset(transp, increment_g > 900)
transp[which(transp$increment_g > 900), 'increment_g'] <- NA
hist(transp$increment_g)
# calculate the number of days in between weight measurements
# the function yday (from lubridate) calculated the number of the day within a year from 1 to 365
transp$day_incr <- ifelse(transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                          yday(transp$date) - yday(lag(transp$date)), NA)

# plot by treatment only plots with plant
plantE <- subset(transp, id_plant <= 120)
plot(plantE$increment_g ~ plantE$date, pch = 19, col = as.factor(plantE$water_treatment))
legend('topright', legend = levels(as.factor(plantE$water_treatment)), pch = 19, bty = 'n',
       col = c('black', 'red'))
# export to excel the file with transpiration data
write.csv(transp, file = 'phlData/trasnpiration_calculations.csv', row.names = F)
