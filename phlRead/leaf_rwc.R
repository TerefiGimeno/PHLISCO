source('phlRead/basicFunTEG.R')
library(tidyverse)
morpho <- read.csv('phlData/morpho_merged.csv')
morpho$leaf1RWC <- (morpho$FW_L1phl - morpho$DW_L1phl)/(morpho$SW_L1phl - morpho$DW_L1phl)
morpho$leaf2RWC <- (morpho$FW_L2phl - morpho$DW_L2phl)/(morpho$SW_L2phl - morpho$DW_L2phl)
morpho$leaf3RWC <- (morpho$FW_L3phl - morpho$DW_L3phl)/(morpho$SW_L3phl - morpho$DW_L3phl)
#have a look at raw values
# windows(12, 8)
# par(mfrow = c(1, 3))
# hist(morpho$leaf1RWC)
# hist(morpho$leaf2RWC)
# hist(morpho$leaf3RWC)
# transform values above 100% and below 50% into NA's
morpho[which(morpho$leaf1RWC > 1 | morpho$leaf1RWC < 0.5), 'leaf1RWC'] <- NA
morpho[which(morpho$leaf2RWC > 1 | morpho$leaf2RWC < 0.5), 'leaf2RWC'] <- NA
morpho[which(morpho$leaf3RWC > 1 | morpho$leaf3RWC < 0.5), 'leaf3RWC'] <- NA
morpho <- morpho %>%
  mutate(leafRWCmean = apply(.[c(paste0('leaf', 1:3, 'RWC'))], 1, mean.na)) %>%
  mutate(leafRWCse = apply(.[c(paste0('leaf', 1:3, 'RWC'))], 1, s.err.na))
with(morpho, plot(leafRWCse ~ leafRWCmean))
# do not use these samples
morpho[which(is.na(morpho$leaf1RWC)), c('ID_plant', 'phytotron', 'water_treatment', 'date', 
                                        'FW_L1phl', 'SW_L1phl', 'DW_L1phl', 'leaf1RWC')]
morpho[which(is.na(morpho$leaf2RWC)), c('ID_plant', 'phytotron', 'water_treatment', 'date', 
                                        'FW_L2phl', 'SW_L2phl', 'DW_L2phl', 'leaf2RWC')]
morpho[which(is.na(morpho$leaf3RWC)), c('ID_plant', 'phytotron', 'water_treatment', 'date', 
                                        'FW_L3phl', 'SW_L3phl', 'DW_L3phl', 'leaf3RWC')]
# have a look at how leaf rwc evolves over time in the different treatments
hist(morpho$leafRWCmean)

sampleList <- read.csv('phlData/summary_sampled_plants_long.csv')
morpho <- left_join(morpho, sampleList[, c('N_days_w', 'ID_plant', 'campaign')], by = 'ID_plant')
morpho$CO2 <- ifelse(morpho$phytotron == 1, 'elevated', 'ambient')

leafRWC <- morpho %>% 
  select(c(ID_plant, N_days_w, campaign, CO2, water_treatment, leaf1RWC, leaf2RWC, leaf3RWC)) %>% 
  reshape2::melt(id.vars = c('ID_plant', 'N_days_w', 'campaign', 'CO2', 'water_treatment'))
names(leafRWC)[7] <- 'rwc'
leafRWC$leafID <- substr(leafRWC$variable, 5, 5)
leafRWC <- leafRWC %>% select(-c(variable))

leafFW <- morpho %>% 
  select(c(ID_plant, FW_L1phl, FW_L2phl, FW_L3phl)) %>% 
  reshape2::melt(id.vars = c('ID_plant'))
names(leafFW)[3] <- 'FW'
leafFW$leafID <- substr(leafFW$variable, 5, 5)
leafFW <- leafFW %>% select(-c(variable))

leafSW <- morpho %>% 
  select(c(ID_plant, SW_L1phl, SW_L2phl, SW_L3phl)) %>% 
  reshape2::melt(id.vars = c('ID_plant'))
names(leafSW)[3] <- 'SW'
leafSW$leafID <- substr(leafSW$variable, 5, 5)
leafSW <- leafSW %>% select(-c(variable))

leafDW <- morpho %>% 
  select(c(ID_plant, DW_L1phl, DW_L2phl, DW_L3phl)) %>% 
  reshape2::melt(id.vars = c('ID_plant'))
names(leafDW)[3] <- 'DW'
leafDW$leafID <- substr(leafDW$variable, 5, 5)
leafDW <- leafDW %>% select(-c(variable))

leaves <- left_join(leafRWC, leafFW, by = c('ID_plant', 'leafID'))
leaves <- left_join(leaves, leafSW, by = c('ID_plant', 'leafID'))
leaves <- left_join(leaves, leafDW, by = c('ID_plant', 'leafID'))
leaves[which(is.na(leaves$rwc)), 'SW'] <- NA
leaves$diff <- leaves$SW - leaves$FW
leavesSumm <- leaves %>% 
  group_by(ID_plant) %>% 
  summarise(maxDiff = max(diff, na.rm = T))

leaves <- left_join(leaves, leavesSumm, by = 'ID_plant')
leaves$isMax <- ifelse(leaves$diff - leaves$maxDiff == 0, 'yes', 'no')
leaves$leafID[which(leaves$leafID == 1)] <- 'A'
leaves$leafID[which(leaves$leafID == 2)] <- 'B'
leaves$leafID[which(leaves$leafID == 3)] <- 'C'
leaves <- doBy::orderBy(~ID_plant + leafID, leaves)
write.csv(leaves, row.names = F, file = 'phlOutput/selectLeafPhloemAnalyses.csv')

leaves$fID_plant <- as.factor(leaves$ID_plant)
leaves$fcamp <- as.factor(leaves$campaign)
rwcMod <- nlme::lme(rwc ~ N_days_w * CO2, random = ~1|fcamp/fID_plant, data = leaves, na.action = "na.omit")
# rwc is lower (???) under eCO2
# the data from the first campaign are very dubious
rwcMod <- nlme::lme(rwc ~ N_days_w * CO2, random = ~1|fcamp/fID_plant, data = subset(leaves, campaign > 1), na.action = "na.omit")
# no significant effecs of eCO2 on rwc or on the interaction term
