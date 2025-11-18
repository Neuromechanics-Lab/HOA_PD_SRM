## Script for all stats in the OA/PD SRM Manuscript 
rm(list = ls())
options(digits = 4)
#### Add Libraries ####
library(readxl)
library(ez)
library(gdata)
library(afex)
library(emmeans)
library(car)
library(lmerTest)
library(tidyverse)
library(reshape2)
library(ggplot2)
library(ggbeeswarm)
library(gridExtra)
library(sjPlot)
library(pwr)

#### Load OA and PD Data table ####
dm = read_excel("C:/Users/seboe/OneDrive - Emory University/Documents/Grad School/Neuromechanics Lab/SRM/Data/SRM Analysis/HOA_PD_SRM_Outputs__24-Apr-2024_StatsTable_wAnalysis.xlsx",sheet = 1)
savepath = file.path("C:","Users", "seboe","OneDrive - Emory University","Documents",
                    "Grad School","Neuromechanics Lab","SRM","Data","SRM Analysis",
                    "HOA_PD_SRM_savedfigs","Output from R","24-Apr-2024-Stats-Table")

setwd(savepath)
dm <- dm[dm$GroupCount >= 3, ] # remove reconstructions when less than 3 trials were averaged
dm <- dm[dm$condition <= 11, ] # remove reconstructions for 12cm perturbation (only OA19 and OA20 had these done as pilot studies)

# specify Factors
dm$patient = as.factor(dm$patient)
dm$condition = as.factor(dm$condition)
dm$pertdir_calc_round_deg = as.factor(dm$pertdir_calc_round_deg)
dm$gender = as.factor(dm$gender)
dm$PD = as.factor(dm$PD)
#dm$dir_mag = as.factor(dm$dir_mag)
# take average across magnitudes
dm_avg <- dm %>% 
  group_by(patient, pertdir_calc_round_deg) %>%
  summarize(across(where(is.numeric) & !condition, mean, .names = "{col}"), .groups = 'drop')
# Subset OA/PD data table
dm_90 = subset(dm,pertdir_calc_round_deg == 90)
dm_90_pd0 <- subset(dm_90, PD == 0)
dm_90_pd1 <- subset(dm_90, PD == 1)

dm_270 = subset(dm,pertdir_calc_round_deg == 270)
dm_270_pd0 <- subset(dm_270, PD == 0)
dm_270_pd1 <- subset(dm_270, PD == 1)


#### Load YA/OA/PD Data Table for exploratory analysis ####
dm_ya = read_excel("C:/Users/seboe/OneDrive - Emory University/Documents/Grad School/Neuromechanics Lab/SRM/Data/SRM Analysis/YA_OA_PD_hSRM_AUC_Table.xlsx",sheet = 1)

# specify variables
# Factors (participant, magnitude, sex)
dm_ya$Participant = as.factor(dm_ya$Participant)
dm_ya$condition = as.factor(dm_ya$condition)
dm_ya$pertdir_calc_round_deg = as.factor(dm_ya$pertdir_calc_round_deg)
dm_ya$Group= as.factor(dm_ya$Group)
dm_ya$ctx_comp_ag_AUC = as.numeric(dm_ya$ctx_comp_ag_AUC)
dm_ya$ctx_comp_ag_AUC_percent = as.numeric(dm_ya$ctx_comp_ag_AUC_percent)
dm_ya$subctx_comp_ag_AUC = as.numeric(dm_ya$subctx_comp_ag_AUC)

# Reorder the levels of condition
dm_ya$condition <- factor(dm_ya$condition, levels = c("S", "M", "L", "XL"))

# Create a complete dataset with all combinations of Group and condition
all_combinations <- expand_grid(Group = unique(dm_ya$Group), condition = levels(dm_ya$condition))

# Join the complete dataset with the original data to fill in missing combinations
dm_complete <- left_join(all_combinations, dm_ya, by = c("Group", "condition"))
dm_complete$condition <- factor(dm_complete$condition, levels = c("S", "M", "L", "XL"))

# subset data matrix
dm_ya_90 = subset(dm_complete,pertdir_calc_round_deg == 90)
dm_ya_90$condition <- factor(dm_ya_90$condition, levels = c("S", "M", "L", "XL"))

dm_ya_270 = subset(dm_complete,pertdir_calc_round_deg == 270)
dm_ya_270$condition <- factor(dm_ya_270$condition, levels = c("S", "M", "L", "XL"))

dm_ya_270_subset = subset(dm_ya_270, condition == "M" | condition == "L")
dm_ya_270_subset$Group <- relevel(dm_ya_270_subset$Group, ref = "YA") # Re-level Group to make "YA" the reference level


