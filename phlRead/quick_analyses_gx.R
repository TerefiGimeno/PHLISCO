serr <- function(x){
  se <- sd(x)/sqrt(length(x))
  return(se)
}
library(tidyverse)
third <- read.csv("phlData/third_camp_gx_short.csv")
third$iWUE <- third$Photo/third$Cond
summary(aov(Photo ~ CO2 * water, data = third))
summary(aov(Cond ~ CO2 * water, data = third))
summary(aov(iWUE ~ CO2 * water, data = third))
thirdSumm <- third %>% group_by(CO2, water) %>% 
  summarise(Amean = mean(Photo), Ase = serr(Photo),
            gsmean = mean(Cond), gsse = serr(Cond),
            iWUEmean = mean(iWUE), iWUEse = serr(iWUE))
ggplot(thirdSumm, aes(x=CO2, y=Amean, fill=water)) + 
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  geom_errorbar(aes(ymin=Amean, ymax=Amean+Ase), width=.2,
                position=position_dodge(.9)) +
  labs(title="Photosynthesis", x=expression(CO[2]), y = expression(italic(A)[net]~(mu*mol~CO[2]~m^-2~s^-1))) +
  theme_classic()

ggplot(thirdSumm, aes(x=CO2, y=gsmean, fill=water)) + 
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  geom_errorbar(aes(ymin=gsmean, ymax=gsmean+gsse), width=.2,
                position=position_dodge(.9)) +
  labs(title="Stomatal Conductance", x=expression(CO[2]), y = expression(italic(g)[s]~(mol~H[2]*O~m^-2~s^-1))) +
  theme_classic()

ggplot(thirdSumm, aes(x=CO2, y=iWUEmean, fill=water)) + 
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  geom_errorbar(aes(ymin=iWUEmean, ymax=iWUEmean+iWUEse), width=.2,
                position=position_dodge(.9)) +
  labs(title="Water use efficiency", x=expression(CO[2]), y = expression(iWUE~(mu*mol~CO[2]~mol^-1~H[2]*O))) +
  theme_classic()
