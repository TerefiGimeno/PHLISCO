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
potW <- potW %>% rename(id_plant = plant_ID)
# make R understand dates
potW$date <- as.Date(ymd(as.character(potW$date)))

drySoils <- read.csv('phlData/weight_dry_soils.csv')
drySoils$dryW_kg <- rowSums(drySoils[, paste0('weight_', 1:4)], na.rm =T)*0.001
drySoils <- drySoils %>% select(c(ID, dryW_kg)) %>% 
  rename(id_plant = ID) %>% 
  left_join(labels, by ='id_plant')

potW <- left_join(potW, drySoils, by = 'id_plant')
labelsSoilPots <- read.csv('phlData/labels_pots_with_soil.csv')
potW <- left_join(potW, labelsSoilPots, by = 'id_plant')
