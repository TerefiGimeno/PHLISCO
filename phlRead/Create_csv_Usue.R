#Usueri bidaltzeo csv sortzeko.

source('scriptstfg/pre-correlaciones.R')

#read data
morpho_biomass <- read.csv('C:/calculostfg/datostfg/morpho_biomass.csv')

#primero tenemos que calcular el PESO FRESCO TOTAL de la planta con RAICES INCLUIDAS

names(morpho_biomass)

morpho_biomass$total_FW <- rowSums(morpho_biomass[, c("FW_Sphl", "FW_SNSC", "FW_Shist", "FW_L1phl", "FW_L2phl", "FW_L3phl", "FW_10LNSC","FW_10LSLA", "FW_rootNSC", "FW_S", "FW_L", "FW_root" )], na.rm = T)

#Crear data frame con solo id_plant, total_FW y peso maceta (sacados de morpho_biomass)

plant_total_FW_and_pot <-data.frame(morpho_biomass$id_plant,morpho_biomass$total_FW,morpho_biomass$W_pot)

#renombrar
plant_total_FW_and_pot <- plant_total_FW_and_pot %>% rename(id_plant = morpho_biomass.id_plant)
plant_total_FW_and_pot <- plant_total_FW_and_pot %>% rename(total_FW = morpho_biomass.total_FW)
plant_total_FW_and_pot <- plant_total_FW_and_pot %>% rename(W_pot = morpho_biomass.W_pot)

#juntar con el data frame de las 30 plantas pesadas cada dia

source('scriptstfg/4_read_weight_pots.R')

RWC_calculations <- transp %>%
  left_join(plant_total_FW_and_pot, by = 'id_plant')


#pasar los pesos totales (de planta maceta y todo) a gramos
RWC_calculations$weight_g <- RWC_calculations$weight_kg*1000

#restar peso fresco de la planta (total_FW) y de la maceta a cada peso total de cada día. Conseguimos FW soil de cada dia.

RWC_calculations$FWeight_soil_g <- RWC_calculations$weight_g - (RWC_calculations$total_FW+RWC_calculations$W_pot)

#calcular RWC restando peso seco tierra. Hay un peso seco de tierra por cada planta.

RWC_calculations$dryW_g <- RWC_calculations$dryW_kg*1000

RWC_calculations$RWC_day <- ((RWC_calculations$FWeight_soil_g - RWC_calculations$dryW_g)/RWC_calculations$dryW_g)*100


#METER AREA FOLIAR####

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

#merge data frames

transp_SRWC_area <- RWC_calculations %>%
  left_join(tot_area_leaves_df, by = 'id_plant')

####calcular transpiracion diaria por unidad de area foliar (g/cm^2)####

transp_SRWC_area$daily_transp_per_area <- 
  transp_SRWC_area$daily_transp/transp_SRWC_area$tot_area_leaves

transp_SRWC_area <- transp_SRWC_area %>% 
  mutate(daily_E_mol.m2 = (daily_transp/18)/(tot_area_leaves*0.0001))


#Añadir WUE (g/L)#####

#Calcular biomasa aerea:
#primero tengo que crear varias variables:
#pesos estimados de segmentos de tallos y hojas (regla de tres con pesos frescos y secos generales)
morpho_biomass$est_DW_Sph <- (morpho_biomass$FW_Sphl*morpho_biomass$DW_S)*(morpho_biomass$FW_S^-1)
morpho_biomass$est_DW_SNSC <- (morpho_biomass$FW_SNSC*morpho_biomass$DW_S)*(morpho_biomass$FW_S^-1)
morpho_biomass$est_DW_Shist <- (morpho_biomass$FW_Shist*morpho_biomass$DW_S)*(morpho_biomass$FW_S^-1)

#comprobar que se han creado todas la nuevas variables
names(morpho_biomass)

#sumar pesos secos para calcular biomasa aerea de madera total

morpho_biomass$abg_wood_DW <- rowSums(morpho_biomass[, c('DW_S', 'est_DW_Sph', 'est_DW_SNSC', 'est_DW_Shist' )], na.rm = T)


