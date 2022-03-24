#### read the data ####

# download files in your local directory
# OBS! We are only downloading the first sheet and saving it as a *.csv
# where it says "phlData" the name of the folder where you will store your data
# the first time you use this package you will be promted with an authorization
# it is important to add the command overwrite = TRUE in case anything change!
googledrive::drive_download(file = "morpho_merged",
                            path = "phlData/morpho_merged.csv", overwrite = TRUE)
googledrive::drive_download(file = "sampling_cleaned",
                            path = "phlData/sampling_clean.csv", overwrite = TRUE)
googledrive::drive_download(file = "area_SLA_photos",
                            path = "phlData/area_SLA_photos.csv", overwrite = TRUE)
# do NOT open these files with excel
# if you want to open and explore these files with excel, make a copy and open the copy

# read the data from the downloaded files
# if you continue to have trouble reading *.csv files, download the files as *.xls
morpho <- read.csv('phlData/morpho_merged.csv')
# the file sampling_clean and sla do NOT have the columns campaign, phyto, etc.
sampling <- read.csv('phlData/sampling_clean.csv')
sla <- read.csv("phlData/area_SLA_photos.csv")
# explore the data
# make sure that numeric variables are identified as such
# descriptions of variables and their units can be found on the file in google drive

### organize and clean the data ###

# convert records that are 9999 into NA's
morpho[which(morpho$height_cm >= 999), c("height_cm", "stem_width_1_cm", "stem_width_2_cm", "branching")] <- NA
morpho[which(morpho$date_f == 99999999), 'date_f'] <- NA
morpho[which(morpho$n_days == 9999), 'n_days'] <- NA
# give a different name to column "OBS"
morpho <- morpho %>% rename(OBS_morpho = OBS)
# check the file

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

# same for SLA area
sla[which(sla$area_sla_leaves == 999999), 'area_sla_leaves'] <- NA
sla <- sla %>% rename(id_plant = ID_plant)

# merge files into one
# Important the resulting file will only have the harvested plants
morpho_biomass <- sampling %>%
  left_join(sla, by = 'id_plant') %>% 
  left_join(morpho, by = 'id_plant')
# check the file
