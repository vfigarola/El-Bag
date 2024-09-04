
##### cleaning the environments
rm(list = ls())
graphics.off()
cat("\014")


##### working dictionary
getwd()
setwd("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/")


###############################################
# packages and references
###############################################

# load packages
library(data.table)
library(dplyr)
library(tidyr)
#library(nlme)
library(ggplot2)
#library(multcomp)
#library(emmeans)
library(rstatix)
library(ggpubr)
#library(ez)
#library(lme4)
library(effsize)
library(gridExtra)
library(grid)
library(lattice)
library(tidyverse)



###############################################
# main code: get clean data
###############################################
data = 'Code/Analysis/blink_count.csv' #gorilla saves all subjects data (i.e., data_all.csv)
data <- read.csv(data, header = TRUE)


data_summary = data %>%
  dplyr::group_by(ID,envCond,intCond) %>%
  dplyr::summarise(blink_avg = mean(blinkCt))
data_summary


# data_reform <- reshape2::melt(data = summary, id.vars = c('ID','intCond','envCond'), variable.name = 'blink_avg',value.name = 'avgBlink')

# data_reform <- pivot_longer(data,cols = starts_with("syl"),
#                             names_to = "sylb",
#                             values_to = "accuracy")

############ Plotting 
color_palette = c("#FF0000", "#3333FF")

title_size = 16
axis_size = 16
label_size = 14


# main code: visualization
raw_plot = data %>%
  ggplot(aes(x=intCond, y=blinkCt, fill = envCond)) +
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = intCond,y = blinkCt,fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  # geom_line(aes(group=interaction(subjID,sylb)),alpha=0.2) +
  scale_color_manual(values=color_palette) +
  scale_fill_manual(values=color_palette) +
  ggtitle('Blink Count') +
  xlab('Condition') +
  ylab('Average # of Blinks') +
  scale_x_discrete(labels=c("anech.inter" = "1","anech.sylb2" = "2","anech.sylb3" = "3"
                            ,"anech.sylb4" = "4","anech.sylb5" = "5",
                            "reverb.sylb1" = "","reverb.sylb2" = "","reverb.sylb3" = "","reverb.sylb4" = "","reverb.sylb5" = "")) +
  theme_bw() +
  theme(
    # panel.border = element_blank(),
    panel.grid.major = element_blank(),
    # panel.grid.minor = element_blank(),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  )
raw_plot



