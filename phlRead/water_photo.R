### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(readxl)
library(dplyr)
library(openxlsx)

### Sampling ####

#Read data from google drive
googledrive::drive_download(file = "sampling_cleaned",
                            path = "phlData/sampling_clean.csv", overwrite = TRUE)
#Create a object from csv                            
sampling <- read.csv('phlData/sampling_clean.csv')
str(sampling)


### organize and clean the data ###
sampling[which(sampling$long_Shist == 9999), c('long_Shist', 'diam_Shist', 'FW_Shist')] <- NA
sampling[which(sampling$long_Sphl == 9999), c('long_Sphl', 'diam_Sphl')] <- NA
sampling[which(sampling$SW_L1phl == 9999),
         c(paste0('FW_L', 1:3, 'phl'), paste0('SW_L', 1:3, 'phl'), paste0('DW_L', 1:3, 'phl'))] <- NA
sampling[which(sampling$FW_10LNSC == 9999), 'FW_10LNSC'] <- NA
sampling[which(sampling$FW_rootNSC == 9999), 'FW_rootNSC'] <- NA
sampling[which(sampling$FW_root == 9999), c('FW_root', 'DW_root')] <- NA
sampling[which(sampling$FW_ss_soil == 9999), c('FW_ss_soil', 'DW_ss_soil')] <- NA
sampling[which(sampling$FW_soil_pot_kg == 9999), c('FW_soil_pot_kg', 'DW_soil', 'W_pot')] <- NA

# rename column "ID_plant"
sampling <- sampling %>% rename(id_plant = ID_plant)

#check the file
View(sampling)
str(sampling)

#Add column of initial date of the experiment and identifing like a date
sampling$initial_date<-lubridate::ymd(20210420)
view(sampling$initial_date)

#Add column of sampling date of the sample and identifing like a date
sampling$sampling_date<-lubridate::ymd(sampling$sampling_date)
view(sampling$sampling_date)
 
#Calculate the number of days since the initial moment of the experiment
sampling$tiempo <- (sampling$sampling_date-sampling$initial_date)
view(sampling$tiempo)
structure(sampling$tiempo)

#Calculate water content (fw-dw/dw) for each soil sub-sample pot
sampling$WC_ss <- ((sampling$FW_ss_soil-sampling$DW_ss_soil)
                   /sampling$DW_ss_soil)*100
view(sampling$WC_ss)

#Calculate water content (fw-dw/dw) for each soil-sample pot
sampling$FW_s <- ((sampling$FW_soil_pot_kg*1000)-sampling$W_pot)
# do not add a column that is the same as another one
# sampling$DW_s <- (sampling$DW_soil)
# remove extra parenthesis
sampling$WC_s <- ((sampling$FW_s-sampling$DW_soil)/sampling$DW_soil)*100
view(sampling$WC_s)

#Merged  WC_ss y WC_s
sampling <- sampling %>% 
  mutate(WC = ifelse(is.na(WC_ss) , WC_s, WC_ss))
view(sampling$WC)


###GAS EXCHANGE####


#Comandos para descargar un archivo especifico desde google drive
googledrive::drive_download(file = "gxPHLISCO.xlsx",
                            path = "phlData/gxPHLISCO.xlsx", overwrite = TRUE)

#Comando para crear un data frame desde un archivo especifico local
gas_x <- read_xlsx (file.choose('gxPHLISCO.xlsx'))
# do not keep the labels
gas_x <- gas_x %>% select(-c(phyto, treatment_co2, treatment_h2o, ndays_water))
str(gas_x)


#Cambiando el formato de fecha para que lo entienda R
gas_x$date_gx<-lubridate::ymd(gas_x$date)
str(gas_x$date_gx)
gas_x$HHMMSS<-lubridate::hms(gas_x$HHMMSS)
str(gas_x$HHMMSS)

#Preparando variables de Fotosintesis y conductancia estomatica de H20
#Ver todos los valores < 0 de Conductancia del dataframe gas_x
View(subset(gas_x,Cond < 0))
#Asignar NA a todos los valores < 0 de Conductacia 
gas_x$Cond[which(gas_x$Cond < 0)] <- NA #Por el momento pero algo hay que hacer
#Comprobar que la accion anterior corrio bien 
View(gas_x[which(is.na(gas_x$Cond)), ])


