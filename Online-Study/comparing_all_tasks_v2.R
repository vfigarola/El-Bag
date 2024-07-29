
##### cleaning the environments
rm(list = ls())
graphics.off()
cat("\014")


##### working dictionary
getwd()
setwd("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/OnlineStudy/Data/")

###############################################
# packages and references
###############################################

# load packages
library(data.table)
library(dplyr)
library(tidyr)
#library(nlme)
library(ggplot2)
library(ggsignif)
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
# import data
###############################################
#task 1 = task 3; task 2 = task 4
CRM_prolific_file = 'Task1/Prolific-Study1/data_exp_143373-v4_task-af7j.csv' #gorilla saves all subjects data (i.e., data_all.csv)
CRM_prolific_data <- read.csv(CRM_prolific_file, header = TRUE)
CRM_SONA_file = 'Task1/SONA/data_exp_142662-v4_task-af7j.csv' #gorilla saves all subjects data (i.e., data_all.csv)
CRM_SONA_data <- read.csv(CRM_SONA_file, header = TRUE)
CRM_data <- rbind(CRM_prolific_data,CRM_SONA_data)


CRB_file = 'Task2/data_exp_143907-v4_task-3nup.csv' #gorilla saves all subjects data (i.e., data_all.csv)
CRB_data <- read.csv(CRB_file, header = TRUE)


FARM_SONA_file = 'Task3/SONA/data_exp_165230-v4_task-mlz1.csv' #gorilla saves all subjects data (i.e., data_all.csv)
FARM_SONA_data <- read.csv(FARM_SONA_file, header = TRUE)
FARM_PROLIFIC_file = 'Task3/Prolific/data_exp_155438-v5_task-mlz1.csv' #gorilla saves all subjects data (i.e., data_all.csv)
FARM_PROLIFIC_data <- read.csv(FARM_PROLIFIC_file, header = TRUE)
FARM_data <- rbind(FARM_SONA_data,FARM_PROLIFIC_data)
# FARM_data_to_exclude = c('63126caf43d014aa6db9a1d4') # --> uncomment line 78

FARB_file = 'Task4/Prolific/data_exp_170303-v3_task-hoyh.csv' #gorilla saves all subjects data (i.e., data_all.csv)
FARB_data <- read.csv(FARB_file, header = TRUE)
# FARB_data_to_exclude = c('63126caf43d014aa6db9a1d4') # --> uncomment line 78

rm(CRM_prolific_file,CRM_SONA_file,FARM_SONA_file,CRB_file,FARM_PROLIFIC_file,FARB_file)

###############################################
# Functions to clean up data
###############################################
data_select <- function(data){
  data_select = select(data, c('Participant.Public.ID','Response',
                               'Spreadsheet..T1','Spreadsheet..T2','Spreadsheet..T3','Spreadsheet..T4','Spreadsheet..T5',
                               'Spreadsheet..interrupter'))
  
  names(data_select) = c('ID','response','T1','T2','T3','T4','T5','interrupter')
  data_select = data_select[data_select$response %in% c('b','d','g'),]
  
}

cleaned_up_data <- function(data){
  data$helper = rep(c(1,2,3,4,5),nrow(data)/5)
  data$intCond = as.integer(data$interrupter != '') #seeing which has interrupter 
  data$res1 = rep(data[data$helper==1,]$response,each=5) 
  data$res2 = rep(data[data$helper==2,]$response,each=5) 
  data$res3 = rep(data[data$helper==3,]$response,each=5) 
  data$res4 = rep(data[data$helper==4,]$response,each=5) 
  data$res5 = rep(data[data$helper==5,]$response,each=5) 
  cleaned_up_data = data[data$helper==1,]
  cleaned_up_data = subset(cleaned_up_data, select=-c(response,helper))
  
  # data_anech_clean = data_anech_clean[!(data_anech_clean$ID %in% data_to_exclude),] #only run this if using subject ID that did BAD
  #initializing the score
  cleaned_up_data$score1 = 99
  cleaned_up_data$score2 = 99
  cleaned_up_data$score3 = 99
  cleaned_up_data$score4 = 99
  cleaned_up_data$score5 = 99
  # "logical" score if you got right or not
  for (i in 1:nrow(cleaned_up_data)) {
    cleaned_up_data[i,]$T1 = substr(strsplit(cleaned_up_data[i,]$T1,'_')[[1]][1],1,1) 
    cleaned_up_data[i,]$T2 = substr(strsplit(cleaned_up_data[i,]$T2,'_')[[1]][1],1,1)
    cleaned_up_data[i,]$T3 = substr(strsplit(cleaned_up_data[i,]$T3,'_')[[1]][1],1,1)
    cleaned_up_data[i,]$T4 = substr(strsplit(cleaned_up_data[i,]$T4,'_')[[1]][1],1,1)
    cleaned_up_data[i,]$T5 = substr(strsplit(cleaned_up_data[i,]$T5,'_')[[1]][1],1,1)
    cleaned_up_data[i,]$interrupter = strsplit(cleaned_up_data[i,]$interrupter,'_')[[1]][2]
    cleaned_up_data[i,]$score1 = as.integer(cleaned_up_data[i,]$res1==cleaned_up_data[i,]$T1)
    cleaned_up_data[i,]$score2 = as.integer(cleaned_up_data[i,]$res2==cleaned_up_data[i,]$T2)
    cleaned_up_data[i,]$score3 = as.integer(cleaned_up_data[i,]$res3==cleaned_up_data[i,]$T3)
    cleaned_up_data[i,]$score4 = as.integer(cleaned_up_data[i,]$res4==cleaned_up_data[i,]$T4)
    cleaned_up_data[i,]$score5 = as.integer(cleaned_up_data[i,]$res5==cleaned_up_data[i,]$T5)
  }
  
  # summarize avg for each subject 
  cleaned_up_data$intCond = factor(cleaned_up_data$intCond,levels = c(0,1), labels = c('uninterrupted','interrupted'))
  return(cleaned_up_data)
}

  # Summarize average for each subject --> not including syllable 1
    # data_summary <- function(cleaned_up_data){
    #   # cleaned_up_data$intCond = factor(cleaned_up_data$intCond,levels = c(0,1), labels = c('uninterrupted','interrupted'))
    #   data_summary = cleaned_up_data %>%
    #     dplyr::group_by(ID,intCond) %>%
    #     dplyr::summarise(sylb2 = mean(score2),sylb3 = mean(score3),sylb4 = mean(score4),sylb5 = mean(score5))
    # }
# Summarize average for each subject

data_summary <- function(cleaned_up_data){
  # cleaned_up_data$intCond = factor(cleaned_up_data$intCond,levels = c(0,1), labels = c('uninterrupted','interrupted'))
  data_summary = cleaned_up_data %>%
    dplyr::group_by(ID,intCond) %>%
    dplyr::summarise(sylb1 = mean(score1),sylb2 = mean(score2),sylb3 = mean(score3),sylb4 = mean(score4),sylb5 = mean(score5))
}

# Reform data frame
data_reform <- function(data_summary){
  data_reform = reshape2::melt(data_summary, 
                               id.vars = c('ID','intCond'),
                               variable.name = 'sylb',
                               value.name = 'accuracy')
}

# Create difference data
data_difference <- function(data_reform){
  data_to_difference <- data_reform
  data_to_difference[data_to_difference$intCond == 'interrupted',]$accuracy = - data_to_difference[data_to_difference$intCond == 'interrupted',]$accuracy
  
  data_difference = data_to_difference %>%
    dplyr::group_by(ID, sylb) %>%
    dplyr::summarise(diff = sum(accuracy))
}

# Function outputs 
CRM_data_select = data_select(CRM_data)
CRM_data_reverb = with(CRM_data_select,CRM_data_select[grepl("rev",CRM_data_select$T1) | grepl("rev",CRM_data_select$T2) | grepl("rev",CRM_data_select$T3) |grepl("rev",CRM_data_select$T4) | grepl("rev",CRM_data_select$T5),])
CRM_data_anech = with(CRM_data_select,CRM_data_select[grepl("anec",CRM_data_select$T1) | grepl("anec",CRM_data_select$T2) | grepl("anec",CRM_data_select$T3) |grepl("anec",CRM_data_select$T4) | grepl("anec",CRM_data_select$T5),])
CRM_reverb_data_cleaned = cleaned_up_data(CRM_data_reverb)
CRM_anech_data_cleaned = cleaned_up_data(CRM_data_anech)

# CRM_anech_data_cleaned = CRM_anech_data_cleaned[!(CRM_anech_data_cleaned$ID %in% unique(CRM_data_to_exclude)),]
# CRM_reverb_data_cleaned = CRM_reverb_data_cleaned[!(CRM_reverb_data_cleaned$ID %in% unique(CRM_data_to_exclude)),]


CRM_reverb_data_summary = data_summary(CRM_reverb_data_cleaned)
CRM_anech_data_summary = data_summary(CRM_anech_data_cleaned)
CRM_reverb_data_reform = data_reform(CRM_reverb_data_summary)
CRM_anech_data_reform = data_reform(CRM_anech_data_summary)
CRM_reverb_data_difference = data_difference(CRM_reverb_data_reform)
CRM_anech_data_difference = data_difference(CRM_anech_data_reform)

