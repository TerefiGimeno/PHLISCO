### label samples for any analyses ###

# custum functions to calculate number of observastions and se without se
lengthWithoutNA <- function(x){
  l <- length(which(!is.na(x)))
  return(l)
}

s.err.na <- function(x){
  se <- sd(x, na.rm = T)/sqrt(lengthWithoutNA(x))
  return(se)
}

library(tidyverse)
# read the file with the info for each plant
labels <- read.csv('phlData/summary_sampled_plants_long.csv')
# assing CO2 treatment
labels <- labels %>% mutate(CO2 = ifelse(phytotron == 1, 'elevated', 'ambient'))
# read the data
data <- read.csv('phlData/Templete_analisis_resultados_NSC.csv')
data <- data %>% rename(ID_plant = ID)
# label correctly
data <- dplyr::left_join(data, labels, by = 'ID_plant')
# have a quick look at the mean and sd

data %>%  group_by(CO2, N_days_w, campaign) %>% 
  summarise(sac = mean(unknow4, na.rm = T), sac.se = sd(unknow4, na.rm = T), N_sac = lengthWithoutNA(unknow4))

# check for effects
hist(data$unknow4)
summary(lm(unknow4 ~ CO2 * N_days_w, data = data))
