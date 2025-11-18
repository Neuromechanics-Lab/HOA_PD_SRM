## Script to analyze YA/OA/PD SRM AUC outputs
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
library(tidyr)
library(reshape2)
library(ggplot2)
library(gridExtra)
#### Load Data table####
dm = read_excel("C:/Users/seboe/OneDrive - Emory University/Documents/Grad School/Neuromechanics Lab/SRM/Data/SRM Analysis/YA_OA_PD_hSRM_AUC_Table.xlsx",sheet = 1)

savepath = file.path("C:","Users", "seboe","OneDrive - Emory University","Documents","Grad School","Neuromechanics Lab","SRM","Data","SRM Analysis","HOA_PD_SRM_savedfigs","Output from R")
setwd(savepath)

#### specify variables ####
# Factors (participant, magnitude, sex)
dm$Participant = as.factor(dm$Participant)
dm$condition = as.factor(dm$condition)
dm$pertdir_calc_round_deg = as.factor(dm$pertdir_calc_round_deg)
dm$Group= as.factor(dm$Group)
dm$ctx_comp_ag_AUC = as.numeric(dm$ctx_comp_ag_AUC)
dm$ctx_comp_ag_AUC_percent = as.numeric(dm$ctx_comp_ag_AUC_percent)
dm$subctx_comp_ag_AUC = as.numeric(dm$subctx_comp_ag_AUC)

# remove YA - FOR AUGUST COMMITTEE MEETING ONLY
#dm = subset(dm,Group != "YA")
# Reorder the levels of condition
dm$condition <- factor(dm$condition, levels = c("S", "M", "L", "XL"))

# Create a complete dataset with all combinations of Group and condition
all_combinations <- expand_grid(Group = unique(dm$Group), condition = levels(dm$condition))

# Join the complete dataset with the original data to fill in missing combinations
dm_complete <- left_join(all_combinations, dm, by = c("Group", "condition"))
dm_complete$condition <- factor(dm_complete$condition, levels = c("S", "M", "L", "XL"))

# subset data matrix
dm_90 = subset(dm_complete,pertdir_calc_round_deg == 90)
dm_90$condition <- factor(dm_90$condition, levels = c("S", "M", "L", "XL"))

dm_270 = subset(dm_complete,pertdir_calc_round_deg == 270)
dm_270$condition <- factor(dm_270$condition, levels = c("S", "M", "L", "XL"))

dm_270_subset = subset(dm_270, condition == "M" | condition == "L")
# Relevel Group to make "YA" the reference level
dm_270_subset$Group <- relevel(dm_270_subset$Group, ref = "YA")

#### Agonist Cortical comp AUC across perturbation magnitude ####
# Backward Perturbation
ctx_comp_AUC_270 = lmer(ctx_comp_ag_AUC ~ condition*Group + (1|Participant), data = dm_270_subset)
print(ctx_comp_AUC_270)
summary(ctx_comp_AUC_270)
emmeans(ctx_comp_AUC_270,pairwise~condition)
emmeans(ctx_comp_AUC_270,pairwise~Group)
VarCorr(ctx_comp_AUC_270)

ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("ctx_comp_ag_AUC_vs_mag_270_ALLGROUPS.pdf")
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()

# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remoave major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("ctx_comp_ag_AUC_vs_mag_90_ALLGROUPS.pdf")
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()

#### Agonist subcortical comp AUC across perturbation magnitude ####
# Backward Perturbation
ggplot(data = dm_270, aes(x = condition, y = subctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("subctx_comp_ag_AUC_vs_mag_270_ALLGROUPS.pdf")
ggplot(data = dm_270, aes(x = condition, y = subctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()

# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = subctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("subctx_comp_ag_AUC_vs_mag_90_ALLGROUPS.pdf")
ggplot(data = dm_90, aes(x = condition, y = subctx_comp_ag_AUC, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "subctx_comp_ag_AUC") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()


#### Agonist Cortical comp AUC Percentage across perturbation magnitude ####
# Backward Perturbation
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC_percent, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 100) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC_percent") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("ctx_comp_ag_AUC_percent_vs_mag_270_ALLGROUPS.pdf")
ggplot(data = dm_270, aes(x = condition, y = ctx_comp_ag_AUC_percent, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 100) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC_percent") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()

# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC_percent, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 100) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC_percent") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("ctx_comp_ag_AUC_percent_vs_mag_90_ALLGROUPS.pdf")
ggplot(data = dm_90, aes(x = condition, y = ctx_comp_ag_AUC_percent, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 100) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "ctx_comp_ag_AUC_percent") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()
#### Agonist Cortical onset latency across perturbation magnitude ####
#### Agonist Cortical comp AUC across perturbation magnitude ####
# Backward Perturbation
ctx_comp_onset_270 = lmer(Gains_Ag_TotalDual_CoM_8 ~ condition*Group + (1|Participant), data = dm_270_subset)
print(ctx_comp_onset_270)
summary(ctx_comp_onset_270)
emmeans(ctx_comp_onset_270,pairwise~condition)
emmeans(ctx_comp_onset_270,pairwise~Group)
VarCorr(ctx_comp_onset_270)

ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.6) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("ctx_comp_ag_onset_vs_mag_270_ALLGROUPS.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.6) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()

## Subcortical component
subctx_comp_onset_270 = lmer(Gains_Ag_TotalDual_CoM_4 ~ condition*Group + (1|Participant), data = dm_270_subset)
print(subctx_comp_onset_270)
summary(subctx_comp_onset_270)
emmeans(subctx_comp_onset_270,pairwise~condition)
emmeans(subctx_comp_onset_270,pairwise~Group)
VarCorr(subctx_comp_onset_270)

ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.6) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels

# save 
pdf("subctx_comp_ag_onset_vs_mag_270_ALLGROUPS.pdf")
ggplot(data = dm_270, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, fill = Group)) +
  geom_boxplot(position = position_dodge2(width = 0.75, preserve = "single"), width = 0.6) +  ylim(0, 0.6) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 18),  # Adjust the font size of x-axis tick labels
        axis.text.y = element_text(size = 18),  # Adjust the font size of y-axis tick labels
        axis.title.x = element_text(size = 18), # Adjust the font size of x-axis label
        axis.title.y = element_text(size = 18), # Adjust the font size of y-axis label
        panel.grid.major = element_blank(),      # Remove major grid lines
        panel.grid.minor = element_blank(),      # Remove minor grid lines
        panel.spacing = unit(0.5, "lines"))     # Adjust spacing between panels
dev.off()
