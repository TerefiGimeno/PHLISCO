### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(doBy)
# you will probably also need
library(readxl)

# read script with a few custom function that I use a lot
source('phlRead/basicFunTEG.R')

### run script to download, clean and process morpho and biomass data
source('phlRead/read_clean_morpho_biomass.R')
# get the columns with the lables for the different treatments
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

# Gap fill missing data -> Step 1: fill in records of missing data "after watering"
# withe average of the weight of the corresponding plant

# calculate averages of weight per plant after watering (only pots with plant)
weight_after_means <- potW %>% 
  filter(timing == "2_after watering" & id_plant <= 120) %>% 
  group_by(id_plant) %>% 
  summarise(weight_after_mean = mean(weight_kg, na.rm = T),
            weight_after_se = s.err.na(weight_kg),
            N_weight_after = lengthWithoutNA(weight_kg))
# have a look at the data
View(weight_after_means)
# small se per plot and we have at least 5 measurements per plot
# merge with potW
potW <- potW %>%
  left_join(weight_after_means[, c('id_plant', 'weight_after_mean')], by = 'id_plant')
# gap fill
potW$estimated_weight_after <- ifelse(is.na(potW$weight_kg) & potW$timing == "2_after watering",
                                      'yes', 'no')
potW$weight_kg <- ifelse(is.na(potW$weight_kg) & potW$timing == "2_after watering",
                         potW$weight_after_mean, potW$weight_kg)

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
# this time, let's incorporate root fresh weight into the calculations

# for now, we leave aside the data from pots without plants
# put everything back into one database and get rid of certain columns
# transp <- bind_rows(potW, soilPotW) %>% select(-c(water_plate, OBS_weight, treatment_h2o))
# head(transp)
# str(transp)

transp <- potW %>% select(-c(water_plate, OBS_weight, treatment_h2o, weight_after_mean))
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
transp$increment_g <- ifelse(transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                           (lag(transp$weight_kg) - transp$weight_kg)*1000, NA)
hist(transp$increment_g)
# # there are two negative estimates of transpiration both from pots without plant
# subset(transp, increment_g < 0)
# # these are likely due to typos in the database that are not evident and  cannot be fixed
# transp[which(transp$increment_g < 0), 'increment_g'] <- NA
# # there is one reading that looks abnormably high and is likely a typo too
# subset(transp, increment_g > 900)
# transp[which(transp$increment_g > 900), 'increment_g'] <- NA
# hist(transp$increment_g)

# calculate the number of days in between weight measurements
# the function yday (from lubridate) calculated the number of the day within a year from 1 to 365
transp$day_incr <- ifelse(transp$id_plant - lag(transp$id_plant) == 0 & transp$timing != "2_after watering",
                          yday(transp$date) - yday(lag(transp$date)), NA)
# calculate rate of daily transpiration
transp <- transp %>% mutate(daily_transp = increment_g/day_incr)

# Gap fill missing data -> Step 2: estimate weight of pots BEFORE watering:
transp$estimated_weight_before <- ifelse(is.na(transp$weight_kg) & transp$timing == "1_before watering",
                                         "yes", "no")
# A) Plants from Phyto 2 on the 3rd of May -> use estimates of transpiration from the 3rd to the 6th May
phyto2_20210506 <- transp %>% 
  filter(phyto == 2 & date == as.Date("2021-05-06") & timing == "1_before watering") %>% 
  select(c(id_plant, timing, daily_transp)) %>% 
  rename(daily_transp_est_20210506 = daily_transp)
transp <- transp %>% 
  left_join(phyto2_20210506, by = c('id_plant', 'timing'))
# gap fill
transp$increment_g <- ifelse(is.na(transp$weight_kg) & transp$date == as.Date("2021-05-03")
                             & transp$timing == "1_before watering",
                           transp$daily_transp_est_20210506 * transp$day_incr, transp$increment_g)
transp$weight_kg <- ifelse(is.na(transp$weight_kg) & transp$date == as.Date("2021-05-03")
                           & transp$timing == "1_before watering",
                           lead(transp$weight_kg) - transp$day_incr*0.001, transp$weight_kg)
# B) Control plants from Phyto 1 & 2 on the 6th May -> use estimates of transpiration from 31 May to 3 June
control_20210603 <- transp %>% 
  filter(water_treatment == "control" & date == as.Date("2021-06-03") & timing == "1_before watering") %>% 
  select(c(id_plant, timing, daily_transp)) %>% 
  rename(daily_transp_est_20210603 = daily_transp)
transp <- transp %>% 
  left_join(control_20210603, by = c('id_plant', 'timing'))
# gap fill
transp$increment_g <- ifelse(is.na(transp$weight_kg) & transp$date == as.Date("2021-06-06")
                             & transp$timing == "1_before watering",
                             transp$daily_transp_est_20210603 * transp$day_incr, transp$increment_g)
transp$weight_kg <- ifelse(is.na(transp$weight_kg) & transp$date == as.Date("2021-05-03"),
                           lead(transp$weight_kg) - transp$day_incr*0.001, transp$weight_kg)
write.csv(transp, file ='transp.csv', row.names = F)

# plot by treatment only plots with plant
plantE <- subset(transp, id_plant <= 120)
plot(plantE$increment_g ~ plantE$date, pch = 19, col = as.factor(plantE$water_treatment))
legend('topright', legend = levels(as.factor(plantE$water_treatment)), pch = 19, bty = 'n',
       col = c('black', 'red'))
# export to excel the file with transpiration data
write.csv(transp, file = 'phlData/trasnpiration_calculations.csv', row.names = F)