#histograma
windows(12, 8)
hist(morpho_biomass$abg_wood_DW)


#ESTIMAR BIOMASA INICIAL USANDO LA CORRELACION

abg_wood_DW_and_diam<- lm(abg_wood_DW ~ diam_f_avg, data = morpho_biomass)
summary(abg_wood_DW_and_diam)

#ajustar el modelo de biomasa y diametro. Lo ponia en una web
library(broom)
tidy(abg_wood_DW_and_diam, quick=TRUE)

#la funcion "coefficients" me da el intercepto y la slope de la regresión. Aparece esto:
#coefficients(abg_wood_DW_and_diam)
#(Intercept)  diam_f_avg 
#-18.81651    38.81990

#esto nos va a dar el primer objeto de "coefficients", es decir, el intercepto. Y el segundo objeto, es decir, slope:
int_mod_abg <- coefficients(abg_wood_DW_and_diam)[1]
slope_mod_abg <- coefficients(abg_wood_DW_and_diam)[2]

#crear objeto para las predicciones de biomasa inicial
morpho_biomass$predicted_i_abg_wood_DW <- int_mod_abg+morpho_biomass$diam_i_avg*slope_mod_abg

morpho_biomass_short<-data.frame(morpho_biomass$id_plant, morpho_biomass$campaign, morpho_biomass$phyto, morpho_biomass$treatment_co2, morpho_biomass$water_treatment, morpho_biomass$abg_wood_DW, morpho_biomass$predicted_i_abg_wood_DW)
morpho_biomass_short <- morpho_biomass_short %>% rename(id_plant = morpho_biomass.id_plant)

total_transp2<-summaryBy(increment_g ~ id_plant, FUN=sum,na.rm = T, data=transp_SRWC_area)

biomass_per_transp <- total_transp2 %>%
  left_join(morpho_biomass_short, by = 'id_plant')

#renombrar
biomass_per_transp <- biomass_per_transp %>% rename(campaign = morpho_biomass.campaign)
biomass_per_transp <- biomass_per_transp %>% rename(increment_transp = increment_g.sum)
biomass_per_transp <- biomass_per_transp %>% rename(phyto = morpho_biomass.phyto)
biomass_per_transp <- biomass_per_transp %>% rename(treatment_co2 = morpho_biomass.treatment_co2)
biomass_per_transp <- biomass_per_transp %>% rename(water_treatment = morpho_biomass.water_treatment)
biomass_per_transp <- biomass_per_transp %>% rename(abg_wood_DW = morpho_biomass.abg_wood_DW)
biomass_per_transp <- biomass_per_transp %>% rename(predicted_i_abg_wood_DW = morpho_biomass.predicted_i_abg_wood_DW)

#incremento transpiracion de gramos a Litros
biomass_per_transp$increment_transp_L <- (biomass_per_transp$increment_transp * 0.001)

#Calcular incremento de biomasa
biomass_per_transp$increment_biomass <- (biomass_per_transp$abg_wood_DW - biomass_per_transp$predicted_i_abg_wood_DW)
#unos pocos salen con valor negativo; convertirlos en NA
biomass_per_transp[which(biomass_per_transp$increment_biomass < 0), 'increment_biomass'] <- NA

#Calcular incremento de biomasa por cada incremento de transpiracion
biomass_per_transp$WUE <-biomass_per_transp$increment_biomass/biomass_per_transp$increment_transp_L

transp_SRWC_area <- transp_SRWC_area %>%
  left_join(biomass_per_transp[, c('id_plant','abg_wood_DW','predicted_i_abg_wood_DW','increment_biomass', 'WUE')], by = 'id_plant')

#Guardar csv

write.csv(transp_SRWC_area, file ='transp_SRWC_area.csv', row.names = F)
write.csv(transp_SRWC_area, file = 'resultadostfg//trasnp_area_and_SRWC_calculations.csv', row.names = F)
