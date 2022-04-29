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
# get the columns with the labels for the different treatments
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
            N_weight_after = lengthWithoutNA(weight_kg)) %>% 
  filter(id_plant != 31 & id_plant != 54 & id_plant != 64)
# some plants mysteriously lost weight after 24-5-21
weight_after_means2 <- potW %>% 
  filter(timing == "2_after watering" & date >= as.Date("2021-05-24")) %>%
  filter(id_plant == 31 | id_plant == 54 | id_plant == 64) %>% 
  group_by(id_plant) %>% 
  summarise(weight_after_mean = mean(weight_kg, na.rm = T),
            weight_after_se = s.err.na(weight_kg),
            N_weight_after = lengthWithoutNA(weight_kg))
weight_after_means <- weight_after_means %>% 
  bind_rows(weight_after_means2)
# have a look at the data
#View(weight_after_means)
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
# str(potW)
# View(potW)

labelsSoilPots <- read.csv('phlData/labels_pots_with_soil.csv')
drySoilsOnly <- drySoils %>% filter(id_plant >= 121) %>% 
  left_join(labelsSoilPots, by = 'id_plant')

soilPotW <- left_join(soilPotW, drySoilsOnly, by = 'id_plant')
soilPotW$plant_in_pot <- 'no'
head(soilPotW)
# str(soilPotW)
# View(soilPotW)

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
#(transp)
# make sure the order is what it should look like
# calculate weight loss in between dates
# the ifelse function runs a test and depending on the results assigns a value or another
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
hist(transp$daily_transp)
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
                           lead(transp$weight_kg) - transp$increment_g*0.001, transp$weight_kg)
# B) Control plants from Phyto 1 & 2 on the 6th June -> use estimates of transpiration from 31 May to 3 June
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
transp$weight_kg <- ifelse(is.na(transp$weight_kg) & transp$date == as.Date("2021-05-03")
                           & transp$timing == "1_before watering",
                           lead(transp$weight_kg) - transp$increment_g*0.001, transp$weight_kg)
# exclude daily transpiration rates calculated using estimated weights for further analyses:
transp$daily_transp <- ifelse(transp$estimated_weight_before == 'yes', NA, transp$daily_transp)
transp$daily_transp <- ifelse(transp$date == as.Date('2021-06-07'), NA, transp$daily_transp)
# get rid of a value calculated after a plant measured too early in the day
transp[which(transp$id_plant == 20 & transp$date == as.Date("2021-06-01")), 'daily_transp'] <- NA

write.csv(transp, file ='transp.csv', row.names = F)
# calculate cumulative transpiration 8E) and daily mean E over the entire period (29 or 30 April until harvest date):
transp_summ <- transp %>% 
  group_by(id_plant) %>% 
  summarise(E_cum = sum(increment_g, na.rm = T), ndays = sum(day_incr,  na.rm = T),
            E_rate_mean = mean(daily_transp, na.rm = T), E_rate_se = s.err.na(daily_transp),
            E_rate_n = lengthWithoutNA(daily_transp))

# plot by treatment only pots with plant
plantE <- subset(transp, id_plant <= 120)
plot(plantE$increment_g ~ plantE$date, pch = 19, col = as.factor(plantE$water_treatment))
legend('topright', legend = levels(as.factor(plantE$water_treatment)), pch = 19, bty = 'n',
       col = c('black', 'red'))
# export to excel the file with transpiration data
write.csv(transp, file = 'phlData/trasnpiration_calculations.csv', row.names = F)

#para las hojas LNSC no tenemos datos de peso seco, por lo que hay que estimarlo haciendo una regla de tres con los pesos seco y fresco totales de hojas
#para ello creo la variable est_DW_LNSC
morpho_biomass$est_DW_LNSC <- (morpho_biomass$FW_10LNSC*morpho_biomass$DW_L)*(morpho_biomass$FW_L^-1)

