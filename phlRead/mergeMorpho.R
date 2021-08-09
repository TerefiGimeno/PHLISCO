library('lubridate')
library('dplyr')
watering <- read.csv('phlData/water_treatment_list.csv')
morphoi <- read.csv('phlData/morpho_initial.csv')
morphof <- read.csv('phlData/morpho_final.csv')
morpho_all <- watering %>% 
  left_join(morphoi, by = c('ID_plant', 'phytotron')) %>%
  left_join(morphof, by = c('ID_plant', 'phytotron'))

morpho_all$Date_i <- ymd(morpho_all$date_i)
morpho_all$Date_f <- ymd(morpho_all$date_f)
morpho_all$n_days <- difftime(morpho_all$Date_f, morpho_all$Date_i, 'days')
write.csv(morpho_all, file ='phlOutput/morpho_all.csv', row.names = F)
