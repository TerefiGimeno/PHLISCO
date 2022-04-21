####Usando correlacion entre diametro final y biomasa, calcular biomasas iniciales de las plantas muestreadas (72-75)

source('scriptstfg/4_read_weight_pots.R')

#read data
morpho_biomass <- read.csv('C:/calculostfg/datostfg/morpho_biomass.csv')


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
# calculate average initial and final diameters (not on morpho_biomass yet)
morpho_biomass$diam_f_avg <- rowMeans(morpho_biomass[, paste0('stem_width_', 1:2, '_cm')], na.rm = T)
morpho_biomass$diam_i_avg <- rowMeans(morpho_biomass[, paste0('initial_stem_width_', 1:2, '_cm')], na.rm = T)


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
# do the same for final biomass
morpho_biomass$predicted_i_abg_wood_DW <- int_mod_abg+morpho_biomass$diam_i_avg*slope_mod_abg
morpho_biomass$predicted_f_abg_wood_DW <- int_mod_abg+morpho_biomass$diam_f_avg*slope_mod_abg
# plot predictd vs. obseved
plot(morpho_biomass$predicted_f_abg_wood_DW ~ morpho_biomass$abg_wood_DW,
     ylab = 'Biomass predicted', xlab = 'Biomass observed', pch = 19,
     col = as.factor(morpho_biomass$treatment_co2))
legend('topleft', bty = 'n', pch = c(19, 19), legend = c('ambient', 'elevated'), col = c('black', 'red'))
# looks pretty good! Our fit seems to be unerestimating a little bit high values of biomass

windows(12, 8)
hist(morpho_biomass$predicted_i_abg_wood_DW)

# morpho_biomass_short<-data.frame(morpho_biomass$id_plant, morpho_biomass$campaign, morpho_biomass$phyto,
#                                  morpho_biomass$treatment_co2, morpho_biomass$water_treatment,
#                                  morpho_biomass$abg_wood_DW, morpho_biomass$predicted_i_abg_wood_DW,
#                                  morpho_biomass$predicted_f_abg_wood_DW)
# morpho_biomass_short <- morpho_biomass_short %>% rename(id_plant = morpho_biomass.id_plant)

# you can simplify the lines of code above with:
morpho_biomass_short <- morpho_biomass %>% 
  select(id_plant, campaign, phyto, treatment_co2, water_treatment,
         abg_wood_DW, predicted_i_abg_wood_DW, predicted_f_abg_wood_DW)

#trabajar con datos de transpiracion

# library(doBy) 
# total_transp<-summaryBy(increment_g ~ id_plant, FUN=sum,na.rm = T, data=transp)
# used "transp_summ" created with the script read_weights

#Crear data frame con solo las 30 pantas, el "increment"(lo transpirado) y biomasas iniciales y finales (del frame de morpho_biomass_short)

biomass_per_transp <- transp_summ %>%
  left_join(morpho_biomass_short, by = 'id_plant')

# you do not need to do this if you use the pipeline above :-)
# #renombrar
# biomass_per_transp <- biomass_per_transp %>% rename(campaign = morpho_biomass.campaign)
# biomass_per_transp <- biomass_per_transp %>% rename(increment_transp = increment_g.sum)
# biomass_per_transp <- biomass_per_transp %>% rename(phyto = morpho_biomass.phyto)
# biomass_per_transp <- biomass_per_transp %>% rename(treatment_co2 = morpho_biomass.treatment_co2)
# biomass_per_transp <- biomass_per_transp %>% rename(water_treatment = morpho_biomass.water_treatment)
# biomass_per_transp <- biomass_per_transp %>% rename(abg_wood_DW = morpho_biomass.abg_wood_DW)
# biomass_per_transp <- biomass_per_transp %>% rename(predicted_i_abg_wood_DW = morpho_biomass.predicted_i_abg_wood_DW)

#incremento transpiracion de gramos a Litros (es como pasar de gramos a kilogramos)
biomass_per_transp$increment_transp_L <- (biomass_per_transp$E_cum * 0.001)

#Calcular incremento de biomasa
biomass_per_transp$increment_biomass <- (biomass_per_transp$abg_wood_DW - biomass_per_transp$predicted_i_abg_wood_DW)
# calculate biomass gain with the differnce betweeen predicted values
biomass_per_transp <- biomass_per_transp %>% 
  mutate(increment_biomass_pred = predicted_f_abg_wood_DW - predicted_i_abg_wood_DW)
hist(biomass_per_transp$increment_biomass_pred)
# no more negative values!
#unos pocos salen con valor negativo; convertirlos en NA
biomass_per_transp[which(biomass_per_transp$increment_biomass < 0), 'increment_biomass'] <- NA

#Tal vez mejor convertirlos a 0?
#biomass_per_transp[which(biomass_per_transp$increment_biomass < 0), 'increment_biomass'] <- 0