#crear la variable del peso seco total de hojas
morpho_biomass$tot_DW_L <- rowSums(morpho_biomass[, c('est_DW_LNSC', 'DW_L1phl', 'DW_L2phl', 'DW_L3phl', 'DW_10LSLA', 'DW_L')], na.rm = T)

# calculate SLA
morpho_biomass <- morpho_biomass %>% 
  mutate(sla = area_sla_leaves*0.01/morpho_biomass$DW_10LSLA)

#calcular area foliar total de cada planta
morpho_biomass$tot_area_leaves <- morpho_biomass$tot_DW_L*morpho_biomass$sla
#crear data frame solo con id_plant y area foliar total (y poner los nombres bien)
tot_area_leaves_df <-data.frame(morpho_biomass$id_plant,morpho_biomass$tot_area_leaves)

tot_area_leaves_df <- tot_area_leaves_df %>% rename(id_plant = morpho_biomass.id_plant)
tot_area_leaves_df <- tot_area_leaves_df %>% rename(tot_area_leaves = morpho_biomass.tot_area_leaves)

transp2 <- transp %>%
  select(c(1,2,7,8,9,12,13)) %>% 
  filter(!daily_transp == "NA") %>% 
  group_by (id_plant) %>% 
  mutate(day_cum = cumsum(day_incr))

#View(transp2)

transp_and_area <- transp2 %>%
  left_join(tot_area_leaves_df, by = 'id_plant')

####calcular transpiracion diaria por unidad de area foliar (g/cm^2)####

transp_and_area$daily_transp_per_area <- 
  transp_and_area$daily_transp/transp_and_area$tot_area_leaves

transp_and_area <- transp_and_area %>% 
  mutate(daily_E_mol.m2 = (daily_transp/18)/(tot_area_leaves*0.0001))

hist(transp_and_area$daily_transp_per_area)
hist(transp_and_area$daily_E_mol.m2)

#create a variable that combines water and CO2 treatment
transp_and_area$water_co2 <- paste0(transp_and_area$treatment_co2, '_', transp_and_area$water_treatment)

transp_and_area$doy <- yday(transp_and_area$date)

# plot individual raw data per treatment combination:
windows(12, 8)
ggplot(transp_and_area, aes(x = doy, y = daily_E_mol.m2, color = as.factor(id_plant), group = as.factor(id_plant))) +
  geom_line() +
  facet_grid(~water_co2) +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('DOY')

# boxplots of raw data per treatment combination:
# a little cheat to have a boxplot per day
transp_and_area$doy_f <- as.factor(yday(transp_and_area$date))
windows(12, 8)
ggplot(transp_and_area, aes(x = doy_f, y = daily_E_mol.m2)) +
  geom_boxplot() +
  facet_grid(~water_co2) +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')

####Agrupar los daily_transp por tratamientos(co2 y h2o) y dias (day_cum)####

transp_and_area_groups <- transp_and_area %>%
  group_by (treatment_co2, water_treatment, date) %>%
  summarize (E_mean = mean (daily_E_mol.m2, na.rm=T),
             E_sd = sd(daily_E_mol.m2, na.rm=T),
             E_se = s.err.na(daily_E_mol.m2),
             E_n = lengthWithoutNA(daily_E_mol.m2))

# create a variable indicated number of days since start of measurements
transp_and_area_groups <- transp_and_area_groups %>% 
  mutate(n_day = ifelse(treatment_co2 == "ambient", yday(date) - yday(as.Date("2021-04-29")),
                        yday(date) - yday(as.Date("2021-04-30"))))
# now plot:
windows(12, 8)
ggplot(transp_and_area_groups, aes(x = n_day, y = E_mean, shape = water_treatment)) +
  geom_errorbar(aes(ymin = E_mean - E_se, ymax = E_mean + E_se), width = 0.1) +
  geom_line(aes(color = water_treatment)) +
  geom_point(aes(color = water_treatment)) +
  scale_shape_manual(values = c(19, 15)) +
  scale_color_manual(values = c('blue', 'red')) +
  facet_grid(~treatment_co2) +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('Number days since start') +
  theme_classic()