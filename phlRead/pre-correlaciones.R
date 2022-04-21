### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
# you will probably also need
library(readxl)

# download files in your local directory

googledrive::drive_download(file = "morpho_merged",
                            path = "C:/calculostfg/datostfg/morpho_merged.csv", overwrite = TRUE)
googledrive::drive_download(file = "sampling_cleaned",
                            path = "C:/calculostfg/datostfg/sampling_clean.csv", overwrite = TRUE)
googledrive::drive_download(file = "area_SLA_photos",
                            path = "C:/calculostfg/datostfg/area_SLA_photos.csv", overwrite = TRUE)

# read the data from the downloaded files
morpho <- read.csv('C:/calculostfg/datostfg/morpho_merged.csv')
# the file sampling_clean and sla do NOT have the columns campaign, phyto, etc.
sampling <- read.csv('C:/calculostfg/datostfg/sampling_clean.csv')
sla <- read.csv("C:/calculostfg/datostfg/area_SLA_photos.csv")

### organize and clean the data ###

# convert records that are 9999 into NA's
morpho[which(morpho$height_cm >= 999), c("height_cm", "stem_width_1_cm", "stem_width_2_cm", "branching")] <- NA
morpho[which(morpho$date_f == 99999999), 'date_f'] <- NA
morpho[which(morpho$n_days == 9999), 'n_days'] <- NA
# give a different name to column "OBS"
morpho <- morpho %>% rename(OBS_morpho = OBS)
# check the file
#View(morpho)
#str(morpho)

# similar approach for the object sampling
sampling[which(sampling$long_Shist == 9999), c('long_Shist', 'diam_Shist', 'FW_Shist')] <- NA
sampling[which(sampling$long_Sphl == 9999), c('long_Sphl', 'diam_Sphl')] <- NA
sampling[which(sampling$SW_L1phl == 9999),
         c(paste0('FW_L', 1:3, 'phl'), paste0('SW_L', 1:3, 'phl'), paste0('DW_L', 1:3, 'phl'))] <- NA
sampling[which(sampling$FW_10LNSC == 9999), 'FW_10LNSC'] <- NA
sampling[which(sampling$FW_rootNSC == 9999), 'FW_rootNSC'] <- NA
sampling[which(sampling$FW_root == 9999), c('FW_root', 'DW_root')] <- NA
sampling[which(sampling$FW_ss_soil == 9999), c('FW_ss_soil', 'DW_ss_soil')] <- NA
sampling[which(sampling$FW_soil_pot_kg == 9999), c('FW_soil_pot_kg', 'DW_soil', 'W_pot')] <- NA
sampling[which(sampling$FW_Sphl == 9999), 'FW_Sphl'] <- NA
sampling[which(sampling$FW_SNSC == 9999), 'FW_SNSC'] <- NA
# rename column "ID_plant"
sampling <- sampling %>% rename(id_plant = ID_plant)
#check the file
#View(sampling)
#str(sampling)
# same for SLA area
sla[which(sla$area_sla_leaves == 999999), 'area_sla_leaves'] <- NA
sla <- sla %>% rename(id_plant = ID_plant)

# merge files into one
# Important the resulting file will only have the harvested plants
morpho_biomass <- sampling %>%
  left_join(sla, by = 'id_plant') %>% 
  left_join(morpho, by = 'id_plant')

#calculate the average diameters
morpho_biomass$diam_i_avg <- rowMeans(morpho_biomass[, c('initial_stem_width_1_cm', 'initial_stem_width_2_cm')])
morpho_biomass$diam_f_avg <- rowMeans(morpho_biomass[, c('stem_width_1_cm', 'stem_width_2_cm')])

# calculate specific leaf area in g cm-2
morpho_biomass$sla <- morpho_biomass$area_sla_leaves*0.01/morpho_biomass$DW_10LSLA

## export merged file to csv files (change file location accordingly)
write.csv(morpho_biomass, file = 'C:/calculostfg/datostfg/morpho_biomass.csv', row.names = F)
