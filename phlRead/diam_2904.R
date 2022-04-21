#Tengo que estimar el diámetro para el día 29 de abril en base a 
  #1) el diámetro el día 20 de abril y 
  #2) el crecimiento para cada grupo (ambiente/elevado Co2) de las plantas control.

#Para ello tengo que: calcular incremento de diametro para cada planta (f_diam - i_diam), 
 #dividirlo entre los dias que pasan desde el inicio hasta el muestreo destructivo de cada planta, 
 #y sumar esto al i_diam de cada planta

source('scriptstfg/pre-correlaciones.R')

View(morpho)

#calcular medias de diametro 1 y 2
morpho$diam_i <- rowMeans(morpho [, c('initial_stem_width_1_cm', 'initial_stem_width_2_cm')])
morpho$diam_f <- rowMeans(morpho [, c('stem_width_1_cm', 'stem_width_2_cm')])

#incremento diametro de cada planta
morpho$diam_incr <- morpho$diam_f - morpho$diam_i

morpho[which(morpho$diam_incr < 0), 'diam_incr'] <- 0

#incremento por día de cada planta
morpho$diam_day<- morpho$diam_incr/morpho$n_days

#crear variable que combina water treatment y co2 treatment
morpho$water_co2 <- paste0(morpho$treatment_co2, '_', morpho$water_treatment)

#histograma para ver distribucion
windows(12, 8)
ggplot(morpho, aes(x = diam_day)) +
  geom_histogram(fill = "white", colour = "black") +
  facet_grid(water_co2 ~ .)

#boxplot para ver los outliers
library(ggplot2)
windows(12, 8)
dd <- ggplot(morpho, aes(x = water_co2, y = diam_day, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(diampordia)~(cm^2~dia^-1))) +
  xlab('')
dd+scale_fill_brewer(palette= 'Paired')

#eliminar outliers

Q <- quantile(morpho$diam_day, probs=c(.25, .75), na.rm = TRUE)
iqr <- IQR(morpho$diam_day, , na.rm = TRUE)

up <-  Q[2]+1.5*iqr # Upper Range  
low<- Q[1]-1.5*iqr # Lower Range

morpho_elim<- subset(morpho, morpho$diam_day > (Q[1] - 1.5*iqr) & morpho$diam_day < (Q[2]+1.5*iqr))


windows(12, 8)
dd <- ggplot(morpho_elim, aes(x = water_co2, y = diam_day, fill=water_co2)) +
  geom_boxplot() +
  ylab(expression(italic(diampordia)~(cm^2~dia^-1))) +
  xlab('')
dd+scale_fill_brewer(palette= 'Paired')

#crecimieno por dia por tratamiento

source('scriptstfg/basicFunTEG.R')
diam_day_groups <- morpho_elim %>%
  group_by (water_co2) %>%
  summarize (diam_day_mean = mean (diam_day, na.rm=T),
             diam_day_sd = sd(diam_day, na.rm=T),
             diam_day_se = s.err.na(diam_day))

#dejar solo los de los dos controles
diam_day_controls <- diam_day_groups %>%
  filter(!water_co2 == "ambient_drought" & !water_co2 == "elevated_drought")

#cambiar las variables ambient_drought y elevated_drought a simplemente ambient y elevated.
#Cambiar nombre de la columna water_co2 a treatment_co2 para que coincida con esta columna del dataframe "morpho"

diam_day_controls[which(diam_day_controls$water_co2 == "ambient_control"), 'water_co2'] <- "ambient"
diam_day_controls[which(diam_day_controls$water_co2 == "elevated_control"), 'water_co2'] <- "elevated"

diam_day_controls <- diam_day_controls %>% rename(treatment_co2 = water_co2)

#asignarle a cada planta (todas) la media de crecimiento de diametro (de las plantas control) correspondiente a su tratamiento de co2
morpho <- morpho %>%
  left_join(diam_day_controls, by = 'treatment_co2')

#crear variable del diametro estimado del 29 de abril. (Lo multiplico por 9 porque han pasado 9 días del 20 al 29 de abril)
morpho$diam_2904 <- morpho$diam_i + (morpho$diam_day_mean* 9)

#Guardar csv

write.csv(morpho, file ='morpho_diam.csv', row.names = F)
write.csv(morpho, file = 'resultadostfg//morpho_diam.csv', row.names = F)