#Calcular incremento de biomasa por cada incremento de transpiracion
biomass_per_transp$g_per_L <-biomass_per_transp$increment_biomass/biomass_per_transp$increment_transp_L
# idem but with the predicted increment
biomass_per_transp <- biomass_per_transp %>% 
  mutate(g_per_L_pred = increment_biomass_pred/increment_transp_L)


windows(12, 8)
hist(biomass_per_transp$g_per_L)
hist(biomass_per_transp$g_per_L_pred)


# I HAVEN'T REVISED THE SCRIPT FROM HERE ONWARDS BECAUSE WE WILL DISCUSS THE DETAILS TOMORROW

# create a variable that combines water and CO2 treatment
biomass_per_transp$water_co2 <- paste0(biomass_per_transp$treatment_co2, '_', biomass_per_transp$water_treatment)

#crear boxplot por tratamiento

library(ggplot2)

windows(12, 8)
nn <- ggplot(biomass_per_transp, aes(x = water_co2, y = g_per_L, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(WUE)~(g~L^-1))) +
  xlab('')
nn+scale_fill_brewer(palette= 'Paired')


#Puedo separarlos por campañas, pero esto no tiene sentido en estas 30 plantas. Hay pocas por cada campaña, y justamente se dejaron para las últimas campañas.

# biomass_per_transp[3:4] = lapply(biomass_per_transp[3:4], FUN = function(y){as.numeric(y)})

# (windows(12, 8))
#ggplot(biomass_per_transp, aes(x = campaign, y = g_per_L)) +
 # geom_boxplot() + 
  #facet_grid(~water_co2) +
  #ylab(expression(italic(WUE)~(g~L^-1))) +
  #xlab('')


#medias por tratamiento
biomass_per_transp_groups <- biomass_per_transp %>%
  group_by (biomass_per_transp$treatment_co2, biomass_per_transp$water_treatment)%>%
  summarise (biomass_per_transp_groups_mean= mean (g_per_L, na.rm=T),
             biomass_per_transp_groups_sd= sd(g_per_L, na.rm=T))

#MODELOS LINEALES (ANOVA)####

#primero ajustar el modelo con la funcion lm()

lm.biomass_per_transp <- lm(g_per_L~water_co2, data=biomass_per_transp)
summary(lm.biomass_per_transp)

#hacer ANOVA
anova(lm.biomass_per_transp)

#p_value=0,004161 (<0,05) : los cuatro niveles del factor son importantes para determinar WUE
#r squared: el modelo expica un %38,3 de la variabilidad de la variable respuesta

#hacer test de Bonferroni para comparar dos a dos
pairwise.t.test(biomass_per_transp$g_per_L, biomass_per_transp$water_co2, p.adjust= "bonferroni")

###ANALISIS DE RESIDUOS####

windows(12, 8)
par(mfcol=c(2,2))
plot(lm.biomass_per_transp)
#habria que eliminar outliers (plantas 2, 10 y 28) ?????

#Test de shapiro
shapiro.test(residuals(lm.biomass_per_transp))

#p=0,1587 (p>0,05) por lo que aceptamos la hipotesis nula: los residuos son normales

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
install.packages("car", dep=T)
library(car)
leveneTest(g_per_L~water_co2, data=biomass_per_transp)

#p=0,2709 (p>0,05) por lo que nuestros datos son homocedasticos, asumimos la homogenidad de varianza (=la varianza residual es constante)


#ANOVA DE DOS VIAS####

#crear boxplot agrupado (me gusta mas el que hago antes, separando los 4 tratamientos)
install.packages("ggpubr")
library("ggpubr")
windows(12, 8)
ggboxplot(biomass_per_transp, x = "treatment_co2", y = "g_per_L", color = "water_treatment",
          palette = c("#00AFBB", "#E7B800"))+
  ylab(expression(italic(WUE)~(g~L^-1))) +
  xlab('')

#hacer anova de dos vias:
WUE_anova2 <- aov(g_per_L ~ treatment_co2 + water_treatment, data = biomass_per_transp)
summary(WUE_anova2)

#Note the above fitted model is called additive model. 
#It makes an assumption that the two factor variables are independent. 
#If you think that these two variables might interact to create an synergistic effect, 
 #replace the plus symbol (+) by an asterisk (*), as follow.

WUE_anova2b <- aov(g_per_L ~ treatment_co2 * water_treatment, data = biomass_per_transp)
summary(WUE_anova2b)

#treatment_co2:water_treatment p=0,15831> 0,05, 
 #por lo que NO HAY INTERACCIÓN entre el tratamiento de co2 y agua (?).
   #asi que usare el "additive model" (WUE_anova2)

###ANALISIS DE RESIDUOS#### (es lo mismo que para la anova de una via)

windows(12, 8)
par(mfcol=c(2,2))
plot(WUE_anova2b)

#Test de shapiro
shapiro.test(residuals(WUE_anova2b))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
library(car)
leveneTest(g_per_L ~ treatment_co2 * water_treatment, data = biomass_per_transp)

#p=0,2709 (p>0,05) por lo que nuestros datos son homocedasticos, asumimos la homogenidad de varianza (=la varianza residual es constante)