#### ###################### ####
#### ###################### ####
#### INCLUDED IN MANUSCRIPT ####
#### ###################### ####
#### ###################### ####
#### mSRM hSRM Recon Accuracy Comparison ####
# R2 - 90
dm_R2_90 = melt(dm_90, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("fit_agonist_TotalDual_CoM_1", "fit_agonist_1"))
# plot
ggplot(dm_R2_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 90")


# lmer
mSRM_hSRM_Compare_R2_90 = lmer(value ~ variable*condition + (variable|patient), data = dm_R2_90)
print(mSRM_hSRM_Compare_R2_90)
summary(mSRM_hSRM_Compare_R2_90)
emmeans(mSRM_hSRM_Compare_R2_90,pairwise~variable)
VarCorr(mSRM_hSRM_Compare_R2_90)

# save plot
jpeg("mSRM_hSRM_compare_R2_90.jpg",width = 450, height = 450)
ggplot(dm_R2_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 90")
dev.off()
pdf("mSRM_hSRM_compare_R2_90.pdf")
ggplot(dm_R2_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 90")
dev.off()
sink("mSRM_hSRM_compare_R2_90.txt")
emmeans(mSRM_hSRM_Compare_R2_90,pairwise~variable)
sink()

# R2 - 270
dm_R2_270 = melt(dm_270, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("fit_agonist_TotalDual_CoM_1", "fit_agonist_1"))
ggplot(dm_R2_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 270")

# lmer
mSRM_hSRM_Compare_R2_270 = lmer(value ~ variable*condition + (variable|patient), data = dm_R2_270)
print(mSRM_hSRM_Compare_R2_270)
summary(mSRM_hSRM_Compare_R2_270)
emmeans(mSRM_hSRM_Compare_R2_270,pairwise~variable)
VarCorr(mSRM_hSRM_Compare_R2_270)
# save plot
jpeg("mSRM_hSRM_compare_R2_270.jpg",width = 450, height = 450)
plot(dm_R2_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 270")
dev.off()
pdf("mSRM_hSRM_compare_R2_270.pdf")
plot(dm_R2_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "R2") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM R2 Comparison - 270")
dev.off()
sink("mSRM_hSRM_compare_R2_270.txt")
emmeans(mSRM_hSRM_Compare_R2_270,pairwise~variable)
sink()

# VAF - 90
dm_VAF_90 = melt(dm_90, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("fit_agonist_TotalDual_CoM_2", "fit_agonist_2"))
# plot
ggplot(dm_VAF_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 90")

# lmer
mSRM_hSRM_Compare_VAF_90 = lmer(value ~ variable*condition + (variable|patient), data = dm_VAF_90)
print(mSRM_hSRM_Compare_VAF_90)
summary(mSRM_hSRM_Compare_VAF_90)
emmeans(mSRM_hSRM_Compare_VAF_90,pairwise~variable)
VarCorr(mSRM_hSRM_Compare_VAF_90)

# save plot
jpeg("mSRM_hSRM_compare_VAF_90.jpg",width = 450, height = 450)
ggplot(dm_VAF_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 90")
dev.off()
pdf("mSRM_hSRM_compare_VAF_90.pdf")
ggplot(dm_VAF_90) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 90")
dev.off()
sink("mSRM_hSRM_compare_VAF_90.txt")
emmeans(mSRM_hSRM_Compare_VAF_90,pairwise~variable)
sink()

# VAF - 270
dm_VAF_270 = melt(dm_270, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("fit_agonist_TotalDual_CoM_2", "fit_agonist_2"))
ggplot(dm_VAF_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 270")

# lmer
mSRM_hSRM_Compare_VAF_270 = lmer(value ~ variable*condition + (variable|patient), data = dm_VAF_270)
print(mSRM_hSRM_Compare_VAF_270)
summary(mSRM_hSRM_Compare_VAF_270)
emmeans(mSRM_hSRM_Compare_VAF_270,pairwise~variable)
VarCorr(mSRM_hSRM_Compare_VAF_270)

# save plot
jpeg("mSRM_hSRM_compare_VAF_270.jpg",width = 450, height = 450)
ggplot(dm_VAF_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 270")
dev.off()
pdf("mSRM_hSRM_compare_VAF_270.pdf")
ggplot(dm_VAF_270) +  aes(x = variable, y = value) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge boxplots to separate them by PD  
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  #geom_point(aes(size = I(2))) + 
  geom_line(aes(group = patient, color = minibest)) + 
  facet_grid(condition ~ PD) + 
  theme_classic() +
  theme(panel.spacing = unit(0, "lines"),  # Set panel spacing to 0
        panel.border = element_rect(color = "black", fill = NA)) + 
  labs(x = "Model", y = "VAF") + 
  ylim(0,1) + 
  ggtitle("mSRM hSRM VAF Comparison - 270")
dev.off()
sink("mSRM_hSRM_compare_VAF_270.txt")
emmeans(mSRM_hSRM_Compare_VAF_270,pairwise~variable)
sink()

#### Agonist Cortical comp AUC across perturbation magnitude & cohort (LMER) ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save plot
jpeg("ctx_comp_ag_AUC_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("ctx_comp_ag_AUC_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

ctx_comp_ag_AUC_vs_mag_90 = lmer(ctx_comp_ag_AUC ~ condition*PD + (1|patient), data = dm_90)
print(ctx_comp_ag_AUC_vs_mag_90)
summary(ctx_comp_ag_AUC_vs_mag_90)
emmeans(ctx_comp_ag_AUC_vs_mag_90,pairwise~condition)
emmeans(ctx_comp_ag_AUC_vs_mag_90,pairwise~PD)
VarCorr(ctx_comp_ag_AUC_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
ctx_comp_ag_AUC_vs_mag_90_tmp_table = anova(ctx_comp_ag_AUC_vs_mag_90)
print(ctx_comp_ag_AUC_vs_mag_90_tmp_table)
# Make table
tab_model(ctx_comp_ag_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(ctx_comp_ag_AUC ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("ctx_comp_ag_AUC_vs_mag_90.txt")
summary(ctx_comp_ag_AUC_vs_mag_90)
emmeans(ctx_comp_ag_AUC_vs_mag_90,pairwise~condition)
print(ctx_comp_ag_AUC_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure
jpeg("ctx_comp_ag_AUC_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("ctx_comp_ag_AUC_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

ctx_comp_ag_AUC_vs_mag_270 = lmer(ctx_comp_ag_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(ctx_comp_ag_AUC_vs_mag_270)
summary(ctx_comp_ag_AUC_vs_mag_270)
emmeans(ctx_comp_ag_AUC_vs_mag_270,pairwise~condition)
emmeans(ctx_comp_ag_AUC_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(ctx_comp_ag_AUC_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
ctx_comp_ag_AUC_vs_mag_270_tmp_table = anova(ctx_comp_ag_AUC_vs_mag_270)
print(ctx_comp_ag_AUC_vs_mag_270_tmp_table)
# Make table
tab_model(ctx_comp_ag_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(ctx_comp_ag_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("ctx_comp_ag_AUC_vs_mag_270.txt")
summary(ctx_comp_ag_AUC_vs_mag_270)
emmeans(ctx_comp_ag_AUC_vs_mag_270,pairwise~condition)
print(ctx_comp_ag_AUC_vs_mag_270_tmp_table)
sink()

#### Agonist Subcortical comp AUC across perturbation magnitude & cohort (LMER) ####
## Forward perturbation
ggplot(data = dm_90, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure 
jpeg("subctx_comp_ag_AUC_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("subctx_comp_ag_AUC_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

subctx_comp_ag_AUC_vs_mag_90 = lmer(subctx_comp_ag_AUC ~ condition*PD + (1|patient), data = dm_90)
print(subctx_comp_ag_AUC_vs_mag_90)
summary(subctx_comp_ag_AUC_vs_mag_90)
emmeans(subctx_comp_ag_AUC_vs_mag_90,pairwise~condition)
emmeans(subctx_comp_ag_AUC_vs_mag_90,pairwise~PD)
VarCorr(subctx_comp_ag_AUC_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
subctx_comp_ag_AUC_vs_mag_90_tmp_table = anova(subctx_comp_ag_AUC_vs_mag_90)
print(subctx_comp_ag_AUC_vs_mag_90_tmp_table)
# Make table
tab_model(subctx_comp_ag_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(subctx_comp_ag_AUC ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save lmer
sink("subctx_comp_ag_AUC_vs_mag_90.txt")
summary(ctx_comp_ag_AUC_vs_mag_90)
emmeans(ctx_comp_ag_AUC_vs_mag_90,pairwise~condition)
print(subctx_comp_ag_AUC_vs_mag_90_tmp_table)
sink()


## Backward perturbation 
ggplot(data = dm_270, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure 
jpeg("subctx_comp_ag_AUC_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("subctx_comp_ag_AUC_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = subctx_comp_ag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

subctx_comp_ag_AUC_vs_mag_270 = lmer(subctx_comp_ag_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(subctx_comp_ag_AUC_vs_mag_270)
summary(subctx_comp_ag_AUC_vs_mag_270)
emmeans(subctx_comp_ag_AUC_vs_mag_270,pairwise~condition)
emmeans(subctx_comp_ag_AUC_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(subctx_comp_ag_AUC_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
subctx_comp_ag_AUC_vs_mag_270_tmp_table = anova(subctx_comp_ag_AUC_vs_mag_270)
print(subctx_comp_ag_AUC_vs_mag_270_tmp_table)
# Make table
tab_model(subctx_comp_ag_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(subctx_comp_ag_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("subctx_comp_ag_AUC_vs_mag_270.txt")
summary(subctx_comp_ag_AUC_vs_mag_270)
emmeans(subctx_comp_ag_AUC_vs_mag_270,pairwise~condition)
print(subctx_comp_ag_AUC_vs_mag_270_tmp_table)
sink()

#### Antagonist Destabilizing comp AUC across perturbation magnitude (LMER) ####
## Forward perturbation
ggplot(data = dm_90, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save 
jpeg("destabilizing_comp_antag_AUC_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("destabilizing_comp_antag_AUC_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

# lmer
destabilizing_comp_antag_AUC_vs_mag_90 = lmer(destabilizing_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_90)
print(destabilizing_comp_antag_AUC_vs_mag_90)
summary(destabilizing_comp_antag_AUC_vs_mag_90)
emmeans(destabilizing_comp_antag_AUC_vs_mag_90,pairwise~condition)
emmeans(destabilizing_comp_antag_AUC_vs_mag_90,pairwise~PD)
VarCorr(destabilizing_comp_antag_AUC_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
destabilizing_comp_antag_AUC_vs_mag_90_tmp_table = anova(destabilizing_comp_antag_AUC_vs_mag_90)
print(destabilizing_comp_antag_AUC_vs_mag_90_tmp_table)
# Make table
tab_model(destabilizing_comp_antag_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(destabilizing_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("destabilizing_comp_antag_AUC_vs_mag_90.txt")
summary(destabilizing_comp_antag_AUC_vs_mag_90)
emmeans(destabilizing_comp_antag_AUC_vs_mag_90,pairwise~condition)
emmeans(destabilizing_comp_antag_AUC_vs_mag_90,pairwise~PD)
VarCorr(destabilizing_comp_antag_AUC_vs_mag_90)
print(destabilizing_comp_antag_AUC_vs_mag_90_tmp_table)
sink()

## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save 
jpeg("destabilizing_comp_antag_AUC_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("destabilizing_comp_antag_AUC_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = destabilizing_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Destabilizing Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

# lmer
destabilizing_comp_antag_AUC_vs_mag_270 = lmer(destabilizing_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_270)
print(destabilizing_comp_antag_AUC_vs_mag_270)
summary(destabilizing_comp_antag_AUC_vs_mag_270)
emmeans(destabilizing_comp_antag_AUC_vs_mag_270,pairwise~condition)
emmeans(destabilizing_comp_antag_AUC_vs_mag_270,pairwise~PD)
VarCorr(destabilizing_comp_antag_AUC_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
destabilizing_comp_antag_AUC_vs_mag_270_tmp_table = anova(destabilizing_comp_antag_AUC_vs_mag_270)
print(destabilizing_comp_antag_AUC_vs_mag_270_tmp_table)
# Make table
tab_model(destabilizing_comp_antag_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(destabilizing_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save
sink("destabilizing_comp_antag_AUC_vs_mag_270.txt")
summary(destabilizing_comp_antag_AUC_vs_mag_270)
emmeans(destabilizing_comp_antag_AUC_vs_mag_270,pairwise~condition)
emmeans(destabilizing_comp_antag_AUC_vs_mag_270,pairwise~PD)
VarCorr(destabilizing_comp_antag_AUC_vs_mag_270)
print(destabilizing_comp_antag_AUC_vs_mag_270_tmp_table)
sink()
#### Antagonist braking comp AUC across perturbation magnitude (LMER) ####
## Forward perturbation
ggplot(data = dm_90, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save 
jpeg("braking_comp_antag_AUC_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("braking_comp_antag_AUC_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

# lmer
braking_comp_antag_AUC_vs_mag_90 = lmer(braking_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_90)
print(braking_comp_antag_AUC_vs_mag_90)
summary(braking_comp_antag_AUC_vs_mag_90)
emmeans(braking_comp_antag_AUC_vs_mag_90,pairwise~condition)
emmeans(braking_comp_antag_AUC_vs_mag_90,pairwise~PD)
VarCorr(braking_comp_antag_AUC_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
braking_comp_antag_AUC_vs_mag_90_tmp_table = anova(braking_comp_antag_AUC_vs_mag_90)
print(braking_comp_antag_AUC_vs_mag_90_tmp_table)
# Make table
tab_model(braking_comp_antag_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(braking_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("braking_comp_antag_AUC_vs_mag_90.txt")
summary(braking_comp_antag_AUC_vs_mag_90)
emmeans(braking_comp_antag_AUC_vs_mag_90,pairwise~condition)
emmeans(braking_comp_antag_AUC_vs_mag_90,pairwise~PD)
VarCorr(braking_comp_antag_AUC_vs_mag_90)
print(braking_comp_antag_AUC_vs_mag_90_tmp_table)
sink()

## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save 
jpeg("braking_comp_antag_AUC_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("braking_comp_antag_AUC_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = braking_comp_antag_AUC, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Integrated Braking Component") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

# lmer
braking_comp_antag_AUC_vs_mag_270 = lmer(braking_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_270)
print(braking_comp_antag_AUC_vs_mag_270)
summary(braking_comp_antag_AUC_vs_mag_270)
emmeans(braking_comp_antag_AUC_vs_mag_270,pairwise~condition)
emmeans(braking_comp_antag_AUC_vs_mag_270,pairwise~PD)
VarCorr(braking_comp_antag_AUC_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
braking_comp_antag_AUC_vs_mag_270_tmp_table = anova(braking_comp_antag_AUC_vs_mag_270)
print(braking_comp_antag_AUC_vs_mag_270_tmp_table)
# Make table
tab_model(braking_comp_antag_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(braking_comp_antag_AUC ~ condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save
sink("braking_comp_antag_AUC_vs_mag_270.txt")
summary(braking_comp_antag_AUC_vs_mag_270)
emmeans(braking_comp_antag_AUC_vs_mag_270,pairwise~condition)
emmeans(braking_comp_antag_AUC_vs_mag_270,pairwise~PD)
VarCorr(braking_comp_antag_AUC_vs_mag_270)
print(braking_comp_antag_AUC_vs_mag_270_tmp_table)
sink()
#### kaD comp AUC across perturbation magnitude (LMER) ####
## Forward perturbation
#lmer 
kaD_comp_AUC_vs_mag_90 = lmer(kaD_comp_AUC ~ condition*PD + (1|patient), data = dm_90)
print(kaD_comp_AUC_vs_mag_90)
summary(kaD_comp_AUC_vs_mag_90)
emmeans(kaD_comp_AUC_vs_mag_90,pairwise~condition)
emmeans(kaD_comp_AUC_vs_mag_90,pairwise~PD)
VarCorr(kaD_comp_AUC_vs_mag_90)

# Make table
tab_model(kaD_comp_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "kaD Comp",
          show.re.var=TRUE)
sink("kaD_comp_AUC_vs_mag_90.txt")
summary(kaD_comp_AUC_vs_mag_90)
emmeans(kaD_comp_AUC_vs_mag_90,pairwise~condition)
emmeans(kaD_comp_AUC_vs_mag_90,pairwise~PD)
sink()

# Generate box plots separately for PD = 0 and PD = 1
p1 <- ggplot(dm_90_pd0, aes(x = factor(condition), y = kaD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.05) + 
  labs(title = "PD = 0 (Forward)", x = "Magnitude", y = "kaD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
p2 <- ggplot(dm_90_pd1, aes(x = factor(condition), y = kaD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.05) +
  labs(title = "PD = 1 (Forward)", x = "Magnitude", y = "kaD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
# Display the plots side by side
grid.arrange(p1, p2, ncol = 2)

# save 
jpeg("kaD_comp_AUC_vs_mag_90.jpg",width = 600, height = 600)
grid.arrange(p1, p2, ncol = 2)
dev.off()
pdf("kaD_comp_AUC_vs_mag_90.pdf")
grid.arrange(p1, p2, ncol = 2)
dev.off()

## Backward perturbation
#lmer 
kaD_comp_AUC_vs_mag_270 = lmer(kaD_comp_AUC ~ condition*PD + (1|patient), data = dm_270)
print(kaD_comp_AUC_vs_mag_270)
summary(kaD_comp_AUC_vs_mag_270)
emmeans(kaD_comp_AUC_vs_mag_270,pairwise~condition)
emmeans(kaD_comp_AUC_vs_mag_270,pairwise~PD)
VarCorr(kaD_comp_AUC_vs_mag_270)
tab_model(kaD_comp_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "kaD Comp",
          show.re.var=TRUE)
#save
sink("kaD_comp_AUC_vs_mag_270.txt")
summary(kaD_comp_AUC_vs_mag_270)
emmeans(kaD_comp_AUC_vs_mag_270,pairwise~condition)
emmeans(kaD_comp_AUC_vs_mag_270,pairwise~PD)
sink()

# Split the data by PD
dm_pd0 <- subset(dm_270, PD == 0)
dm_pd1 <- subset(dm_270, PD == 1)
# Generate box plots separately for PD = 0 and PD = 1
p1 <- ggplot(dm_270_pd0, aes(x = factor(condition), y = kaD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.05) + 
  labs(title = "PD = 0 (Backward)", x = "Magnitude", y = "kaD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
p2 <- ggplot(dm_270_pd1, aes(x = factor(condition), y = kaD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.05) +
  labs(title = "PD = 1 (Backward)", x = "Magnitude", y = "kaD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
# Display the plots side by side
grid.arrange(p1, p2, ncol = 2)

# save 
jpeg("kaD_comp_AUC_vs_mag_270.jpg",width = 600, height = 600)
grid.arrange(p1, p2, ncol = 2)
dev.off()
pdf("kaD_comp_AUC_vs_mag_270.pdf")
grid.arrange(p1, p2, ncol = 2)
dev.off()

#### kvD + kdD comp AUC across perturbation magnitude (LMER) ####
## Forward perturbation
kvD_kdD_comp_AUC_vs_mag_90 = lmer(kvD_kdD_comp_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_90)
print(kvD_kdD_comp_AUC_vs_mag_90)
summary(kvD_kdD_comp_AUC_vs_mag_90)
emmeans(kvD_kdD_comp_AUC_vs_mag_90,pairwise~condition)
emmeans(kvD_kdD_comp_AUC_vs_mag_90,pairwise~PD)
VarCorr(kvD_kdD_comp_AUC_vs_mag_90)
tab_model(kvD_kdD_comp_AUC_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "kaD Comp",
          show.re.var=TRUE)
#save
sink("kvD_kdD_comp_AUC_vs_mag_90.txt")
summary(kvD_kdD_comp_AUC_vs_mag_90)
emmeans(kvD_kdD_comp_AUC_vs_mag_90,pairwise~condition)
emmeans(kvD_kdD_comp_AUC_vs_mag_90,pairwise~PD)
sink()

# Generate box plots separately for PD = 0 and PD = 1
p1 <- ggplot(dm_90_pd0, aes(x = factor(condition), y = kvD_kdD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.25) + 
  labs(title = "PD = 0 (Forward)", x = "Magnitude", y = "kvD_kdD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
p2 <- ggplot(dm_90_pd1, aes(x = factor(condition), y = kvD_kdD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.25) +
  labs(title = "PD = 1 (Forward)", x = "Magnitude", y = "kvD_kdD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
# Display the plots side by side
grid.arrange(p1, p2, ncol = 2)
# save 
jpeg("kvD_kdD_comp_AUC_vs_mag_90.jpg",width = 600, height = 600)
grid.arrange(p1, p2, ncol = 2)
dev.off()
pdf("kvD_kdD_comp_AUC_vs_mag_90.pdf")
grid.arrange(p1, p2, ncol = 2)
dev.off()

## Backward perturbation lmer
kvD_kdD_comp_AUC_vs_mag_270 = lmer(kvD_kdD_comp_AUC ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(kvD_kdD_comp_AUC_vs_mag_270)
summary(kvD_kdD_comp_AUC_vs_mag_270)
emmeans(kvD_kdD_comp_AUC_vs_mag_270,pairwise~condition)
emmeans(kvD_kdD_comp_AUC_vs_mag_270,pairwise~PD)
VarCorr(kvD_kdD_comp_AUC_vs_mag_270)
tab_model(kvD_kdD_comp_AUC_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "kaD Comp",
          show.re.var=TRUE)
#save
sink("kvD_kdD_comp_AUC_vs_mag_270.txt")
summary(kvD_kdD_comp_AUC_vs_mag_270)
emmeans(kvD_kdD_comp_AUC_vs_mag_270,pairwise~condition)
emmeans(kvD_kdD_comp_AUC_vs_mag_270,pairwise~PD)
sink()

#plot
p1 <- ggplot(dm_270_pd0, aes(x = factor(condition), y = kvD_kdD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.25) + 
  labs(title = "PD = 0 (Backward)", x = "Magnitude", y = "kvD_kdD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
p2 <- ggplot(dm_270_pd1, aes(x = factor(condition), y = kvD_kdD_comp_AUC)) +
  geom_boxplot() + 
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  ylim(0, 0.25) +
  labs(title = "PD = 1 (Backward)", x = "Magnitude", y = "kvD_kdD_comp_AUC") +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18))
# Display the plots side by side
grid.arrange(p1, p2, ncol = 2)
# save 
jpeg("kvD_kdD_comp_AUC_vs_mag_270.jpg",width = 600, height = 600)
grid.arrange(p1, p2, ncol = 2)
dev.off()
pdf("kvD_kdD_comp_AUC_vs_mag_270.pdf")
grid.arrange(p1, p2, ncol = 2)
dev.off()
#### Agonist SRM Cortical Onset Latency comparison between OA and PD ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save plot
jpeg("Gains_Ag_TotalDual_CoM_8_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Ag_TotalDual_CoM_8_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Ag_TotalDual_CoM_8_vs_mag_90 = lmer(Gains_Ag_TotalDual_CoM_8 ~ condition*PD + (1|patient), data = dm_90)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_90)
summary(Gains_Ag_TotalDual_CoM_8_vs_mag_90)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_90,pairwise~condition)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_90,pairwise~PD)
VarCorr(Gains_Ag_TotalDual_CoM_8_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Ag_TotalDual_CoM_8_vs_mag_90_tmp_table = anova(Gains_Ag_TotalDual_CoM_8_vs_mag_90)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_90_tmp_table)
# Make table
tab_model(Gains_Ag_TotalDual_CoM_8_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Ag_TotalDual_CoM_8 ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("Gains_Ag_TotalDual_CoM_8_vs_mag_90.txt")
summary(Gains_Ag_TotalDual_CoM_8_vs_mag_90)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_90,pairwise~condition)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure
jpeg("Gains_Ag_TotalDual_CoM_8_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Ag_TotalDual_CoM_8_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Cortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Ag_TotalDual_CoM_8_vs_mag_270 = lmer(Gains_Ag_TotalDual_CoM_8 ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_270)
summary(Gains_Ag_TotalDual_CoM_8_vs_mag_270)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_270,pairwise~condition)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(Gains_Ag_TotalDual_CoM_8_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Ag_TotalDual_CoM_8_vs_mag_270_tmp_table = anova(Gains_Ag_TotalDual_CoM_8_vs_mag_270)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_270_tmp_table)
# Make table
tab_model(Gains_Ag_TotalDual_CoM_8_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Ag_TotalDual_CoM_8 ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("Gains_Ag_TotalDual_CoM_8_vs_mag_270.txt")
summary(Gains_Ag_TotalDual_CoM_8_vs_mag_270)
emmeans(Gains_Ag_TotalDual_CoM_8_vs_mag_270,pairwise~condition)
print(Gains_Ag_TotalDual_CoM_8_vs_mag_270_tmp_table)
sink()
#### Agonist SRM Subcortical Onset Latency comparison between OA and PD ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save plot
jpeg("Gains_Ag_TotalDual_CoM_4_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Ag_TotalDual_CoM_4_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Ag_TotalDual_CoM_4_vs_mag_90 = lmer(Gains_Ag_TotalDual_CoM_4 ~ condition*PD + (1|patient), data = dm_90)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_90)
summary(Gains_Ag_TotalDual_CoM_4_vs_mag_90)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_90,pairwise~condition)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_90,pairwise~PD)
VarCorr(Gains_Ag_TotalDual_CoM_4_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Ag_TotalDual_CoM_4_vs_mag_90_tmp_table = anova(Gains_Ag_TotalDual_CoM_4_vs_mag_90)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_90_tmp_table)
# Make table
tab_model(Gains_Ag_TotalDual_CoM_4_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Ag_TotalDual_CoM_4 ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("Gains_Ag_TotalDual_CoM_4_vs_mag_90.txt")
summary(Gains_Ag_TotalDual_CoM_4_vs_mag_90)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_90,pairwise~condition)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure
jpeg("Gains_Ag_TotalDual_CoM_4_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Ag_TotalDual_CoM_4_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Agonist Subcortical Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Ag_TotalDual_CoM_4_vs_mag_270 = lmer(Gains_Ag_TotalDual_CoM_4 ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_270)
summary(Gains_Ag_TotalDual_CoM_4_vs_mag_270)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_270,pairwise~condition)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(Gains_Ag_TotalDual_CoM_4_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Ag_TotalDual_CoM_4_vs_mag_270_tmp_table = anova(Gains_Ag_TotalDual_CoM_4_vs_mag_270)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_270_tmp_table)
# Make table
tab_model(Gains_Ag_TotalDual_CoM_4_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Ag_TotalDual_CoM_4 ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("Gains_Ag_TotalDual_CoM_4_vs_mag_270.txt")
summary(Gains_Ag_TotalDual_CoM_4_vs_mag_270)
emmeans(Gains_Ag_TotalDual_CoM_4_vs_mag_270,pairwise~condition)
print(Gains_Ag_TotalDual_CoM_4_vs_mag_270_tmp_table)
sink()



#### Antagonist SRM Destabilizing Onset Latency comparison between OA and PD ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save plot
jpeg("Gains_Antag_8_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Antag_8_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Antag_8_vs_mag_90 = lmer(Gains_Antag_8 ~ condition*PD + (1|patient), data = dm_90)
print(Gains_Antag_8_vs_mag_90)
summary(Gains_Antag_8_vs_mag_90)
emmeans(Gains_Antag_8_vs_mag_90,pairwise~condition)
emmeans(Gains_Antag_8_vs_mag_90,pairwise~PD)
VarCorr(Gains_Antag_8_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Antag_8_vs_mag_90_tmp_table = anova(Gains_Antag_8_vs_mag_90)
print(Gains_Antag_8_vs_mag_90_tmp_table)
# Make table
tab_model(Gains_Antag_8_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Antag_8 ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("Gains_Antag_8_vs_mag_90.txt")
summary(Gains_Antag_8_vs_mag_90)
emmeans(Gains_Antag_8_vs_mag_90,pairwise~condition)
print(Gains_Antag_8_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure
jpeg("Gains_Antag_8_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Antag_8_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_8, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Destabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Antag_8_vs_mag_270 = lmer(Gains_Antag_8 ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(Gains_Antag_8_vs_mag_270)
summary(Gains_Antag_8_vs_mag_270)
emmeans(Gains_Antag_8_vs_mag_270,pairwise~condition)
emmeans(Gains_Antag_8_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(Gains_Antag_8_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Antag_8_vs_mag_270_tmp_table = anova(Gains_Antag_8_vs_mag_270)
print(Gains_Antag_8_vs_mag_270_tmp_table)
# Make table
tab_model(Gains_Antag_8_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Antag_8 ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("Gains_Antag_8_vs_mag_270.txt")
summary(Gains_Antag_8_vs_mag_270)
emmeans(Gains_Antag_8_vs_mag_270,pairwise~condition)
print(Gains_Antag_8_vs_mag_270_tmp_table)
sink()

#### Antagonist SRM Braking Onset Latency comparison between OA and PD ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save plot
jpeg("Gains_Antag_4_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Antag_4_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Antag_4_vs_mag_90 = lmer(Gains_Antag_4 ~ condition*PD + (1|patient), data = dm_90)
print(Gains_Antag_4_vs_mag_90)
summary(Gains_Antag_4_vs_mag_90)
emmeans(Gains_Antag_4_vs_mag_90,pairwise~condition)
emmeans(Gains_Antag_4_vs_mag_90,pairwise~PD)
VarCorr(Gains_Antag_4_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Antag_4_vs_mag_90_tmp_table = anova(Gains_Antag_4_vs_mag_90)
print(Gains_Antag_4_vs_mag_90_tmp_table)
# Make table
tab_model(Gains_Antag_4_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Antag_4 ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("Gains_Antag_4_vs_mag_90.txt")
summary(Gains_Antag_4_vs_mag_90)
emmeans(Gains_Antag_4_vs_mag_90,pairwise~condition)
print(Gains_Antag_4_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )

# save figure
jpeg("Gains_Antag_4_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()
pdf("Gains_Antag_4_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Antag_4, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  ylim(0, 0.5) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Antagonist Stabilizing Onset Latency (s)") +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 28, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 28, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.key.size = unit(3, 'lines'),   # Increase the size of legend keys
    legend.text = element_text(size = 28)   # Increase the text size in the legend
  )
dev.off()

Gains_Antag_4_vs_mag_270 = lmer(Gains_Antag_4 ~ condition + PD + condition*PD + (1|patient), data = dm_270)
print(Gains_Antag_4_vs_mag_270)
summary(Gains_Antag_4_vs_mag_270)
emmeans(Gains_Antag_4_vs_mag_270,pairwise~condition)
emmeans(Gains_Antag_4_vs_mag_270,pairwise~PD) # Reporting this comparison
VarCorr(Gains_Antag_4_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
Gains_Antag_4_vs_mag_270_tmp_table = anova(Gains_Antag_4_vs_mag_270)
print(Gains_Antag_4_vs_mag_270_tmp_table)
# Make table
tab_model(Gains_Antag_4_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(Gains_Antag_4 ~ condition + PD + condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save lmer output
sink("Gains_Antag_4_vs_mag_270.txt")
summary(Gains_Antag_4_vs_mag_270)
emmeans(Gains_Antag_4_vs_mag_270,pairwise~condition)
print(Gains_Antag_4_vs_mag_270_tmp_table)
sink()



#### SRM Onset latency comparison between models ####
# prepare data for stat model
dm_vars_90 = melt(dm_90, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("Gains_Antag_4", "Gains_Antag_8",
                                                                                "Gains_Ag_TotalDual_CoM_8", "Gains_Ag_TotalDual_CoM_4"))
dm_vars_270 = melt(dm_270, id = c("patient", "condition", "PD", "minibest"), measure.vars = c("Gains_Antag_4", "Gains_Antag_8",
                                                                                  "Gains_Ag_TotalDual_CoM_8", "Gains_Ag_TotalDual_CoM_4"))
# Forward perturbations
# lmer
onset_latency_Compare_90 = lmer(value ~ variable*condition*PD + (variable|patient), data = dm_vars_90)
print(onset_latency_Compare_90)
summary(onset_latency_Compare_90)
emmeans(onset_latency_Compare_90,pairwise~variable)
emmeans(onset_latency_Compare_90,pairwise~PD)

# Backward perturbations
# lmer
onset_latency_Compare_270 = lmer(value ~ variable*condition*PD + (variable|patient), data = dm_vars_270)
print(onset_latency_Compare_270)
summary(onset_latency_Compare_270)
emmeans(onset_latency_Compare_270,pairwise~variable)
emmeans(onset_latency_Compare_270,pairwise~PD)

#save
sink("LatencyComparison.txt")
summary(onset_latency_Compare_90)
emmeans(onset_latency_Compare_90,pairwise~variable)
emmeans(onset_latency_Compare_90,pairwise~PD)

summary(onset_latency_Compare_270)
emmeans(onset_latency_Compare_270,pairwise~variable)
emmeans(onset_latency_Compare_270,pairwise~PD)
sink()

# plot forward perturbation
p90 = ggplot(data = dm_vars_90, aes(x = variable, y = value, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  scale_x_discrete(labels = c("Gains_Antag_4" = "B", "Gains_Antag_8" = "D", "Gains_Ag_TotalDual_CoM_8" = "2", 
                              "Gains_Ag_TotalDual_CoM_4" = "1")) +  # Custom x-axis tick labels
  ylim(0, 0.4) +
  labs(title = "Onset Latency Comparison - 90", x = "Delay", y = "Latency (s)") +
  theme(
    axis.text.x = element_text(size = 18, color = "black",angle = 45, hjust = 1),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 18, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 18, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 18, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.position = "none"   # Remove the legend
  )
# plot backward perturbation
p270 = ggplot(data = dm_vars_270, aes(x = variable, y = value, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  geom_jitter(aes(color = minibest), position = position_dodge(width = 0.75), size = 2) +  # Dodge points to align with boxplots
  scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  scale_x_discrete(labels = c("Gains_Antag_4" = "B", "Gains_Antag_8" = "D", "Gains_Ag_TotalDual_CoM_8" = "2", 
                              "Gains_Ag_TotalDual_CoM_4" = "1")) +  # Custom x-axis tick labels
  ylim(0, 0.4) +
  labs(title = "Onset Latency Comparison - 270", x = "Delay", y = "Latency (s)") +
  theme(
    axis.text.x = element_text(size = 18, color = "black",angle = 45, hjust = 1),  # Adjust the font size of x-axis tick labels
    axis.text.y = element_text(size = 18, color = "black"),  # Adjust the font size of y-axis tick labels
    axis.title.x = element_text(size = 18, color = "black"), # Adjust the font size of x-axis label
    axis.title.y = element_text(size = 18, color = "black"), # Adjust the font size of y-axis label
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 2),  # Increase the stroke size of tick marks
    panel.grid.major = element_blank(),      # Remove major grid lines
    panel.grid.minor = element_blank(),      # Remove minor grid lines
    panel.spacing = unit(0.5, "lines"),      # Adjust spacing between panels
    panel.background = element_rect(fill = "white", color = NA),  # Change background to white
    plot.background = element_rect(fill = "white", color = NA),   # Change plot background to white
    legend.position = "none"   # Remove the legend
  )
# Display the plots side by side
grid.arrange(p90, p270, ncol = 2)

# save
jpeg("LatencyComparison.jpg",width = 300, height = 300)
grid.arrange(p90, p270, ncol = 2)
dev.off()
pdf("LatencyComparison.pdf")
grid.arrange(p90, p270, ncol = 2)
dev.off()

#### Antagonist Destabilizing comp AUC correlation with minibest ####
# Forward Perturbation
# OA only lmer
destabilizing_comp_antag_AUC_vs_minibest_90_pd0 = lmer(destabilizing_comp_antag_AUC ~ minibest*condition + (minibest|patient),
                                                       data = dm_90_pd0)
print(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
VarCorr(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
tab_model(destabilizing_comp_antag_AUC_vs_minibest_90_pd0,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "destabilizing_comp_antag_AUC_vs_minibest_90_pd0",
          show.re.var=TRUE)
#save
sink("destabilizing_comp_antag_AUC_vs_minibest_90_pd0.txt")
print(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
sink()

# PD only lmer
destabilizing_comp_antag_AUC_vs_minibest_90_pd1 = lmer(destabilizing_comp_antag_AUC ~ minibest*condition + (minibest|patient),
                                                       data = dm_90_pd1)
print(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
VarCorr(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
tab_model(destabilizing_comp_antag_AUC_vs_minibest_90_pd1,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "destabilizing_comp_antag_AUC_vs_minibest_90_pd1",
          show.re.var=TRUE)
#save
sink("destabilizing_comp_antag_AUC_vs_minibest_90_pd1.txt")
print(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
sink()

# plot linear model
# OA slope/int
tmp_OA = summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd0)
int_OA = tmp_OA$coefficients[1]
sl_OA = tmp_OA$coefficients[2]
# PD slope/int
tmp_PD = summary(destabilizing_comp_antag_AUC_vs_minibest_90_pd1)
int_PD = tmp_PD$coefficients[1]
sl_PD = tmp_PD$coefficients[2]

ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )

# save plot
jpeg("destabilizing_comp_antag_AUC_vs_minibest_90.jpg",width = 600, height = 600)
ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()

pdf("destabilizing_comp_antag_AUC_vs_minibest_90.pdf")
ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()


# Backwards perturbation
# OA only lmer
destabilizing_comp_antag_AUC_vs_minibest_270_pd0 = lmer(destabilizing_comp_antag_AUC ~ minibest*condition + (minibest|patient),
                                                        data = dm_270_pd0)
print(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
VarCorr(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
tab_model(destabilizing_comp_antag_AUC_vs_minibest_270_pd0,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "destabilizing_comp_antag_AUC_vs_minibest_270_pd0",
          show.re.var=TRUE)
#save
sink("destabilizing_comp_antag_AUC_vs_minibest_270_pd0.txt")
print(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
sink()

#PD only lmer
destabilizing_comp_antag_AUC_vs_minibest_270_pd1 = lmer(destabilizing_comp_antag_AUC ~ minibest*condition + (minibest|patient),
                                                        data = dm_270_pd1)
print(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
VarCorr(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
tab_model(destabilizing_comp_antag_AUC_vs_minibest_270_pd1,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "destabilizing_comp_antag_AUC_vs_minibest_270_pd1",
          show.re.var=TRUE)
#save
sink("destabilizing_comp_antag_AUC_vs_minibest_270_pd1.txt")
print(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
sink()

# plot linear model
# OA slope/int
tmp_OA = summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd0)
int_OA = tmp_OA$coefficients[1]
sl_OA = tmp_OA$coefficients[2]
# PD slope/int
tmp_PD = summary(destabilizing_comp_antag_AUC_vs_minibest_270_pd1)
int_PD = tmp_PD$coefficients[1]
sl_PD = tmp_PD$coefficients[2]

ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )

# save plot
jpeg("destabilizing_comp_antag_AUC_vs_minibest_270.jpg",width = 600, height = 600)
ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()

pdf("destabilizing_comp_antag_AUC_vs_minibest_270.pdf")
ggplot() + 
  aes(x = minibest, y = destabilizing_comp_antag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Destabilizing component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()


#### Agonist Cortical comp AUC correlation with minibest ####
# Forward perturbation
# OA only
ctx_comp_ag_AUC_vs_minibest_90_pd0 = lmer(ctx_comp_ag_AUC ~ minibest*condition + (minibest|patient),
                                          data = dm_90_pd0)
print(ctx_comp_ag_AUC_vs_minibest_90_pd0)
summary(ctx_comp_ag_AUC_vs_minibest_90_pd0)
VarCorr(ctx_comp_ag_AUC_vs_minibest_90_pd0)
tab_model(ctx_comp_ag_AUC_vs_minibest_90_pd0,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,
          dv.labels = "ctx comp AUC vs miniBEST (Forward - OA only)",
          show.re.var=TRUE)
#save
sink("ctx_comp_ag_AUC_vs_minibest_90_pd0.txt")
print(ctx_comp_ag_AUC_vs_minibest_90_pd0)
summary(ctx_comp_ag_AUC_vs_minibest_90_pd0)
sink()

# PD only
ctx_comp_ag_AUC_vs_minibest_90_pd1 = lmer(ctx_comp_ag_AUC ~ minibest*condition + (minibest|patient),
                                          data = dm_90_pd1)
print(ctx_comp_ag_AUC_vs_minibest_90_pd1)
summary(ctx_comp_ag_AUC_vs_minibest_90_pd1)
VarCorr(ctx_comp_ag_AUC_vs_minibest_90_pd1)
tab_model(ctx_comp_ag_AUC_vs_minibest_90_pd1,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,
          dv.labels = "ctx comp AUC vs miniBEST (Forward - PD only)",
          show.re.var=TRUE)
#save
sink("ctx_comp_ag_AUC_vs_minibest_90_pd1.txt")
print(ctx_comp_ag_AUC_vs_minibest_90_pd1)
summary(ctx_comp_ag_AUC_vs_minibest_90_pd1)
sink()

# plot linear model
# OA slope/int
tmp_OA = summary(ctx_comp_ag_AUC_vs_minibest_90_pd0)
int_OA = tmp_OA$coefficients[1]
sl_OA = tmp_OA$coefficients[2]
# PD slope/int
tmp_PD = summary(ctx_comp_ag_AUC_vs_minibest_90_pd1)
int_PD = tmp_PD$coefficients[1]
sl_PD = tmp_PD$coefficients[2]

ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )


# save plot
jpeg("ctx_comp_ag_AUC_vs_minibest_90.jpg",width = 600, height = 600)
ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()
pdf("ctx_comp_ag_AUC_vs_minibest_90.pdf")
ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_90_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_90_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Forward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()

# Backward perturbation
# OA only
ctx_comp_ag_AUC_vs_minibest_270_pd0 = lmer(ctx_comp_ag_AUC ~ minibest*condition + (minibest|patient),
                                           data = dm_270_pd0)
print(ctx_comp_ag_AUC_vs_minibest_270_pd0)
summary(ctx_comp_ag_AUC_vs_minibest_270_pd0)
VarCorr(ctx_comp_ag_AUC_vs_minibest_270_pd0)
tab_model(ctx_comp_ag_AUC_vs_minibest_270_pd0,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,
          dv.labels = "ctx comp AUC vs miniBEST (Backward - OA only)",
          show.re.var=TRUE)
#save
sink("ctx_comp_ag_AUC_vs_minibest_270_pd0.txt")
print(ctx_comp_ag_AUC_vs_minibest_270_pd0)
summary(ctx_comp_ag_AUC_vs_minibest_270_pd0)
sink()


# PD only
ctx_comp_ag_AUC_vs_minibest_270_pd1 = lmer(ctx_comp_ag_AUC ~ minibest*condition + (minibest|patient),
                                           data = dm_270_pd1)
print(ctx_comp_ag_AUC_vs_minibest_270_pd1)
summary(ctx_comp_ag_AUC_vs_minibest_270_pd1)
VarCorr(ctx_comp_ag_AUC_vs_minibest_270_pd1)
tab_model(ctx_comp_ag_AUC_vs_minibest_270_pd1,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,
          dv.labels = "ctx comp AUC vs miniBEST (Backward - PD only)",
          show.re.var=TRUE)
#save
sink("ctx_comp_ag_AUC_vs_minibest_270_pd1.txt")
print(ctx_comp_ag_AUC_vs_minibest_270_pd1)
summary(ctx_comp_ag_AUC_vs_minibest_270_pd1)
sink()

# plot linear model
# OA slope/int
tmp_OA = summary(ctx_comp_ag_AUC_vs_minibest_270_pd0)
int_OA = tmp_OA$coefficients[1]
sl_OA = tmp_OA$coefficients[2]
# PD slope/int
tmp_PD = summary(ctx_comp_ag_AUC_vs_minibest_270_pd1)
int_PD = tmp_PD$coefficients[1]
sl_PD = tmp_PD$coefficients[2]

ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )

# save plot
jpeg("ctx_comp_ag_AUC_vs_minibest_270.jpg",width = 600, height = 600)
ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()
pdf("ctx_comp_ag_AUC_vs_minibest_270.pdf")
ggplot() + 
  aes(x = minibest, y = ctx_comp_ag_AUC, fill = PD) +
  
  # Add points and line for group 0 (OA)
  geom_point(data = dm_270_pd0, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_OA, slope = sl_OA, color = "#f8992c", size = 1.5) +  # Change color to f8992c and increase stroke width
  
  # Add points and line for group 1 (PD)
  geom_point(data = dm_270_pd1, aes(color = PD, shape = condition), size = 5) + 
  geom_abline(intercept = int_PD, slope = sl_PD, color = "#cb4e27", size = 1.5) +  # Change color to cb4e27 and increase stroke width
  
  scale_color_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Set custom colors for group 0 and group 1
  
  theme_classic() +
  ylim(0, 0.3) + 
  xlim(7, 28) +
  
  labs(title = "Backward Perturbation", x = "minibest", y = "Integrated Longer Latency Component") +
  
  # Customize the axis labels and title
  theme(
    axis.text.x = element_text(size = 28, color = "black"),  # Increase font size for x-axis tick marks
    axis.text.y = element_text(size = 28, color = "black"),  # Increase font size for y-axis tick marks
    axis.title.x = element_text(size = 28, color = "black"), # Increase font size for x-axis label
    axis.title.y = element_text(size = 28, color = "black"), # Increase font size for y-axis label
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5)  # Increase title size and center it
  )
dev.off()


#### PD Specific Stats - See "Stats_HOA_PD_PD_Specific.R" script ####
# spoiler, nothing is significant



#### ###################### ####
#### ###################### ####
#### Requested by reviewers ####
#### ###################### ####
