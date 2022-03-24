### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
# you will probably also need
library(readxl)

### run script to download, clean and process morpho and biomass data
source('phlRead/read_clean_morpho_biomass.R')
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
# rename, get rid of extra readings
potW <- potW %>% rename(id_plant = plant_ID) %>% 
  filter(id_plant != 1 & id_plant != 100)
# make R understand dates
potW$date <- as.Date(ymd(as.character(potW$date)))
# make separate objects for pots with and without plants
soilPotW <- potW %>% filter(id_plant >= 121)
potW <- potW %>% filter(id_plant <= 120)

drySoils <- read.csv('phlData/weight_dry_soils.csv')
drySoils$dryW_kg <- rowSums(drySoils[, paste0('weight_', 1:4)], na.rm =T)*0.001
drySoils <- drySoils %>% select(c(ID, dryW_kg)) %>%
  rename(id_plant = ID)
# dry soils from pots with plants
drySoilsWithPlant <- drySoils %>% filter(id_plant <= 120) %>% 
  left_join(labels, by ='id_plant')

potW <- left_join(potW, drySoilsWithPlant, by = 'id_plant')
head(potW)
str(potW)
View(potW)

labelsSoilPots <- read.csv('phlData/labels_pots_with_soil.csv')
drySoilsOnly <- drySoils %>% filter(id_plant >= 121) %>% 
  left_join(labelsSoilPots, by = 'id_plant')

soilPotW <- left_join(soilPotW, drySoilsOnly, by = 'id_plant')
head(soilPotW)
str(soilPotW)
View(soilPotW)

# put everything back into one database
transp <- bind_rows(potW, soilPotW) %>% select(-c(water_plate, OBS_weight, treatment_h2o))
head(transp)
str(transp)

# order the file
transp <- doBy::orderBy(~ id_plant + date + timing, data = transp)
View(transp)
# make sure the order is what it should look like
# calculate weight loss in between dates
transp$increment_g <- ifelse(transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                           (lag(transp$weight_kg) - transp$weight_kg)*1000, NA)
hist(transp$increment_g)
# there are five negative estimates of transpiration
subset(transp, increment_g < 0)
# these are likely due to typos in the database that are not evident and I don't think we can fix
transp[which(transp$increment_g < 0), 'increment_g'] <- NA
hist(transp$increment_g)
# calculate the number of days in between weight measurements
transp$day_incr <- ifelse(transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                          yday(transp$date) - yday(lag(transp$date)), NA)
                          
