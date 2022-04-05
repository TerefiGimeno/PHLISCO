##Script para calcular RWC


### load libraries ####
library(googledrive)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(readxl)
library(googlesheets4)
library(googlesheets)
#Read data from google drive
googledrive::drive_download(file = "sampling_cleaned",
                            path = "phlData//sampling_clean.csv", overwrite = TRUE)
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

#Add column of sampling date and identifing like a date
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
sampling$DW_s <- (sampling$DW_soil)
sampling$WC_s <- (((sampling$FW_s-sampling$DW_s)/sampling$DW_s)*100)
view(sampling$WC_s)

#Merged  WC_ss y WC_s
sampling <- sampling %>% 
  mutate(WC = ifelse(is.na(WC_ss) , WC_s, WC_ss))
view(sampling$WC)


###We have not this file in the drive, i attached with the email###
#Add drought days for the drought treatment 
#Create a object from csv ## I have this file in my local directory "data_inv"                           
droughtdays <- read.csv('phlData/drought_days.csv')


##PREPARING THE FILE MORPHO###
#Comando para crear un data frame de morpho desde un archivo especifico del drive
morpho <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1EqIYhOlCPGVp2AKgWZ2gqlKjDUCFtPtpeYkNSPRMcNo/edit#gid=0", sheet = "Sheet1")
str(morpho)

#Asignar NA a todos los valores por encima de 2000 para todas las variables que no tienen datos
morpho[which(morpho$height_cm > 2000),
       c("date_f","height_cm",paste0("stem_width_",1:2,"_cm"),"branching","n_days")] <- NA

#Cambiando el formato de fecha para que lo entienda R
morpho$date_i<-lubridate::ymd(morpho$date_i)
morpho$date_f<-lubridate::ymd(morpho$date_f)

#Numero de dias = (fecha final-fecha inicial) explorar diff.Date y difftime
morpho$nD <- difftime(morpho$date_f,morpho$date_i, units = "days")

#Crear un subset eliminando el tratamiento drought_test
morpho2 <- subset(morpho, treatment_h2o !="drought_test")
str(morpho2)


#Merged morpho-sampling-droughtdays
# Important the resulting file will only have the harvested plants
morpho_sampling <- morpho2 %>%
  right_join(sampling, by = 'id_plant')%>%
  right_join(droughtdays, by = 'id_plant')
view(morpho_sampling)


####WATER CONTENT CALCULATES###

#Graficando water content con ggplot
ggplot(data = morpho_sampling,
       mapping = aes(x =campaign,
                     y =WC))+  
  geom_point() + ylim(0,60)



###Standard errors calculates###
#Subsets h2o treatment
WC_control <- subset(morpho_sampling, treatment_h2o =="control"
                     & !WC =="NA")
WC_drought <- subset(morpho_sampling, treatment_h2o =="drought"
                     & !WC =="NA")
WC_moddrought <- subset(morpho_sampling, treatment_h2o =="moderate_drought"
                        & !WC =="NA")
#Create a vector
WC_control_V <- as.vector(WC_control$WC)
View(WC_control_V)

WC_drought_V <- as.vector(WC_drought$WC)
View(WC_drought_V)

WC_moddrought_V <- as.vector(WC_moddrought$WC)
View(WC_moddrought_V)

#create function
standard_error_c <- function(WC_control_V) sqrt(var(WC_control_V) / length(WC_control_V))
standard_error_d <- function(WC_drought_V) sqrt(var(WC_drought_V) / length(WC_drought_V))
standard_error_md <- function(WC_moddrought_V) sqrt(var(WC_moddrought_V) / length(WC_moddrought_V))

#Apply function
standard_error_c (WC_control_V)
standard_error_d (WC_drought_V)
standard_error_md (WC_moddrought_V)

##Adding to database morpho sampling##
morpho_sampling$sd_c <- standard_error_c (WC_control_V)
morpho_sampling$sd_d <- standard_error_d (WC_drought_V)
morpho_sampling$sd_md <- standard_error_md (WC_moddrought_V)

###Average per campigns###
morpho_sampling_sum <- morpho_sampling %>% 
  group_by(campaign,treatment_h2o,treatment_co2) %>% 
  summarise(WC_mean = mean(WC,na.rm = TRUE),
            sd_c = mean(sd_c,na.rm = TRUE),
            sd_d = mean(sd_d,na.rm = TRUE),
            sd_md = mean(sd_md,na.rm = TRUE))

#Incorporate standard error at the morpho sampling sum database
###No pude incorporar el error del tratamiento "moderate drought"###
morpho_sampling_sum <- morpho_sampling_sum %>% 
  mutate(sd = ifelse(treatment_h2o =="control" , sd_c, sd_d))
# %>% mutate(sd = rename(treatment_h2o =="moderate_drought", sd_md))
view(sampling$WC)  


#Graficando promedio de WC por campaña 
attach(morpho_sampling_sum)
ggplot(data = morpho_sampling_sum,
       aes(campaign,WC_mean, colour = treatment_h2o))+
  geom_point()+ ylim(0,50)+
  geom_errorbar(ymin = WC_mean-sd,ymax =WC_mean+sd)


#ANOVA
morpho_sampling_aov <- aov(morpho_sampling_sum$WC_mean ~ campaign*treatment_h2o, data = morpho_sampling_sum)
summary(morpho_sampling_aov)
TukeyHSD(morpho_sampling_aov)#No funcionan


##export morpho sampling sum database to excel##
#library(openxlsx)
#write.xlsx(morpho_sampling_sum,file = "data_inv/morpho_sampling_sum.xlsx", row.names = FALSE)