#Remover tratamiento "moderate drought"
#gas_x <-gas_x %>% 
#  filter(treatment_h2o!="mod_dro")


# no need to this again: remove lines

#Add column of sampling date of the sample and identifing like a date
# gas_x$date<-lubridate::ymd(gas_x$date)


###WATER POTENTIALS####

#Comandos para descargar un archivo especifico desde google drive
googledrive::drive_download(file = "Water_potential",
                            path = "phlData/water_potential.csv", overwrite = TRUE)

#Create a object from csv                            
wp <- read.csv("phlData/water_potential.csv")
str(wp)

# convert 9999 to NA's
wp[which(wp$wp_mpa >= 100), 'wp_mpa'] <- NA

# create a variable to identify the time of the day:
wp <- wp %>% mutate(timing = ifelse(time <= 900, 'wp_predawn', 'wp_midmorning'))

#Promedio por ID#
# AND TIMING AND DATE!!!
# also for now, discard those from "drought test" and measurements prior to the campaigns
wp_sum <- wp %>%
  filter(treatment_h2o != "drought test") %>% 
  filter(treatment_h2o != "drought test WATERED") %>%
  filter(date >= 20210504) %>% 
  group_by(id_plant, date, timing) %>% 
  summarise(wp_mpa_mean = mean(wp_mpa, na.rm = TRUE)) %>% 
  pivot_wider(names_from = timing, values_from = wp_mpa_mean) %>% 
  rename(date_wp = date)

####LRWC####

source('phlRead/basicFunTEG.R')

#morpho <- read.csv('data_inv/morpho_biomass.csv')
# you don't need to read a new dataset, the data to calculate LRWC is in sampling:
morpho <- sampling
morpho$leaf1RWC <- (morpho$FW_L1phl - morpho$DW_L1phl)/(morpho$SW_L1phl - morpho$DW_L1phl)
morpho$leaf2RWC <- (morpho$FW_L2phl - morpho$DW_L2phl)/(morpho$SW_L2phl - morpho$DW_L2phl)
morpho$leaf3RWC <- (morpho$FW_L3phl - morpho$DW_L3phl)/(morpho$SW_L3phl - morpho$DW_L3phl)
# have a look at raw values
windows(12, 8)
par(mfrow = c(1, 3))
hist(morpho$leaf1RWC)
hist(morpho$leaf2RWC)
hist(morpho$leaf3RWC)
# transform values above 100% and below 50% into NA's
morpho[which(morpho$leaf1RWC > 1 | morpho$leaf1RWC < 0.5), 'leaf1RWC'] <- NA
morpho[which(morpho$leaf2RWC > 1 | morpho$leaf2RWC < 0.5), 'leaf2RWC'] <- NA
morpho[which(morpho$leaf3RWC > 1 | morpho$leaf3RWC < 0.5), 'leaf3RWC'] <- NA


#Promedio de LRWC para cada planta basado en mediciones de 3 de sus hojas 
morpho <- morpho %>%
  mutate(leafRWCmean = apply(.[c(paste0('leaf', 1:3, 'RWC'))], 1, mean.na)) %>%
  mutate(leafRWCse = apply(.[c(paste0('leaf', 1:3, 'RWC'))], 1, s.err.na))
with(morpho, plot(leafRWCse ~ leafRWCmean))
# do not use these samples
morpho[which(is.na(morpho$leaf1RWC)), c('id_plant', 'phyto', 'water_treatment', 'date_f', 
                                        'FW_L1phl', 'SW_L1phl', 'DW_L1phl', 'leaf1RWC')]
morpho[which(is.na(morpho$leaf2RWC)), c('id_plant', 'phyto', 'water_treatment', 'date_f', 
                                        'FW_L2phl', 'SW_L2phl', 'DW_L2phl', 'leaf2RWC')]
morpho[which(is.na(morpho$leaf3RWC)), c('id_plant', 'phyto', 'water_treatment', 'date_f', 
                                        'FW_L3phl', 'SW_L3phl', 'DW_L3phl', 'leaf3RWC')]
# have a look at how leaf rwc evolves over time in the different treatments
hist(morpho$leafRWCmean)

### Merge databases and add lables ####

# do NOT use any other database for the labels of id_plants other than "morpho_merged"
# (this is the one that Ane doubled and tripled checked):
googledrive::drive_download(file = "morpho_merged",
                            path = "phlData/morpho_merged.csv", overwrite = TRUE)
