### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
# you will probably also need
library(readxl)

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
str(morpho)
str(sampling)
str(sla)

### organize and clean the data ###

# convert records that are 9999 into NA's
morpho[which(morpho$height_cm >= 999), c("height_cm", "stem_width_1_cm", "stem_width_2_cm", "branching")] <- NA
morpho[which(morpho$date_f == 99999999), 'date_f'] <- NA
morpho[which(morpho$n_days == 9999), 'n_days'] <- NA
# give a different name to column "OBS"
morpho <- morpho %>% rename(OBS_morpho = OBS)
# check the file
View(morpho)
str(morpho)
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
View(sampling)
str(sampling)
# same for SLA area
sla[which(sla$area_sla_leaves == 999999), 'area_sla_leaves'] <- NA
sla <- sla %>% rename(id_plant = ID_plant)

# merge files into one
# Important the resulting file will only have the harvested plants
morpho_biomass <- sampling %>%
  left_join(sla, by = 'id_plant') %>% 
  left_join(morpho, by = 'id_plant')
# check the file
View(morpho_biomass)
str(morpho_biomass)

### examples of small operations ####

# calculate the mean of the two measured diameters on the initial date
# first check the values
windows(12, 8)
par(mfrow=c(1,2))
hist(morpho_biomass$initial_stem_width_1_cm)
hist(morpho_biomass$initial_stem_width_2_cm)
# loosk good, let's calculate the average
morpho_biomass$diam_i_avg <- rowMeans(morpho_biomass[, c('initial_stem_width_1_cm', 'initial_stem_width_1_cm')])

# calculate specific leaf area in g cm-2
morpho_biomass$sla <- morpho_biomass$area_sla_leaves*0.01/morpho_biomass$DW_10LSLA
# there is one value that is really high!

### example of linear regression

# create and object with the results of the linear regression
# check the distribution of the predictor and response variable
windows(12, 8)
par(mfrow = c(1, 2))
hist(morpho_biomass$initial_height_cm)
hist(morpho_biomass$diam_i_avg)
# looks good
mod <- lm(initial_height_cm ~ diam_i_avg, data = morpho_biomass)
# look at the results
summary(mod)
# there is a significant (p = 0.004) positive relationship between height and diamter at the begining of the experiment
# height increases by 10.4 (se = 3.5) cm for every 1 cm increase in diameter at the base
# this relationship is weak (r2 = 0.09)
# check the linear regression assumptions
# normal distribution of variables (besides histograms)
shapiro.test(morpho_biomass$diam_i_avg)
shapiro.test(morpho_biomass$initial_height_cm)
# the relationship between the data is linear: no evident trends
plot(mod, 1)
# homogeneity of variance: flat line
plot(mod, 3)
# normality of residuals: lines fall within the 1:1 line
plot(mod, 2)
# bonus: outliners and high leverage points
# outliers have standardize residuals > 3
# high leverage points: extreme predictors
plot(mod, 5)
# plot all at once:

windows(12, 8)
par(mfrow=c(2,2))
plot(mod)

# let's plot it
windows(12, 8)
par(mfrow = c(1, 1))
plot(morpho_biomass$initial_height_cm ~ morpho_biomass$diam_i_avg, pch = 19, 
     ylab = 'Height (cm)', xlab = 'Diameter (cm)')
# add regression line
abline(mod)
# the same plot with ggplot with confidence interval
windows(10, 10)
ggplot(morpho_biomass, aes(x = diam_i_avg, y = initial_height_cm)) +
  geom_point() +
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  xlab('Diameter (cm)') +
  ylab('Height (cm)') +
  theme_classic()

### export merged file to csv files (change file location accordingly)
write.csv(morpho_biomass, file = 'phlOutput/morpho_biomass.csv', row.names = F)

### scripts from Monday 14-March-2022 ####

morpho <- read_excel(path = 'phlData/morpho_merged.xlsx', sheet = "Sheet1")
str(morpho)
#`pintar histograma de altura`
hist(morpho$height_cm)
morpho[1:20, 1:3]
morpho$height_cm[1:20]
View(morpho[1:20, 'date_i', 'date_f'])
morpho[which(morpho$height_cm >= 999),
       c("height_cm", "stem_width_1_cm", "stem_width_2_cm", "branching")] <- NA
morpho$diam_i_avg <- rowMeans(morpho[, c('initial_stem_width_1_cm', 'initial_stem_width_2_cm')], na.rm = T)
morpho$diam_f_avg <- rowMeans(morpho[, c('stem_width_1_cm', 'stem_width_2_cm')], na.rm = T)
morpho$inc_ba_cm2 <- pi*0.25*(morpho$diam_f_avg^2 - morpho$diam_i_avg^2)

mod <- lm(height_cm ~ diam_f_avg, data = morpho)
summary(mod)
plot(morpho$height_cm ~ morpho$diam_f_avg)
abline(mod)

vec <- c(1,2,3,4)
length(vec)

mean(vec)
vecNA <- c(1,2,3,4,NA,NA)
length(vecNA)
sum(vecNA, na.rm = T)
mean(vecNA, na.rm = T)
is.na(vec)
is.na(vecNA)
which(is.na(vecNA))
which(is.na(vec))
length(vecNA) 
length(vecNA) - length(which(is.na(vecNA)))

library(tidyverse)
plantVol <- read.csv('phlData/plant_vol.csv')
plantVol <- plantVol %>% 
  mutate(volInc_mm3 = DAYS_diff_vol_corrections * 1000) %>% 
  mutate(volInc_lgTr = log(volInc_mm3 + 1))
windows(24, 12)
par(mfrow = c(1, 2))
hist(plantVol$DAYS_diff_vol_correction,
     main = 'Increment in cm3 day -1', xlab = 'values')
hist(plantVol$volInc_lgTr, main = 'log(Increment in mm3 day-1)', xlab = 'values')