CRB_data_select = data_select(CRB_data)
CRB_data_reverb = with(CRB_data_select,CRB_data_select[grepl("rev",CRB_data_select$T1) | grepl("rev",CRB_data_select$T2) | grepl("rev",CRB_data_select$T3) |grepl("rev",CRB_data_select$T4) | grepl("rev",CRB_data_select$T5),])
CRB_data_anech = with(CRB_data_select,CRB_data_select[grepl("anec",CRB_data_select$T1) | grepl("anec",CRB_data_select$T2) | grepl("anec",CRB_data_select$T3) |grepl("anec",CRB_data_select$T4) | grepl("anec",CRB_data_select$T5),])

CRB_reverb_data_cleaned = cleaned_up_data(CRB_data_reverb)
CRB_anech_data_cleaned = cleaned_up_data(CRB_data_anech)

# CRB_anech_data_cleaned = CRB_anech_data_cleaned[!(CRB_anech_data_cleaned$ID %in% unique(CRB_data_to_exclude)),]
# CRB_reverb_data_cleaned = CRB_reverb_data_cleaned[!(CRB_reverb_data_cleaned$ID %in% unique(CRB_data_to_exclude)),]


CRB_reverb_data_summary = data_summary(CRB_reverb_data_cleaned)
CRB_anech_data_summary = data_summary(CRB_anech_data_cleaned)
CRB_reverb_data_reform = data_reform(CRB_reverb_data_summary)
CRB_anech_data_reform = data_reform(CRB_anech_data_summary)
CRB_reverb_data_difference = data_difference(CRB_reverb_data_reform)
CRB_anech_data_difference = data_difference(CRB_anech_data_reform)


FARM_data_select = data_select(FARM_data)
FARM_data_reverb = with(FARM_data_select,FARM_data_select[grepl("rev",FARM_data_select$T1) | grepl("rev",FARM_data_select$T2) | grepl("rev",FARM_data_select$T3) |grepl("rev",FARM_data_select$T4) | grepl("rev",FARM_data_select$T5),])
FARM_data_anech = with(FARM_data_select,FARM_data_select[grepl("anec",FARM_data_select$T1) | grepl("anec",FARM_data_select$T2) | grepl("anec",FARM_data_select$T3) |grepl("anec",FARM_data_select$T4) | grepl("anec",FARM_data_select$T5),])
FARM_reverb_data_cleaned = cleaned_up_data(FARM_data_reverb)
FARM_anech_data_cleaned = cleaned_up_data(FARM_data_anech)

# FARM_anech_data_cleaned = FARM_anech_data_cleaned[!(FARM_anech_data_cleaned$ID %in% unique(FARM_data_to_exclude)),]
# FARM_reverb_data_cleaned = FARM_reverb_data_cleaned[!(FARM_reverb_data_cleaned$ID %in% unique(FARM_data_to_exclude)),]

FARM_reverb_data_summary = data_summary(FARM_reverb_data_cleaned)
FARM_anech_data_summary = data_summary(FARM_anech_data_cleaned)
FARM_reverb_data_reform = data_reform(FARM_reverb_data_summary)
FARM_anech_data_reform = data_reform(FARM_anech_data_summary)
FARM_reverb_data_difference = data_difference(FARM_reverb_data_reform)
FARM_anech_data_difference = data_difference(FARM_anech_data_reform)

FARB_data_select = data_select(FARB_data)
FARB_data_reverb = with(FARB_data_select,FARB_data_select[grepl("rev",FARB_data_select$T1) | grepl("rev",FARB_data_select$T2) | grepl("rev",FARB_data_select$T3) |grepl("rev",FARB_data_select$T4) | grepl("rev",FARB_data_select$T5),])
FARB_data_anech = with(FARB_data_select,FARB_data_select[grepl("anec",FARB_data_select$T1) | grepl("anec",FARB_data_select$T2) | grepl("anec",FARB_data_select$T3) |grepl("anec",FARB_data_select$T4) | grepl("anec",FARB_data_select$T5),])
FARB_reverb_data_cleaned = cleaned_up_data(FARB_data_reverb)
FARB_anech_data_cleaned = cleaned_up_data(FARB_data_anech)

# FARB_anech_data_cleaned = FARB_anech_data_cleaned[!(FARB_anech_data_cleaned$ID %in% unique(FARB_data_to_exclude)),]
# FARB_reverb_data_cleaned = FARB_reverb_data_cleaned[!(FARB_reverb_data_cleaned$ID %in% unique(FARB_data_to_exclude)),]

FARB_reverb_data_summary = data_summary(FARB_reverb_data_cleaned)
FARB_anech_data_summary = data_summary(FARB_anech_data_cleaned)
FARB_reverb_data_reform = data_reform(FARB_reverb_data_summary)
FARB_anech_data_reform = data_reform(FARB_anech_data_summary)
FARB_reverb_data_difference = data_difference(FARB_reverb_data_reform)
FARB_anech_data_difference = data_difference(FARB_anech_data_reform)

# find suspicious subjects
# CRM_anech_data_suspicious = CRM_anech_data_summary[CRM_anech_data_summary$intCond=='uninterrupted' & (CRM_anech_data_summary$sylb1<=0.4 | CRM_anech_data_summary$sylb2<0.4 | CRM_anech_data_summary$sylb3<0.4 | CRM_anech_data_summary$sylb4<0.4 | CRM_anech_data_summary$sylb5<0.4),]
# CRM_reverb_data_suspicious = CRM_reverb_data_summary[CRM_reverb_data_summary$intCond=='uninterrupted' & (CRM_reverb_data_summary$sylb1<=0.4 | CRM_reverb_data_summary$sylb2<0.4 | CRM_reverb_data_summary$sylb3<0.4 | CRM_reverb_data_summary$sylb4<0.4 | CRM_reverb_data_summary$sylb5<0.4),]
# # CRM_anech_data_to_exclude = c('5c475608cae0ab000188cb6e','604011377e5b121dc3267a3e','64d90ef50ad4204b1babb416','650864c7d8cb07fb933c1c20')
# # CRM_revebr_data_to_exclude = c('5c475608cae0ab000188cb6e','604011377e5b121dc3267a3e','64358f9eb05899a85826382d','64d90ef50ad4204b1babb416','650864c7d8cb07fb933c1c20')
# CRM_data_to_exclude = c('5c475608cae0ab000188cb6e','604011377e5b121dc3267a3e','64d90ef50ad4204b1babb416','650864c7d8cb07fb933c1c20')
# 
# CRB_anech_data_suspicious = CRB_anech_data_summary[CRB_anech_data_summary$intCond=='uninterrupted' & (CRB_anech_data_summary$sylb1<=0.4 | CRB_anech_data_summary$sylb2<0.4 | CRB_anech_data_summary$sylb3<0.4 | CRB_anech_data_summary$sylb4<0.4 | CRB_anech_data_summary$sylb5<0.4),]
#   # 6018a5c0e1600b187ccb8693, 604011377e5b121dc3267a3e, 615dbec57d764bf5ab0a56e5, 62b0ff84054c6ca32f481c65, 636548d16d8486ac6e2c9332
# CRB_reverb_data_suspicious = CRB_reverb_data_summary[CRB_reverb_data_summary$intCond=='uninterrupted' & (CRB_reverb_data_summary$sylb1<=0.4 | CRB_reverb_data_summary$sylb2<0.4 | CRB_reverb_data_summary$sylb3<0.4 | CRB_reverb_data_summary$sylb4<0.4 | CRB_reverb_data_summary$sylb5<0.4),]
#   # 6018a5c0e1600b187ccb8693, 604011377e5b121dc3267a3e, 615dbec57d764bf5ab0a56e5, 62b0ff84054c6ca32f481c65, 636548d16d8486ac6e2c9332, 645e4f49d473048703d162cb
# CRB_data_to_exclude = c('6018a5c0e1600b187ccb8693','604011377e5b121dc3267a3e','615dbec57d764bf5ab0a56e5','62b0ff84054c6ca32f481c65','636548d16d8486ac6e2c9332')
# 
# FARM_anech_data_suspicious = FARM_anech_data_summary[FARM_anech_data_summary$intCond=='uninterrupted' & (FARM_anech_data_summary$sylb1<=0.4 | FARM_anech_data_summary$sylb2<0.4 | FARM_anech_data_summary$sylb3<0.4 | FARM_anech_data_summary$sylb4<0.4 | FARM_anech_data_summary$sylb5<0.4),]
#   # 60fcefe49e61a0aa689df3c8, 6422f34be2b8257efb345837, 6487901ef9fad1bfcf43daa5, 6519acc6f9bfe443695ff316, 655f8b6aead3b1448f52681b
# FARM_reverb_data_suspicious = FARM_reverb_data_summary[FARM_reverb_data_summary$intCond=='uninterrupted' & (FARM_reverb_data_summary$sylb1<=0.4 | FARM_reverb_data_summary$sylb2<0.4 | FARM_reverb_data_summary$sylb3<0.4 | FARM_reverb_data_summary$sylb4<0.4 | FARM_reverb_data_summary$sylb5<0.4),]
#   # 60fcefe49e61a0aa689df3c8, 6519acc6f9bfe443695ff316, 655f8b6aead3b1448f52681b, 65c243c37e0d77ca70ee030e
# FARM_data_to_exclude = c('60fcefe49e61a0aa689df3c8','6519acc6f9bfe443695ff316','655f8b6aead3b1448f52681b')
# 
# FARB_anech_data_suspicious = FARB_anech_data_summary[FARB_anech_data_summary$intCond=='uninterrupted' & (FARB_anech_data_summary$sylb1<=0.4 | FARB_anech_data_summary$sylb2<0.4 | FARB_anech_data_summary$sylb3<0.4 | FARB_anech_data_summary$sylb4<0.4 | FARB_anech_data_summary$sylb5<0.4),]
#   # 605a2dbead400eae8de18f8c, 60e8b06bfb1c78d450ae9f79, 64db68476c022a6c20686908, 651dc3d05cac9714062c2034, 6547bf8012d4702680d55663, 65cefb1a4565306b90516a56
# FARB_reverb_data_suspicious = FARB_reverb_data_summary[FARB_reverb_data_summary$intCond=='uninterrupted' & (FARB_reverb_data_summary$sylb1<=0.4 | FARB_reverb_data_summary$sylb2<0.4 | FARB_reverb_data_summary$sylb3<0.4 | FARB_reverb_data_summary$sylb4<0.4 | FARB_reverb_data_summary$sylb5<0.4),]
#   # 58a229e74d580c0001e0a766, 605a2dbead400eae8de18f8c, 60e8b06bfb1c78d450ae9f79, 632b947efa9da6a9bde31f94, 64db68476c022a6c20686908, 651dc3d05cac9714062c2034, 
#     # 6547bf8012d4702680d55663, 65d563ecf8df20ade2f17888
# FARB_data_to_exclude = c('605a2dbead400eae8de18f8c','60e8b06bfb1c78d450ae9f79','64db68476c022a6c20686908','651dc3d05cac9714062c2034','6547bf8012d4702680d55663')