morpho_big <- read.csv('phlData/morpho_merged.csv')

# sampleList <- read.csv('data_inv/summary_sampled_plants_long.csv')
# sampleList <- sampleList %>% rename(id_plant = ID_plant)
# morpho <- left_join(morpho, sampleList[, c('N_days_w', 'id_plant', 'campaign')], by = 'id_plant')
morpho_big$treatment_co2 <- ifelse(morpho_big$phyto == 1, 'elevated', 'ambient')
labels <- morpho_big[, c('id_plant', 'phyto', 'treatment_co2', 'treatment_h2o', 'water_treatment')]

# leafRWC <- morpho %>% 
#   select(c(id_plant, N_days_w, campaign.x, treatment_co2, treatment_h2o, leaf1RWC, leaf2RWC, leaf3RWC)) %>% 
#   reshape2::melt(id.vars = c('id_plant', 'N_days_w', 'campaign.x', 'treatment_co2', 'treatment_h2o'))
# names(leafRWC)[7] <- 'rwc'
# leafRWC$leafID <- substr(leafRWC$variable, 5, 5)
# leafRWC <- leafRWC %>% select(-c(variable))

# no need to run any of these


# leafFW <- morpho %>% 
#   select(c(id_plant, FW_L1phl, FW_L2phl, FW_L3phl)) %>% 
#   reshape2::melt(id.vars = c('id_plant'))
# names(leafFW)[3] <- 'FW'
# leafFW$leafID <- substr(leafFW$variable, 5, 5)
# leafFW <- leafFW %>% select(-c(variable))
# 
# leafSW <- morpho %>% 
#   select(c(id_plant, SW_L1phl, SW_L2phl, SW_L3phl)) %>% 
#   reshape2::melt(id.vars = c('id_plant'))
# names(leafSW)[3] <- 'SW'
# leafSW$leafID <- substr(leafSW$variable, 5, 5)
# leafSW <- leafSW %>% select(-c(variable))
# 
# leafDW <- morpho %>% 
#   select(c(id_plant, DW_L1phl, DW_L2phl, DW_L3phl)) %>% 
#   reshape2::melt(id.vars = c('id_plant'))
# names(leafDW)[3] <- 'DW'
# leafDW$leafID <- substr(leafDW$variable, 5, 5)
# leafDW <- leafDW %>% select(-c(variable))
# 
# leaves <- left_join(leafRWC, leafFW, by = c('id_plant', 'leafID'))
# leaves <- left_join(leaves, leafSW, by = c('id_plant', 'leafID'))
# leaves <- left_join(leaves, leafDW, by = c('id_plant', 'leafID'))
# leaves[which(is.na(leaves$rwc)), 'SW'] <- NA
# leaves$diff <- leaves$SW - leaves$FW
# leavesSumm <- leaves %>% 
#   group_by(id_plant) %>% 
#   summarise(maxDiff = max(diff, na.rm = T))
# 
# leaves <- left_join(leaves, leavesSumm, by = 'id_plant')
# leaves$isMax <- ifelse(leaves$diff - leaves$maxDiff == 0, 'yes', 'no')
# leaves$leafID[which(leaves$leafID == 1)] <- 'A'
# leaves$leafID[which(leaves$leafID == 2)] <- 'B'
# leaves$leafID[which(leaves$leafID == 3)] <- 'C'
# leaves <- doBy::orderBy(~id_plant + leafID, leaves)
# write.csv(leaves, row.names = F, file = 'products_inv/selectLeafPhloemAnalyses.csv')
# 
# #Promedios
# lrwcsumm <-leaves %>% 
#   group_by(id_plant) %>% 
#   summarise(lrwc_mean = mean(rwc,na.rm = TRUE))


######Uniendo sampling-gas_x-lrwc###
# use inner_join (keep all records in both dataframes) instead of left_join/right_join
# except for when joining with morpho that has ALL the plants (120)
# use morpho (has LRWC)
water_gasx <- labels %>%
  right_join(morpho, by = 'id_plant') %>% 
  inner_join(gas_x, by = 'id_plant') %>%
  inner_join(wp_sum, by = 'id_plant')


###Extraer dataframe a un archivo excel###
write.xlsx(water_gasx,file = "products_inv/water_gasx.xlsx", rowNames = FALSE)

