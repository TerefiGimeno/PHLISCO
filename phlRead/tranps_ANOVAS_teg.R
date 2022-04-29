source('scriptstfg/4_read_weight_pots.R')

#12-13 de MAYO ####

##a) ANOVA de dos vias de transpiraciones DIARIAS los dias 12 y 13 de mayo ####

#crear data frame con los datos de hasta el 12-13 de mayo
# you can do this in a single step
transp_12_13_day <- transp_and_area %>% 
  filter(date <= as.Date("2021-05-13"))

#Hacer boxplot
library(ggplot2)
windows(12, 8)
t1213 <- ggplot(transp_12_13_day, aes(x = water_co2, y = daily_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t1213+scale_fill_brewer(palette= 'Paired')

#con otros tonos de color
windows(12, 8)
t1213 <- ggplot(transp_12_13_day, aes(x = water_co2, y = daily_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t1213+scale_fill_manual(values = c("skyblue1", "skyblue3", "palegreen2", "palegreen4"))

#hacer ANOVA
t1213_day_anova <- aov(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_day)
summary(t1213_day_anova)

###a.1.) ANALISIS DE RESIDUOS####
windows(12, 8)
par(mfcol=c(2,2))
plot(t1213_day_anova)

#Test de shapiro
shapiro.test(residuals(t1213_day_anova))
#p=0,8654 (p>0,05) por lo que aceptamos la hipotesis nula: los residuos son normales

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
library(car)
leveneTest(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_day)
# p=0,2613 (p>0,05) por lo que nuestros datos son homocedasticos, asumimos la homogenidad de varianza (=la varianza residual es constante)

##b) ANOVA de dos vias de transpiraciones ACUMULADAS hasta el 12-13 de mayo ####

#calcular incrementos acumulados


# this is wrong! Remember we got rid of estimates 
transp_12_13 <- transp_12_13 %>%
  group_by (id_plant) %>% 
  mutate(cum_increment_g = cumsum(increment_g))

#dividir por area foliar y pasar a mol/m^2
transp_12_13 <- transp_12_13 %>% 
  mutate(cum_E_mol.m2 = (cum_increment_g/18)/(tot_area_leaves*0.0001))

#filtrar solo fechas 12 y 13 de mayo

transp_12_13_cum <- transp_12_13 %>% 
  filter(date >= as.Date("2021-05-12"))

t1213_cum_anova <- aov(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_cum)
summary(t1213_cum_anova)

#hacer boxplot
windows(12, 8)
t1213cum <- ggplot(transp_12_13_cum, aes(x = water_co2, y = cum_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t1213cum+scale_fill_brewer(palette= 'Paired')

###b.1.) ANALISIS DE RESIDUOS####
windows(12, 8)
par(mfcol=c(2,2))
plot(t1213_cum_anova)

#Test de shapiro
shapiro.test(residuals(t1213_cum_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_cum)

##c) ANOVA de dos vias de media de transpiraciones diarias de cada planta hasta el 12-13 de mayo ####

transp_12_13 <- transp_12_13 %>%
  group_by (id_plant) %>% 
  mutate(mean_E_mol.m2 = mean(daily_E_mol.m2))

transp_12_13_mean <- transp_12_13 %>% 
  filter(date >= as.Date("2021-05-12"))

#hacer boxplot
windows(12, 8)
t1213mean <- ggplot(transp_12_13_mean, aes(x = water_co2, y = mean_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t1213mean+scale_fill_brewer(palette= 'Paired')

t1213_mean_anova <- aov(mean_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_mean)
summary(t1213_mean_anova)

###c.1.) ANALISIS DE RESIDUOS####
windows(12, 8)
par(mfcol=c(2,2))
plot(t1213_mean_anova)

#Test de shapiro
shapiro.test(residuals(t1213_mean_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(mean_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_12_13_mean)

#CAMPAÑAS 4-5 ####

## a) ANOVA de dos vias de transpiraciones del día final de las plantas de las campañas 4 y 5 ####

transp_4 <- transp_and_area %>% 
  filter(date >= as.Date("2021-06-01"))

transp_4 <- transp_4 %>% 
  filter(date <= as.Date("2021-06-03"))

#la planta 80 ?????????????????????????
transp_4 <- transp_4 %>% 
  group_by(id_plant) %>% 
  slice(which.max(day_cum))

#crear boxplot
library(ggplot2)
windows(12, 8)
t4day <- ggplot(transp_4, aes(x = water_co2, y = daily_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t4day+scale_fill_brewer(palette= 'Paired')

#ANOVA
t4_day_anova <- aov(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_4)
summary(t4_day_anova)

###a.1.) ANALISIS DE RESIDUOS####
windows(12, 8)
par(mfcol=c(2,2))
plot(t4_day_anova)

#Test de shapiro
shapiro.test(residuals(t4_day_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_4)

##b) ANOVA de dos vias de transpiraciones ACUMULADAS hasta el dia final (plantas campañas 4 y 5) ####

#calcular incrementos acumulados
transp_cum_4 <- transp_and_area %>%
  group_by (id_plant) %>% 
  mutate(cum_increment_g = cumsum(increment_g))

#dividir por area foliar y pasar a mol/m^2
transp_cum_4 <- transp_cum_4 %>% 
  mutate(cum_E_mol.m2 = (cum_increment_g/18)/(tot_area_leaves*0.0001))

#data frame con solo fechas de la campaña 4

transp_cum_4 <- transp_cum_4 %>% 
  filter(date >= as.Date("2021-06-01"))

transp_cum_4 <- transp_cum_4 %>% 
  filter(date <= as.Date("2021-06-03"))

#la planta 80 ?????????????????????????
transp_cum_4 <- transp_cum_4 %>% 
  group_by(id_plant) %>% 
  slice(which.max(day_cum))

#crear boxplot
windows(12, 8)
t4cum <- ggplot(transp_cum_4, aes(x = water_co2, y = cum_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t4cum+scale_fill_brewer(palette= 'Paired')

#ANOVA
t4_cum_anova <- aov(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_cum_4)
summary(t4_cum_anova)

###b.1.) ANALISIS DE RESIDUOS####
windows(12, 8)
par(mfcol=c(2,2))
plot(t4_cum_anova)

#Test de shapiro
shapiro.test(residuals(t4_cum_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_cum_4)

#CAMPAÑA 3 ####

## a) ANOVA de dos vias de transpiraciones del día final de las plantas de la campaña 3 ####

#crear dos data frames: 
# 1 (transp_fin_3): las plantas que se cosechan en la campaña 3 (so todas drought)
# 2 (transp_3): las plantas control de la campaña 4 y 5 el día de la campaña 3 (27 de mayo)

#1: data frame con solo el último día de cada planta
transp_fin <- transp_and_area %>% 
  group_by(id_plant) %>% 
  slice(which.max(day_cum))

#solo plantas de la campaña 3
transp_fin_3 <- transp_fin %>% 
  filter(date < as.Date("2021-06-01"))

#2: datos de los días de la campaña 3 (del 25 de mayo al 27 de mayo, aunque pone que son todas del 27)

transp_3 <- transp_and_area %>% 
  filter(date >= as.Date("2021-05-25"))
transp_3 <- transp_3 %>% 
  filter(date <= as.Date("2021-05-27"))

#solo las plantas control
transp_3 <- transp_3 %>% 
  filter(water_treatment == "control")

#juntar los dos data frames
transp_3_day <- rbind(transp_fin_3, transp_3)

#crear boxplot
windows(12, 8)
t3day <- ggplot(transp_3_day, aes(x = water_co2, y = daily_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t3day+scale_fill_brewer(palette= 'Paired')

#hacer ANOVA

t3_day_anova <- aov(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_3_day)
summary(t3_day_anova)

## a.1.) ANALISIS DE RESIDUOS ####
windows(12, 8)
par(mfcol=c(2,2))
plot(t3_day_anova)

#Test de shapiro
shapiro.test(residuals(t3_day_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(daily_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_3_day)

##b) ANOVA de dos vias de transpiraciones ACUMULADAS hasta el dia final (campaña 3) ####

#calcular incrementos acumulados
transp_cum <- transp_and_area %>%
  group_by (id_plant) %>% 
  mutate(cum_increment_g = cumsum(increment_g))

#dividir por area foliar y pasar a mol/m^2
transp_cum <- transp_cum %>% 
  mutate(cum_E_mol.m2 = (cum_increment_g/18)/(tot_area_leaves*0.0001))

#data frame con solo fechas de la campaña 3

#1: data frame con solo el último día de cada planta
transp_fin_3cum <- transp_cum %>% 
  group_by(id_plant) %>% 
  slice(which.max(day_cum))

#solo plantas de la campaña 3
transp_fin_3cum <- transp_fin_3cum %>% 
  filter(date < as.Date("2021-06-01"))

#2: datos de los días de la campaña 3 (del 25 de mayo al 27 de mayo, aunque pone que son todas del 27)

transp_3cum <- transp_cum %>% 
  filter(date >= as.Date("2021-05-25"))
transp_3cum <- transp_3cum %>% 
  filter(date <= as.Date("2021-05-27"))

#solo las plantas control
transp_3cum <- transp_3cum %>% 
  filter(water_treatment == "control")

#juntar los dos data frames
transp_3_cum <- rbind(transp_fin_3cum, transp_3cum)

#crear boxplot
windows(12, 8)
t3cum <- ggplot(transp_3_cum, aes(x = water_co2, y = cum_E_mol.m2, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(E)~(mol~m^-2~day^-1))) +
  xlab('')
t3cum+scale_fill_brewer(palette= 'Paired')

#hacer ANOVA

t3_cum_anova <- aov(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_3_cum)
summary(t3_cum_anova)

## b.1.) ANALISIS DE RESIDUOS ####
windows(12, 8)
par(mfcol=c(2,2))
plot(t3_cum_anova)

#Test de shapiro
shapiro.test(residuals(t3_cum_anova))

#Test de Levene para comprobar la hipótesis de homegeinedad de varianzas
leveneTest(cum_E_mol.m2 ~ treatment_co2 * water_treatment, data = transp_3_cum)