####

###############################################
# CRM 
###############################################
CRM_anech_data_selected = CRM_anech_data_reform %>%
  add_column(envCond="anech") %>% 
  add_column(task="CRM")
CRM_anech_data_selected

CRM_reverb_data_selected = CRM_reverb_data_reform %>%
  add_column(envCond="reverb") %>% 
  add_column(task="CRM")
CRM_reverb_data_selected

CRM_combined_data = rbind(CRM_anech_data_selected,CRM_reverb_data_selected)

CRM_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF")
CRM_uninter_color_palette = c("#FF0000", "#3333FF")
# my_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF","#EFBBFF","#643B9F","#B3CF99","#658354")
# anech_color_palette = c("#6286c6", "#6c4a55")
title_size = 16
axis_size = 16
label_size = 14

#### Raw Syllable -- all 4 conditions
# CRM_raw_syllable_plot = CRM_combined_data %>%
#   ggplot(aes(x = sylb,y = accuracy,color = interaction(envCond,intCond),group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
#   stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
#   geom_boxplot(aes(fill=interaction(envCond,intCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
#   stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=interaction(envCond,intCond)),
#                geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
#   scale_color_manual(values=CRM_color_palette) +
#   scale_fill_manual(values=CRM_color_palette) +
#   ggtitle("Raw Syllable Identification Performance: CRM (Excluding suspicious subjects) ") +
#   # ggtitle("Raw Syllable Identification Performance: CRM ") +
#   ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
#   xlab("Syllable") +
#   theme(
#     plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
#     axis.title.x = element_text(size=axis_size, face="bold"),
#     axis.title.y = element_text(size=axis_size, face="bold"),
#     axis.text.x = element_text(face="bold", size=label_size),
#     axis.text.y = element_text(face="bold", size=label_size)
#   )
# CRM_raw_syllable_plot

#### Uninterrupted Condition 
CRM_uninter_data <- filter(CRM_combined_data, intCond == "uninterrupted")
CRM_raw_syllable_uninterrupted_plot = CRM_uninter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRM_uninter_color_palette) +
  scale_fill_manual(values=CRM_uninter_color_palette) +
  ggtitle("Raw Syllable Identification Performance: CRM\n Uninterrupted Condition (Excluding suspicious subjects) ") +
  # ggtitle("Raw Syllable Identification Performance: CRM\n Uninterrupted Condition ") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
CRM_raw_syllable_uninterrupted_plot

#### Interrupted Condition 
CRM_inter_data <- filter(CRM_combined_data, intCond == "interrupted")
CRM_raw_syllable_interrupted_plot = CRM_inter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRM_uninter_color_palette) +
  scale_fill_manual(values=CRM_uninter_color_palette) +
  ggtitle("Raw Syllable Identification Performance: CRM\n Interrupted Condition (Excluding suspicious subjects)") +
  # ggtitle("Raw Syllable Identification Performance: CRM\n Interrupted Condition ") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
CRM_raw_syllable_interrupted_plot

#### Effect of Interrupter Plots
CRM_anech_data_difference_labeled =CRM_anech_data_difference %>%
  add_column(envCond="anech") 
CRM_anech_data_difference_labeled

CRM_reverb_data_difference_labeled = CRM_reverb_data_difference %>%
  add_column(envCond="reverb") 
CRM_reverb_data_difference_labeled

CRM_difference_data = rbind(CRM_anech_data_difference_labeled,CRM_reverb_data_difference_labeled)

CRM_diff_plot = CRM_difference_data %>%
  ggplot(aes(x = sylb,y = diff, color=envCond, group = interaction(sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = diff,group = interaction(sylb,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRM_color_palette) + 
  scale_fill_manual(values=CRM_color_palette) +
  scale_x_discrete(labels=c("sylb1" = "1","sylb2" = "2","sylb3" = "3"
                            ,"sylb4" = "4","sylb5" = "5",
                            "diff.sylb1" = "","diff.sylb2" = "","diff.sylb3" = "","diff.sylb4" = "","diff.sylb5" = "")) + 
                     # guide = guide_legend(override.aes = list(alpha = 0))) +
  # scale_linetype(guide = guide_legend(override.aes = list(alpha = 0))) +
  ggtitle("Syllable Identification Performance Difference\n CRM (N=45)") +
  ylab("Effect of Interrupter\n -- (% Difference)") +
  xlab("Syllable") +
  # ylim(-0.3,1) +
  theme_bw() + 
  theme(
    panel.grid.major = element_blank(),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  )

CRM_diff_plot

#### STATS
library(ez)
CRM_omnibus_anova <- ezANOVA(data=CRM_combined_data, wid=ID, within=.(sylb,intCond,envCond), dv=accuracy, type = 3, detailed=TRUE)
CRM_omnibus_anova
# Effect DFn DFd          SSn        SSd           F            p p<.05          ges
# 1          (Intercept)   1  44 5.242192e+02 28.3748264 812.8911092 5.251438e-30     * 9.373804e-01
# 2                 sylb   4 176 2.514140e+00  2.5450617  43.4654075 2.470861e-25     * 6.698401e-02
# 3              intCond   1  44 8.075019e-01  0.6076890  58.4675424 1.305553e-09     * 2.253905e-02
# 4              envCond   1  44 2.100694e-03  0.2332292   0.3963079 5.322576e-01       5.998318e-05
# 5         sylb:intCond   4 176 8.772878e-01  1.2392052  31.1495321 1.306402e-19     * 2.443932e-02
# 6         sylb:envCond   4 176 2.412423e-02  0.7288272   1.4564030 2.175074e-01       6.884098e-04
# 7      intCond:envCond   1  44 8.150077e-03  0.3879437   0.9243697 3.415843e-01       2.326769e-04
# 8 sylb:intCond:envCond   4 176 3.342978e-02  0.9025077   1.6298038 1.687689e-01       9.537001e-04

# There is an effect of syllable
CRM_descriptive_stats_sylb= summarySE(summarySE(CRM_combined_data, measurevar = "accuracy",groupvars = c("ID","sylb","envCond")),measurevar = "accuracy",groupvars = c("sylb","envCond"))
CRM_descriptive_stats_sylb
# sylb envCond  N  accuracy        sd         se         ci
# 1  sylb1   anech 45 0.8393519 0.2042991 0.03045511 0.06137825
# 2  sylb1  reverb 45 0.8537037 0.1927653 0.02873576 0.05791312
# 3  sylb2   anech 45 0.7865741 0.1953914 0.02912722 0.05870206
# 4  sylb2  reverb 45 0.7833333 0.2071653 0.03088238 0.06223934
# 5  sylb3   anech 45 0.6976852 0.1755797 0.02617388 0.05275000
# 6  sylb3  reverb 45 0.6814815 0.1777018 0.02649022 0.05338753
# 7  sylb4   anech 45 0.7296296 0.1858348 0.02770262 0.05583096
# 8  sylb4  reverb 45 0.7296296 0.1769713 0.02638132 0.05316806
# 9  sylb5   anech 45 0.7703704 0.1948521 0.02904684 0.05854006
# 10 sylb5  reverb 45 0.7601852 0.1899369 0.02831413 0.05706337

# There is an effect of interrupter
CRM_descriptive_stats_int= summarySE(summarySE(CRM_combined_data, measurevar = "accuracy",groupvars = c("ID","intCond","envCond")),measurevar = "accuracy",groupvars = c("intCond","envCond"))
CRM_descriptive_stats_int
# intCond envCond  N  accuracy        sd         se         ci
# 1 uninterrupted   anech 45 0.7916667 0.1900708 0.02833408 0.05710358
# 2 uninterrupted  reverb 45 0.7946296 0.1971239 0.02938549 0.05922256
# 3   interrupted   anech 45 0.7377778 0.1767910 0.02635444 0.05311389
# 4   interrupted  reverb 45 0.7287037 0.1682928 0.02508761 0.05056075

# There is a significant interaction between syllable & intCond
CRM_tukey.test = TukeyHSD(aov(accuracy ~ sylb + intCond + sylb * intCond, data = CRM_combined_data))
CRM_tukey.test
###############################################
# CRB 
###############################################
CRB_anech_data_selected = CRB_anech_data_reform %>%
  add_column(envCond="anech") %>% 
  add_column(task="CRB")
CRB_anech_data_selected

CRB_reverb_data_selected = CRB_reverb_data_reform %>%
  add_column(envCond="reverb") %>% 
  add_column(task="CRB")
CRB_reverb_data_selected

CRB_combined_data = rbind(CRB_anech_data_selected,CRB_reverb_data_selected)

CRB_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF")
CRB_uninter_color_palette = c("#FF0000", "#3333FF")
# my_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF","#EFBBFF","#643B9F","#B3CF99","#658354")
# anech_color_palette = c("#6286c6", "#6c4a55")
title_size = 16

axis_size = 16
label_size = 14

#### Raw Syllable -- all 4 conditions
# CRB_raw_syllable_plot = CRB_combined_data %>%
#   ggplot(aes(x = sylb,y = accuracy,color = interaction(envCond,intCond),group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
#   stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
#   geom_boxplot(aes(fill=interaction(envCond,intCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
#   stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=interaction(envCond,intCond)),
#                geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
#   scale_color_manual(values=CRM_color_palette) +
#   scale_fill_manual(values=CRM_color_palette) +
#   ggtitle("Raw Syllable Identification Performance: CRB ") +
#   ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
#   xlab("Syllable") +
#   theme(
#     plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
#     axis.title.x = element_text(size=axis_size, face="bold"),
#     axis.title.y = element_text(size=axis_size, face="bold"),
#     axis.text.x = element_text(face="bold", size=label_size),
#     axis.text.y = element_text(face="bold", size=label_size)
#   )
# CRB_raw_syllable_plot

#### Uninterrupted Condition 
CRB_uninter_data <- filter(CRB_combined_data, intCond == "uninterrupted")

CRB_raw_syllable_uninterrupted_plot = CRB_uninter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRM_uninter_color_palette) +
  scale_fill_manual(values=CRM_uninter_color_palette) +
  ggtitle("Raw Syllable Identification Performance: CRB\n Uninterrupted Condition (Excluding suspicious subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
CRB_raw_syllable_uninterrupted_plot

#### Interrupted Condition 
CRB_inter_data <- filter(CRB_combined_data, intCond == "interrupted")
CRB_raw_syllable_interrupted_plot = CRB_inter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRM_uninter_color_palette) +
  scale_fill_manual(values=CRM_uninter_color_palette) +
  ggtitle("Raw Syllable Identification Performance: CRB\n Interrupted Condition (Excluding Suspicious Subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
CRB_raw_syllable_interrupted_plot

#### Effect of Interrupter Plots
CRB_anech_data_difference_labeled =CRB_anech_data_difference %>%
  add_column(envCond="anech") 
CRB_anech_data_difference_labeled

CRB_reverb_data_difference_labeled = CRB_reverb_data_difference %>%
  add_column(envCond="reverb") 
CRB_reverb_data_difference_labeled

CRB_difference_data = rbind(CRB_anech_data_difference_labeled,CRB_reverb_data_difference_labeled)

CRB_diff_plot = CRB_difference_data %>%
  ggplot(aes(x = sylb,y = diff, color=envCond, group = interaction(sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = diff,group = interaction(sylb,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_fill_manual(values=CRB_color_palette) +
  scale_color_manual(values=CRB_color_palette) + 
  scale_x_discrete(labels=c("sylb1" = "1","sylb2" = "2","sylb3" = "3"
                            ,"sylb4" = "4","sylb5" = "5",
                            "diff.sylb1" = "","diff.sylb2" = "","diff.sylb3" = "","diff.sylb4" = "","diff.sylb5" = "")) + 
  # guide = guide_legend(override.aes = list(alpha = 0))) +
  # scale_linetype(guide = guide_legend(override.aes = list(alpha = 0))) +
  ggtitle("Syllable Identification Performance Difference\n CRB (N=40)") +
  ylab("Effect of Interrupter\n -- (% Difference)") +
  xlab("Syllable") +
  # ylim(-0.3,1) +
  theme_bw() + 
  theme(
    panel.grid.major = element_blank(),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  )

CRB_diff_plot

#### STATS
library(ez)
CRB_omnibus_anova <- ezANOVA(data=CRB_combined_data, wid=ID, within=.(sylb,intCond,envCond), dv=accuracy, type = 3, detailed=TRUE)
CRB_omnibus_anova
# Effect DFn DFd          SSn        SSd           F            p p<.05          ges
# 1          (Intercept)   1  39 3.887982e+02 27.0775499 559.9890341 9.629436e-25     * 0.9185731868
# 2                 sylb   4 156 2.617839e+00  2.8366753  35.9913246 2.734701e-21     * 0.0705943904
# 3              intCond   1  39 6.781272e-01  0.6164041  42.9052313 8.933862e-08     * 0.0192961676
# 4              envCond   1  39 7.916884e-02  0.3719596   8.3008594 6.409550e-03     * 0.0022918165
# 5         sylb:intCond   4 156 3.969271e-01  1.2464757  12.4191401 8.566971e-09     * 0.0113856982
# 6         sylb:envCond   4 156 4.827257e-02  1.0913108   1.7251092 1.471168e-01       0.0013986679
# 7      intCond:envCond   1  39 2.392578e-02  0.3688694   2.5296367 1.198005e-01       0.0006937241
# 8 sylb:intCond:envCond   4 156 8.854167e-03  0.8557292   0.4035301 8.058993e-01       0.0002568374

# There is an effect of syllable => primacy & recency
CRB_descriptive_stats_sylb= summarySE(summarySE(CRB_combined_data, measurevar = "accuracy",groupvars = c("ID","sylb","envCond")),measurevar = "accuracy",groupvars = c("sylb","envCond"))
CRB_descriptive_stats_sylb
# sylb envCond  N  accuracy        sd         se         ci
# 1  sylb1   anech 40 0.7906250 0.2159891 0.03415088 0.06907668
# 2  sylb1  reverb 40 0.7947917 0.2131155 0.03369652 0.06815765
# 3  sylb2   anech 40 0.7291667 0.2017110 0.03189331 0.06451030
# 4  sylb2  reverb 40 0.7291667 0.2058073 0.03254100 0.06582038
# 5  sylb3   anech 40 0.6234375 0.1922411 0.03039598 0.06148168
# 6  sylb3  reverb 40 0.6458333 0.1758931 0.02781114 0.05625335
# 7  sylb4   anech 40 0.6359375 0.1998813 0.03160401 0.06392514
# 8  sylb4  reverb 40 0.6744792 0.2030137 0.03209928 0.06492692
# 9  sylb5   anech 40 0.6567708 0.1972471 0.03118750 0.06308268
# 10 sylb5  reverb 40 0.6911458 0.1979736 0.03130237 0.06331503

# There is an effect of interrupter
CRB_descriptive_stats_int= summarySE(summarySE(CRB_combined_data, measurevar = "accuracy",groupvars = c("ID","intCond")),measurevar = "accuracy",groupvars = c("intCond"))
CRB_descriptive_stats_int
# intCond  N  accuracy        sd         se         ci
# 1 uninterrupted 40 0.7262500 0.2007890 0.03174754 0.06421545
# 2   interrupted 40 0.6680208 0.1751967 0.02770104 0.05603064

# There is a significant effect of envCond - people performed better in uninterrupted condition
CRB_descriptive_stats_envcond= summarySE(summarySE(CRB_combined_data, measurevar = "accuracy",groupvars = c("ID","envCond","intCond")),measurevar = "accuracy",groupvars = c("envCond","intCond"))
CRB_descriptive_stats_envcond
# envCond       intCond  N  accuracy        sd         se         ci
# 1   anech uninterrupted 40 0.7108333 0.2088003 0.03301423 0.06677759
# 3  reverb uninterrupted 40 0.7416667 0.1970762 0.03116048 0.06302803
# 2   anech   interrupted 40 0.6635417 0.1739303 0.02750079 0.05562560
# 4  reverb   interrupted 40 0.6725000 0.1820194 0.02877979 0.05821262


# Now let's see where people start to perform better in reverb
tukey.test <- TukeyHSD(aov(accuracy ~ envCond + intCond + sylb, data = CRB_combined_data))
tukey.test
plot(tukey.test)

###############################################
# Compare CRM & CRB tasks 
###############################################
CRM_combined_data$blocking <- "Mixed"
CRB_combined_data$blocking <- "Blocked"
CRB_CRM_combined = rbind(CRM_combined_data,CRB_combined_data)
  
CRB_CRM_combined_uninterrupted <- filter(CRB_CRM_combined,intCond == "uninterrupted" & envCond == "anech")

crb_crm_uninter_anech = CRB_CRM_combined_uninterrupted %>% 
  ggplot(aes(x = sylb,y = accuracy, color=interaction(task,envCond),group = interaction(sylb,task,envCond))) +
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=interaction(task,envCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(sylb,task,envCond), fill=interaction(task,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRB_color_palette) +
  scale_fill_manual(values=CRB_color_palette) + 
  ggtitle("Syllable Identification Performance Difference:\n Comparing CRM & CRB (Anechoic, Uninterrupted)") +
  ylab("Syllable Identification\n-- (% correct)") +
  xlab("Syllable") +
  theme_bw() + 
  theme(
    panel.border = element_blank(), 
    panel.grid.major = element_blank(),
    # panel.grid.minor = element_blank(), 
    axis.line = element_line(colour = "black"),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  ) 
crb_crm_uninter_anech 

CRB_CRM_combined_uninterrupted_reverb <- filter(CRB_CRM_combined,intCond == "uninterrupted" & envCond == "reverb")
crb_crm_uninter_reverb = CRB_CRM_combined_uninterrupted_reverb %>% 
  ggplot(aes(x = sylb,y = accuracy, color=interaction(task,envCond),group = interaction(sylb,task,envCond))) +
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=interaction(task,envCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(sylb,task,envCond), fill=interaction(task,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRB_color_palette) +
  scale_fill_manual(values=CRB_color_palette) + 
  ggtitle("Syllable Identification Performance Difference:\n Comparing CRM & CRB (Reverb, Uninterrupted)") +
  ylab("Syllable Identification\n-- (% correct)") +
  xlab("Syllable") +
  theme_bw() + 
  theme(
    panel.border = element_blank(), 
    panel.grid.major = element_blank(),
    # panel.grid.minor = element_blank(), 
    axis.line = element_line(colour = "black"),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  ) 
crb_crm_uninter_reverb 

CRB_CRM_combined_interrupted <- filter(CRB_CRM_combined,intCond == "interrupted" & envCond == "anech")
crb_crm_inter_anech = CRB_CRM_combined_interrupted %>% 
  ggplot(aes(x = sylb,y = accuracy, color=interaction(task,envCond),group = interaction(sylb,task,envCond))) +
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=interaction(task,envCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(sylb,task,envCond), fill=interaction(task,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRB_color_palette) +
  scale_fill_manual(values=CRB_color_palette) + 
  ggtitle("Syllable Identification Performance Difference:\n Comparing CRM & CRB (Anechoic, Interrupted)") +
  ylab("Syllable Identification\n-- (% correct)") +
  xlab("Syllable") +
  theme_bw() + 
  theme(
    panel.border = element_blank(), 
    panel.grid.major = element_blank(),
    # panel.grid.minor = element_blank(), 
    axis.line = element_line(colour = "black"),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  ) 
crb_crm_inter_anech 

CRB_CRM_combined_interrupted_reverb <- filter(CRB_CRM_combined,intCond == "interrupted" & envCond == "reverb")
crb_crm_inter_reverb = CRB_CRM_combined_interrupted_reverb %>% 
  ggplot(aes(x = sylb,y = accuracy, color=interaction(task,envCond),group = interaction(sylb,task,envCond))) +
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=interaction(task,envCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(sylb,task,envCond), fill=interaction(task,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=CRB_color_palette) +
  scale_fill_manual(values=CRB_color_palette) + 
  ggtitle("Syllable Identification Performance Difference:\n Comparing CRM & CRB (Reverb, Interrupted)") +
  ylab("Syllable Identification\n-- (% correct)") +
  xlab("Syllable") +
  theme_bw() + 
  theme(
    panel.border = element_blank(), 
    panel.grid.major = element_blank(),
    # panel.grid.minor = element_blank(), 
    axis.line = element_line(colour = "black"),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  ) 
crb_crm_inter_reverb 


CRB_CRM_omnibus_anova <- ezANOVA(data=CRB_CRM_combined, wid=ID, within=.(sylb,intCond,envCond), 
                             between =.(blocking), dv=accuracy, type = 3, detailed=TRUE)
CRB_CRM_omnibus_anova
# Effect DFn DFd          SSn        SSd            F            p p<.05          ges
# 1                    (Intercept)   1  83 9.032033e+02 55.4523763 1.351896e+03 3.867279e-53     * 9.285647e-01
# 2                       blocking   1  83 1.848196e+00 55.4523763 2.766342e+00 1.000377e-01       2.590960e-02
# 3                           sylb   4 332 5.046020e+00  5.3817371 7.782240e+01 1.673702e-46     * 6.770429e-02
# 5                        intCond   1  83 1.477721e+00  1.2240931 1.001973e+02 6.289104e-16     * 2.082412e-02
# 7                        envCond   1  83 3.002770e-02  0.6051888 4.118218e+00 4.562821e-02     * 4.319644e-04
# 4                  blocking:sylb   4 332 9.205786e-02  5.3817371 1.419765e+00 2.270277e-01       1.323121e-03
# 6               blocking:intCond   1  83 2.982168e-04  1.2240931 2.022068e-02 8.872671e-01       4.291843e-06
# 8               blocking:envCond   1  83 5.577525e-02  0.6051888 7.649424e+00 6.997647e-03     * 8.020595e-04
# 9                   sylb:intCond   4 332 1.167183e+00  2.4856809 3.897369e+01 9.539062e-27     * 1.652029e-02
# 11                  sylb:envCond   4 332 2.211698e-02  1.8201379 1.008555e+00 4.030429e-01       3.182007e-04
# 13               intCond:envCond   1  83 3.044187e-02  0.7568130 3.338573e+00 7.126754e-02       4.379199e-04
# 10         blocking:sylb:intCond   4 332 7.877576e-02  2.4856809 2.630421e+00 3.435402e-02     * 1.132437e-03
# 12         blocking:sylb:envCond   4 332 5.170031e-02  1.8201379 2.357583e+00 5.343076e-02       7.435046e-04
# 14      blocking:intCond:envCond   1  83 2.561970e-03  0.7568130 2.809723e-01 5.974799e-01       3.686986e-05
# 15          sylb:intCond:envCond   4 332 3.277619e-02  1.7582369 1.547245e+00 1.881932e-01       4.714842e-04
# 16 blocking:sylb:intCond:envCond   4 332 8.062137e-03  1.7582369 3.805843e-01 8.224843e-01       1.160148e-04


# Sig interaction between blocking & envCond
CRB_descriptive_stats_blocking_envcond= summarySE(summarySE(CRB_CRM_combined, measurevar = "accuracy",groupvars = c("ID","envCond","blocking")),measurevar = "accuracy",groupvars = c("envCond","blocking"))
CRB_descriptive_stats_blocking_envcond
# envCond blocking  N  accuracy        sd         se         ci
# 1   anech  Blocked 40 0.6871875 0.1886265 0.02982446 0.06032567
# 2   anech    Mixed 45 0.7647222 0.1807357 0.02694249 0.05429902
# 3  reverb  Blocked 40 0.7070833 0.1865567 0.02949721 0.05966374
# 4  reverb    Mixed 45 0.7616667 0.1798691 0.02681331 0.05403867
    #difference in blocking & mixed is what's driving effect??

  # the doesn't need to be a cross over for there to be a significant interaction. 
  # in this case, the difference between mixed/blocked in anech and reverb are significantly different from each other
  # there's an interaction & doesnt survive correction for multiple corrections so not worth interpreting the interaction; simple effect is not there in either group alone 

# Now let's see if the interactions are significant
tukey_crm_crb.test <- TukeyHSD(aov(accuracy ~ envCond + intCond + sylb + blocking + envCond*blocking, data = CRB_CRM_combined))
tukey_crm_crb.test
  # Tukey multiple comparisons of means
  # 95% family-wise confidence level
  # 
  # Fit: aov(formula = accuracy ~ envCond + intCond + sylb + blocking + envCond * blocking, data = CRB_CRM_combined)
  # 
  # $envCond
  # diff         lwr        upr     p adj
  # reverb-anech 0.007745098 -0.01174951 0.02723971 0.4359472
  # 
  # $intCond
  # diff         lwr         upr p adj
  # interrupted-uninterrupted -0.05911765 -0.07861226 -0.03962304     0
  # 
  # $sylb
  # diff         lwr          upr     p adj
  # sylb2-sylb1 -0.06250000 -0.10541439 -0.019585608 0.0006935
  # sylb3-sylb1 -0.15747549 -0.20038988 -0.114561098 0.0000000
  # sylb4-sylb1 -0.12659314 -0.16950753 -0.083678745 0.0000000
  # sylb5-sylb1 -0.09889706 -0.14181145 -0.055982667 0.0000000
  # sylb3-sylb2 -0.09497549 -0.13788988 -0.052061098 0.0000000
  # sylb4-sylb2 -0.06409314 -0.10700753 -0.021178745 0.0004555
  # sylb5-sylb2 -0.03639706 -0.07931145  0.006517333 0.1402202
  # sylb4-sylb3  0.03088235 -0.01203204  0.073796745 0.2836573
  # sylb5-sylb3  0.05857843  0.01566404  0.101492823 0.0018660
  # sylb5-sylb4  0.02769608 -0.01521831  0.070610470 0.3961150
  # 
  # $blocking
  # diff       lwr        upr p adj
  # Mixed-Blocked 0.06605903 0.0465306 0.08558746     0
  # 
  # $`envCond:blocking`
  # diff         lwr        upr     p adj
  # reverb:Blocked-anech:Blocked  0.019895833 -0.01736361 0.05715528 0.5164065
  # anech:Mixed-anech:Blocked     0.077534722  0.04132505 0.11374439 0.0000003
  # reverb:Mixed-anech:Blocked    0.074479167  0.03826950 0.11068884 0.0000008
  # anech:Mixed-reverb:Blocked    0.057638889  0.02142922 0.09384856 0.0002598
  # reverb:Mixed-reverb:Blocked   0.054583333  0.01837366 0.09079300 0.0006358
  # reverb:Mixed-anech:Mixed     -0.003055556 -0.03818410 0.03207298 0.9960532

plot(tukey_crm_crb.test)

###############################################
# FARM 
###############################################
FARM_anech_data_selected = FARM_anech_data_reform %>%
  add_column(envCond="anech") %>% 
  add_column(task="FARM")
FARM_anech_data_selected

FARM_reverb_data_selected = FARM_reverb_data_reform %>%
  add_column(envCond="reverb") %>% 
  add_column(task="FARM")
FARM_reverb_data_selected

FARM_combined_data = rbind(FARM_anech_data_selected,FARM_reverb_data_selected)

FARM_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF")
FARM_uninter_color_palette = c("#FF0000", "#3333FF")
# my_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF","#EFBBFF","#643B9F","#B3CF99","#658354")
# anech_color_palette = c("#6286c6", "#6c4a55")
title_size = 16
axis_size = 16
label_size = 14

#### Raw Syllable -- all 4 conditions
# FARM_raw_syllable_plot = FARM_combined_data %>%
#   ggplot(aes(x = sylb,y = accuracy,color = interaction(envCond,intCond),group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
#   stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
#   geom_boxplot(aes(fill=interaction(envCond,intCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
#   stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=interaction(envCond,intCond)),
#                geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
#   scale_color_manual(values=FARM_color_palette) +
#   scale_fill_manual(values=FARM_color_palette) +
#   ggtitle("Raw Syllable Identification Performance: FARM ") +
#   ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
#   xlab("Syllable") +
#   theme(
#     plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
#     axis.title.x = element_text(size=axis_size, face="bold"),
#     axis.title.y = element_text(size=axis_size, face="bold"),
#     axis.text.x = element_text(face="bold", size=label_size),
#     axis.text.y = element_text(face="bold", size=label_size)
#   )
# FARM_raw_syllable_plot

#### Uninterrupted Condition 
FARM_uninter_data <- filter(FARM_combined_data, intCond == "uninterrupted")
FARM_raw_syllable_uninterrupted_plot = FARM_uninter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARM_color_palette) +
  scale_fill_manual(values=FARM_color_palette) +
  ggtitle("Raw Syllable Identification Performance: FARM\n Uninterrupted Condition (Excluding suspicious subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
FARM_raw_syllable_uninterrupted_plot

#### Interrupted Condition 
FARM_inter_data <- filter(FARM_combined_data, intCond == "interrupted")
FARM_raw_syllable_interrupted_plot = FARM_inter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARM_color_palette) +
  scale_fill_manual(values=FARM_color_palette) +
  ggtitle("Raw Syllable Identification Performance: FARM\n Interrupted Condition (Excluding Suspicious Subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
FARM_raw_syllable_interrupted_plot

#### Effect of Interrupter Plots
FARM_anech_data_difference_labeled =FARM_anech_data_difference %>%
  add_column(envCond="anech") 
FARM_anech_data_difference_labeled

FARM_reverb_data_difference_labeled = FARM_reverb_data_difference %>%
  add_column(envCond="reverb") 
FARM_reverb_data_difference_labeled

FARM_difference_data = rbind(FARM_anech_data_difference_labeled,FARM_reverb_data_difference_labeled)

FARM_diff_plot = FARM_difference_data %>%
  ggplot(aes(x = sylb,y = diff, color=envCond, group = interaction(sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = diff,group = interaction(sylb,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARM_color_palette) + 
  scale_fill_manual(values=FARM_color_palette) +
  scale_x_discrete(labels=c("sylb1" = "1","sylb2" = "2","sylb3" = "3"
                            ,"sylb4" = "4","sylb5" = "5",
                            "diff.sylb1" = "","diff.sylb2" = "","diff.sylb3" = "","diff.sylb4" = "","diff.sylb5" = "")) + 
  ggtitle("Syllable Identification Performance Difference\n FARM (N=45)") +
  ylab("Effect of Interrupter\n -- (% Difference)") +
  xlab("Syllable") +
  ylim(-0.3,0.7) +
  theme_bw() + 
  theme(
    panel.grid.major = element_blank(),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  )

FARM_diff_plot

#### STATS
library(ez)
FARM_omnibus_anova <- ezANOVA(data=FARM_combined_data, wid=ID, within=.(sylb,intCond,envCond), dv=accuracy, type = 3, detailed=TRUE)
FARM_omnibus_anova
# Effect DFn DFd          SSn        SSd            F            p p<.05          ges
# 1          (Intercept)   1  43 4.324843e+02 31.5684896 589.09452552 1.000083e-26     * 9.159466e-01
# 2                 sylb   4 172 3.125324e+00  3.2620028  41.19828189 3.439408e-24     * 7.299944e-02
# 3              intCond   1  43 7.681818e-01  0.7654987  43.15071543 5.434579e-08     * 1.898816e-02
# 4              envCond   1  43 6.392045e-04  0.5816525   0.04725467 8.289393e-01       1.610562e-05
# 5         sylb:intCond   4 172 6.740925e-01  1.1924006  24.30892582 5.888333e-16     * 1.670127e-02
# 6         sylb:envCond   4 172 4.146149e-02  0.9257260   1.92588741 1.082523e-01       1.043605e-03
# 7      intCond:envCond   1  43 6.186869e-03  0.6202020   0.42894951 5.159933e-01       1.558647e-04
# 8 sylb:intCond:envCond   4 172 4.202967e-02  0.7716856   2.34198470 5.688572e-02       1.057891e-03

  # results after excluding suspicious subjects
    # Effect DFn DFd          SSn        SSd            F            p p<.05          ges
    # 1          (Intercept)   1  40 4.326453e+02 23.7600017 728.35902795 2.748876e-27     * 9.334640e-01
    # 2                 sylb   4 160 3.146278e+00  2.7578887  45.63313849 1.560445e-25     * 9.257950e-02
    # 3              intCond   1  40 8.537115e-01  0.6554031  52.10298488 9.332687e-09     * 2.693772e-02
    # 4              envCond   1  40 4.763720e-04  0.5753049   0.03312136 8.565076e-01       1.544716e-05
    # 5         sylb:intCond   4 160 7.577702e-01  1.0165354  29.81775769 1.561908e-18     * 2.398303e-02
    # 6         sylb:envCond   4 160 4.609163e-02  0.8247417   2.23544573 6.752859e-02       1.492391e-03
    # 7      intCond:envCond   1  40 7.370003e-03  0.6041751   0.48793821 4.888900e-01       2.389313e-04
    # 8 sylb:intCond:envCond   4 160 5.016514e-02  0.6442793   3.11449659 1.683065e-02     * 1.624072e-03

  # results after removing syllable 1
    # Effect DFn DFd          SSn        SSd           F            p p<.05          ges
    # 1          (Intercept)   1  43 3.199842e+02 26.7283455 514.7838822 1.478607e-25     * 9.075392e-01
    # 2                 sylb   3 129 5.860830e-01  1.6401540  15.3653676 1.320212e-08     * 1.766037e-02
    # 3              intCond   1  43 8.848273e-01  0.7951857  47.8474032 1.696155e-08     * 2.642452e-02
    # 4              envCond   1  43 1.997514e-04  0.5448306   0.0157651 9.006661e-01       6.127258e-06
    # 5         sylb:intCond   3 129 5.512819e-01  1.0252155  23.1220843 4.830491e-12     * 1.662915e-02
    # 6         sylb:envCond   3 129 4.110194e-02  0.6391281   2.7653037 4.456749e-02     * 1.259198e-03  #post hoc test: not significant
    # 7      intCond:envCond   1  43 8.012251e-03  0.6207855   0.5549853 4.603404e-01       2.457122e-04
    # 8 sylb:intCond:envCond   3 129 4.019442e-02  0.6066155   2.8491859 4.005542e-02     * 1.231430e-03

# There is an effect of syllable
FARM_descriptive_stats_sylb= summarySE(summarySE(FARM_combined_data, measurevar = "accuracy",groupvars = c("ID","sylb","envCond")),measurevar = "accuracy",groupvars = c("sylb","envCond"))
FARM_descriptive_stats_sylb
# sylb envCond  N  accuracy        sd         se         ci
# 1  sylb1   anech 44 0.8063447 0.2074876 0.03127993 0.06308200
# 2  sylb1  reverb 44 0.8106061 0.1893384 0.02854384 0.05756415
# 3  sylb2   anech 44 0.7111742 0.2323202 0.03502359 0.07063180
# 4  sylb2  reverb 44 0.7163826 0.2222674 0.03350806 0.06757545
# 5  sylb3   anech 44 0.6505682 0.1827214 0.02754629 0.05555238
# 6  sylb3  reverb 44 0.6264205 0.1728736 0.02606168 0.05255839
# 7  sylb4   anech 44 0.6482008 0.2009956 0.03030122 0.06110824
# 8  sylb4  reverb 44 0.6652462 0.2199016 0.03315141 0.06685619
# 9  sylb5   anech 44 0.6846591 0.2030627 0.03061286 0.06173671
# 10 sylb5  reverb 44 0.6908144 0.2167832 0.03268130 0.06590813

# effect of interrupter
FARM_descriptive_stats_int= summarySE(summarySE(FARM_combined_data, measurevar = "accuracy",groupvars = c("ID","intCond","envCond")),measurevar = "accuracy",groupvars = c("intCond","envCond"))
FARM_descriptive_stats_int
  # intCond envCond  N  accuracy        sd         se         ci
  # 1 uninterrupted   anech 44 0.7270833 0.2046940 0.03085878 0.06223266
  # 2 uninterrupted  reverb 44 0.7340909 0.2044705 0.03082509 0.06216472
  # 3   interrupted   anech 44 0.6732955 0.1898556 0.02862181 0.05772138
  # 4   interrupted  reverb 44 0.6696970 0.1903357 0.02869419 0.05786735

# After removing suspicious subjects, there's a significant 3-way interaction
tukey_farm.test <- TukeyHSD(aov(accuracy ~ + intCond + sylb  + sylb*intCond, data = FARM_combined_data))
tukey_farm.test

plot(tukey_farm.test)
###############################################
# FARB
###############################################
FARB_anech_data_selected = FARB_anech_data_reform %>%
  add_column(envCond="anech") %>% 
  add_column(task="FARB")
FARB_anech_data_selected

FARB_reverb_data_selected = FARB_reverb_data_reform %>%
  add_column(envCond="reverb") %>% 
  add_column(task="FARB")
FARB_reverb_data_selected

FARB_combined_data = rbind(FARB_anech_data_selected,FARB_reverb_data_selected)

FARB_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF")
FARB_uninter_color_palette = c("#FF0000", "#3333FF")
# my_color_palette = c("#FF99CC", "#FF0000","#99CCFF", "#3333FF","#EFBBFF","#643B9F","#B3CF99","#658354")
# anech_color_palette = c("#6286c6", "#6c4a55")
title_size = 16
axis_size = 16
label_size = 14

#### Raw Syllable -- all 4 conditions
# FARB_raw_syllable_plot = FARB_combined_data %>%
#   ggplot(aes(x = sylb,y = accuracy,color = interaction(envCond,intCond),group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
#   stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
#   geom_boxplot(aes(fill=interaction(envCond,intCond)), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
#   stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=interaction(envCond,intCond)),
#                geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
#   scale_color_manual(values=FARB_color_palette) +
#   scale_fill_manual(values=FARB_color_palette) +
#   ggtitle("Raw Syllable Identification Performance: FARB ") +
#   ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
#   xlab("Syllable") +
#   theme(
#     plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
#     axis.title.x = element_text(size=axis_size, face="bold"),
#     axis.title.y = element_text(size=axis_size, face="bold"),
#     axis.text.x = element_text(face="bold", size=label_size),
#     axis.text.y = element_text(face="bold", size=label_size)
#   )
# FARB_raw_syllable_plot

#### Uninterrupted Condition 
FARB_uninter_data <- filter(FARB_combined_data, intCond == "uninterrupted")
FARB_raw_syllable_uninterrupted_plot = FARB_uninter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARB_color_palette) +
  scale_fill_manual(values=FARB_color_palette) +
  ggtitle("Raw Syllable Identification Performance: FARB\n Uninterrupted Condition (Excluding Suspicious Subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
FARB_raw_syllable_uninterrupted_plot

#### Interrupted Condition 
FARB_inter_data <- filter(FARB_combined_data, intCond == "interrupted")
FARB_raw_syllable_interrupted_plot = FARB_inter_data %>%
  ggplot(aes(x = sylb,y = accuracy,color = envCond,group = interaction(intCond,sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = accuracy,group = interaction(intCond,sylb,envCond),fill=envCond),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARB_color_palette) +
  scale_fill_manual(values=FARB_color_palette) +
  ggtitle("Raw Syllable Identification Performance: FARB\n Interrupted Condition (Excluding Suspicious Subjects)") +
  ylab("Syllable Identification\n-- (% correct)") + # "Performance difference<br>-- (% correct)"
  xlab("Syllable") +
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
FARB_raw_syllable_interrupted_plot

#### Effect of Interrupter Plots
FARB_anech_data_difference_labeled =FARB_anech_data_difference %>%
  add_column(envCond="anech") 
FARB_anech_data_difference_labeled

FARB_reverb_data_difference_labeled = FARB_reverb_data_difference %>%
  add_column(envCond="reverb") 
FARB_reverb_data_difference_labeled

FARB_difference_data = rbind(FARB_anech_data_difference_labeled,FARB_reverb_data_difference_labeled)

FARB_diff_plot = FARB_difference_data %>%
  ggplot(aes(x = sylb,y = diff, color=envCond, group = interaction(sylb,envCond))) + # ,group = interaction(spaCond,subject)
  stat_boxplot(geom = "errorbar",position=position_dodge(0.8),width = 0.5,lwd=0.8,alpha = 1) +
  geom_boxplot(aes(fill=envCond), position=position_dodge(0.8),width=0.6,outlier.size = 1.5,lwd=0.8,alpha=0.3) +
  stat_summary(fun=mean,aes(x = sylb,y = diff,group = interaction(sylb,envCond)),
               geom="point", shape=23, size=2, position=position_dodge(0.8),alpha = 1) +
  scale_color_manual(values=FARB_color_palette) + 
  scale_fill_manual(values=FARB_color_palette) +
  scale_x_discrete(labels=c("sylb1" = "1","sylb2" = "2","sylb3" = "3"
                            ,"sylb4" = "4","sylb5" = "5",
                            "diff.sylb1" = "","diff.sylb2" = "","diff.sylb3" = "","diff.sylb4" = "","diff.sylb5" = "")) + 
  ggtitle("Syllable Identification Performance Difference\n FARB (N=45)") +
  ylab("Effect of Interrupter\n -- (% Difference)") +
  xlab("Syllable") +
  # ylim(-0.3,1) +
  theme_bw() + 
  theme(
    panel.grid.major = element_blank(),
    plot.title = element_text(size=title_size, face="bold",hjust = 0.5),
    axis.title.x = element_text(size=axis_size, face="bold"),
    axis.title.y = element_text(size=axis_size, face="bold"),
    axis.text.x = element_text(face="bold", size=label_size),
    axis.text.y = element_text(face="bold", size=label_size)
  )

FARB_diff_plot

#### STATS
library(ez)
FARB_omnibus_anova <- ezANOVA(data=FARB_combined_data, wid=ID, within=.(sylb,intCond,envCond), dv=accuracy, type = 3, detailed=TRUE)
FARB_omnibus_anova
# Effect DFn DFd          SSn        SSd           F            p p<.05          ges
# 1          (Intercept)   1  44 3.761984e+02 31.6272569 523.3690503 4.628067e-26     * 0.8992794858
# 2                 sylb   4 176 4.209703e+00  4.1743248  44.3729072 1.006356e-25     * 0.0908351526
# 3              intCond   1  44 6.071007e-01  0.8480208  31.4997339 1.248472e-06     * 0.0142039027
# 4              envCond   1  44 2.269464e-01  0.8941474  11.1677792 1.705701e-03     * 0.0053573521
# 5         sylb:intCond   4 176 6.472106e-01  1.3486227  21.1158160 3.088779e-14     * 0.0151281301
# 6         sylb:envCond   4 176 1.166281e-02  1.4050039   0.3652400 8.331453e-01       0.0002767214
# 7      intCond:envCond   1  44 6.267361e-03  0.4269792   0.6458486 4.259213e-01       0.0001487236
# 8 sylb:intCond:envCond   4 176 2.227238e-02  1.4103665   0.6948439 5.964569e-01       0.0005283198

# There is an effect of syllable
FARB_descriptive_stats_sylb= summarySE(summarySE(FARB_combined_data, measurevar = "accuracy",groupvars = c("ID","sylb","envCond")),measurevar = "accuracy",groupvars = c("sylb","envCond"))
FARB_descriptive_stats_sylb
# sylb envCond  N  accuracy        sd         se         ci
# 1  sylb1   anech 45 0.8393519 0.2042991 0.03045511 0.06137825
# 2  sylb1  reverb 45 0.8537037 0.1927653 0.02873576 0.05791312
# 3  sylb2   anech 45 0.7865741 0.1953914 0.02912722 0.05870206
# 4  sylb2  reverb 45 0.7833333 0.2071653 0.03088238 0.06223934
# 5  sylb3   anech 45 0.6976852 0.1755797 0.02617388 0.05275000
# 6  sylb3  reverb 45 0.6814815 0.1777018 0.02649022 0.05338753
# 7  sylb4   anech 45 0.7296296 0.1858348 0.02770262 0.05583096
# 8  sylb4  reverb 45 0.7296296 0.1769713 0.02638132 0.05316806
# 9  sylb5   anech 45 0.7703704 0.1948521 0.02904684 0.05854006
# 10 sylb5  reverb 45 0.7601852 0.1899369 0.02831413 0.05706337

# There is an effect of reverb
FARB_descriptive_stats_envCond= summarySE(summarySE(FARB_combined_data, measurevar = "accuracy",groupvars = c("ID","envCond","intCond")),measurevar = "accuracy",groupvars = c("envCond","intCond"))
FARB_descriptive_stats_envCond
# envCond       intCond  N  accuracy        sd         se         ci
# 1   anech uninterrupted 45 0.6857407 0.2029581 0.03025521 0.06097536
# 2   anech   interrupted 45 0.6390741 0.1892538 0.02821229 0.05685813
# 3  reverb uninterrupted 45 0.6592593 0.2113660 0.03150858 0.06350137
# 4  reverb   interrupted 45 0.6020370 0.1787050 0.02663976 0.05368892

  # after removing suspicious subjects
    # envCond       intCond  N  accuracy        sd         se         ci
    # 1   anech uninterrupted 40 0.7247917 0.1798077 0.02843009 0.05750528
    # 2   anech   interrupted 40 0.6725000 0.1727851 0.02731973 0.05525937
    # 3  reverb uninterrupted 40 0.6972917 0.1922130 0.03039154 0.06147269
    # 4  reverb   interrupted 40 0.6291667 0.1703650 0.02693706 0.05448535

tukey_farb.test <- TukeyHSD(aov(accuracy ~ envCond + intCond + sylb , data = FARB_combined_data))
tukey_farb.test

plot(tukey_farb.test)
###############################################
# Compare FARM & FARB tasks
###############################################
FARM_combined_data$blocking <- "Mixed"
FARB_combined_data$blocking <- "Blocked"
FARM_FARB_combined = rbind(FARM_combined_data,FARB_combined_data)

FARM_FARB_omnibus_anova <- ezANOVA(data=FARM_FARB_combined, wid=ID, within=.(sylb,intCond,envCond), 
                                 between =.(blocking), dv=accuracy, type = 3, detailed=TRUE)
FARM_FARB_omnibus_anova
# Effect DFn DFd          SSn       SSd            F            p p<.05          ges
# 1                    (Intercept)   1  87 8.079928e+02 63.195747 1.112343e+03 2.409609e-51     * 9.080456e-01
# 2                       blocking   1  87 1.322268e+00 63.195747 1.820333e+00 1.807745e-01       1.590323e-02
# 3                           sylb   4 348 7.265900e+00  7.436328 8.500611e+01 2.698933e-50     * 8.155843e-02
# 5                        intCond   1  87 1.371411e+00  1.613520 7.394567e+01 2.970206e-13     * 1.648454e-02
# 7                        envCond   1  87 1.004779e-01  1.475800 5.923279e+00 1.698724e-02     * 1.226494e-03
# 4                  blocking:sylb   4 348 5.694244e-02  7.436328 6.661881e-01 6.158427e-01       6.954435e-04
# 6               blocking:intCond   1  87 5.681038e-03  1.613520 3.063181e-01 5.813679e-01       6.942652e-05
# 8               blocking:envCond   1  87 1.245649e-01  1.475800 7.343238e+00 8.107316e-03     * 1.520068e-03
# 9                   sylb:intCond   4 348 1.287765e+00  2.541023 4.409072e+01 6.216010e-30     * 1.549468e-02
# 11                  sylb:envCond   4 348 3.091183e-02  2.330730 1.153857e+00 3.310581e-01       3.776492e-04
# 13               intCond:envCond   1  87 1.245325e-02  1.047181 1.034619e+00 3.118967e-01       1.521755e-04
# 10         blocking:sylb:intCond   4 348 3.384020e-02  2.541023 1.158627e+00 3.288858e-01       4.134102e-04
# 12         blocking:sylb:envCond   4 348 2.254729e-02  2.330730 8.416307e-01 4.994902e-01       2.754879e-04
# 14      blocking:intCond:envCond   1  87 7.093406e-08  1.047181 5.893214e-06 9.980686e-01       8.669274e-10
# 15          sylb:intCond:envCond   4 348 5.855337e-02  2.182052 2.334566e+00 5.533742e-02       7.151039e-04
# 16 blocking:sylb:intCond:envCond   4 348 5.970666e-03  2.182052 2.380548e-01 9.167413e-01       7.296573e-05

# Sig interaction between blocking & envCond
CRB_descriptive_stats_blocking_envcond= summarySE(summarySE(FARM_FARB_combined, measurevar = "accuracy",groupvars = c("ID","envCond","blocking")),measurevar = "accuracy",groupvars = c("envCond","blocking"))
CRB_descriptive_stats_blocking_envcond
# envCond blocking  N  accuracy        sd         se         ci
# 1   anech  Blocked 45 0.6624074 0.1918117 0.02859360 0.05762662
# 2   anech    Mixed 44 0.7001894 0.1929117 0.02908253 0.05865051
# 3  reverb  Blocked 45 0.6306481 0.1926669 0.02872109 0.05788355
# 4  reverb    Mixed 44 0.7018939 0.1937856 0.02921428 0.05891620
      #diff is opposite; bigger difference in reverb than anech 


# After running post-hoc tukey, there is a significant effect of randomly blocking condition: people performed significant better in reverb condition when trials were mixed 
tukey_farm_farb.test <- TukeyHSD(aov(accuracy ~ envCond + intCond + sylb + blocking + envCond*blocking, data = FARM_FARB_combined))
tukey_farm_farb.test
  # Tukey multiple comparisons of means
  # 95% family-wise confidence level
  # 
  # Fit: aov(formula = accuracy ~ envCond + intCond + sylb + blocking + envCond * blocking, data = FARM_FARB_combined)
  # 
  # $envCond
  # diff         lwr         upr     p adj
  # reverb-anech -0.01521536 -0.03538381 0.004953094 0.1391485
  # 
  # $intCond
  # diff         lwr         upr p adj
  # interrupted-uninterrupted -0.05547753 -0.07564598 -0.03530908 1e-07
  # 
  # $sylb
  # diff          lwr          upr     p adj
  # sylb2-sylb1 -0.09281367 -0.137210684 -0.048416656 0.0000001
  # sylb3-sylb1 -0.17872191 -0.223118924 -0.134324896 0.0000000
  # sylb4-sylb1 -0.16444288 -0.208839898 -0.120045870 0.0000000
  # sylb5-sylb1 -0.13038390 -0.174780909 -0.085986881 0.0000000
  # sylb3-sylb2 -0.08590824 -0.130305254 -0.041511226 0.0000014
  # sylb4-sylb2 -0.07162921 -0.116026227 -0.027232200 0.0001091
  # sylb5-sylb2 -0.03757022 -0.081967239  0.006826789 0.1418615
  # sylb4-sylb3  0.01427903 -0.030117988  0.058676040 0.9049640
  # sylb5-sylb3  0.04833801  0.003941001  0.092735029 0.0248858
  # sylb5-sylb4  0.03405899 -0.010338025  0.078456003 0.2226941
  # 
  # $blocking
  # diff        lwr        upr p adj
  # Mixed-Blocked 0.05451389 0.03434417 0.07468361 1e-07
  # 
  # $`envCond:blocking`
  # diff           lwr         upr     p adj
  # reverb:Blocked-anech:Blocked -0.031759259 -0.0689468564 0.005428338 0.1246624
  # anech:Mixed-anech:Blocked     0.037781987  0.0003836931 0.075180280 0.0466097
  # reverb:Mixed-anech:Blocked    0.039486532  0.0020882385 0.076884825 0.0338023
  # anech:Mixed-reverb:Blocked    0.069541246  0.0321429523 0.106939539 0.0000112
  # reverb:Mixed-reverb:Blocked   0.071245791  0.0338474978 0.108644085 0.0000063
  # reverb:Mixed-anech:Mixed      0.001704545 -0.0359032639 0.039312355 0.9994340




plot(tukey_farm_farb.test)







