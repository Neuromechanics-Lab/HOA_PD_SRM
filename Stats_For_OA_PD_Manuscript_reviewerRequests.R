## Script to run stats for OA/PD Manuscript resubmission (requested by reviewers and refitting SRM)
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
#dm = read_excel("C:/Users/seboe/OneDrive - Emory University/Documents/Grad School/Neuromechanics Lab/SRM/Data/SRM Analysis/HOA_PD_SRM_Outputs_LR_Averaged_02-May-2024_StatsTable_wAnalysis.xlsx",sheet = 1)
dm = read_excel("C:/Users/seboe/OneDrive - Emory University/Documents/Grad School/Neuromechanics Lab/SRM/Data/SRM Analysis/HOA_PD_SRM_Outputs__24-Apr-2024_StatsTable_wAnalysis.xlsx",sheet = 1)

savepath = file.path("C:","Users", "seboe","OneDrive - Emory University","Documents",
                     "Grad School","Neuromechanics Lab","SRM","Data","SRM Analysis",
                     "HOA_PD_SRM_savedfigs","Output from R","LR_Averaged")

setwd(savepath)
dm <- dm[dm$GroupCount >= 3, ] # remove reconstructions when less than 3 trials were averaged
dm <- dm[dm$condition <= 11, ] # remove reconstructions for 12cm perturbation (only OA19 and OA20 had these done as pilot studies)

# specify Factors
dm$patient = as.factor(dm$patient)
dm$condition = as.factor(dm$condition)
dm$pertdir_calc_round_deg = as.factor(dm$pertdir_calc_round_deg)
dm$gender = as.factor(dm$gender)
dm$PD = as.factor(dm$PD)
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

dm_1cond = subset(dm,condition == 5) # data table with a single magnitude for minibest comparison
dm_1cond = subset(dm_1cond,pertdir_calc_round_deg == 90) # data table with a single magnitude for minibest comparison
#### miniBEST group Comparison ####
# Run t-test on original numeric PD variable
t_test_result <- t.test(minibest ~ PD, data = dm_1cond)
p_val <- signif(t_test_result$p.value, 3)

# Plot
ggplot(dm_1cond, aes(x = PD, y = minibest, fill = PD)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.1, height = 0, size = 2, alpha = 0.6) +
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +
  labs(
    x = "Group",
    y = "MiniBEST Score",
    title = "MiniBEST Scores by Group",
    subtitle = paste("t-test p-value:", p_val)
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")




#### CoM Excursion comparison across perturbation magnitude & cohort (LMER) ####
# Forward Perturbation
ggplot(data = dm_90, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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
jpeg("CoM_Excursion_Y_vs_mag_90.jpg",width = 600, height = 600)
ggplot(data = dm_90, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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
pdf("CoM_Excursion_Y_vs_mag_90.pdf")
ggplot(data = dm_90, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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

CoM_Excursion_Y_vs_mag_90 = lmer(CoM_Excursion_Y ~ condition*PD + (1|patient), data = dm_90)
print(CoM_Excursion_Y_vs_mag_90)
summary(CoM_Excursion_Y_vs_mag_90)
emmeans(CoM_Excursion_Y_vs_mag_90,pairwise~condition)
emmeans(CoM_Excursion_Y_vs_mag_90,pairwise~PD)
VarCorr(CoM_Excursion_Y_vs_mag_90)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
CoM_Excursion_Y_vs_mag_90_tmp_table = anova(CoM_Excursion_Y_vs_mag_90)
print(CoM_Excursion_Y_vs_mag_90_tmp_table)
# Make table
tab_model(CoM_Excursion_Y_vs_mag_90,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(CoM_Excursion_Y ~ condition*PD + (1|patient), data = dm_90)",
          show.re.var=TRUE)
# save
sink("ctx_comp_ag_AUC_vs_mag_90.txt")
summary(CoM_Excursion_Y_vs_mag_90)
emmeans(CoM_Excursion_Y_vs_mag_90,pairwise~condition)
emmeans(CoM_Excursion_Y_vs_mag_90,pairwise~PD)
print(CoM_Excursion_Y_vs_mag_90_tmp_table)
sink()


## Backward perturbation
ggplot(data = dm_270, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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
jpeg("CoM_Excursion_Y_vs_mag_270.jpg",width = 600, height = 600)
ggplot(data = dm_270, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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

pdf("CoM_Excursion_Y_vs_mag_270.pdf")
ggplot(data = dm_270, aes(x = condition, y = CoM_Excursion_Y, fill = PD)) +
  geom_boxplot(position = position_dodge(width = 0.75, preserve = "single"), width = 0.6, size = 1.5) +  # Increase outline stroke size
  #geom_jitter(aes(color = "black"), position = position_dodge(width = 0.75), size = 5) +  # Dodge points to align with boxplots
  #scale_color_gradient(low = "black", high = "lightgray", limits = c(7, 28)) +  # Gradient color for minibest
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +  # Custom colors for each group
  #ylim(0, 0.2) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "CoM_Excursion") +
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

CoM_Excursion_Y_vs_mag_270 = lmer(CoM_Excursion_Y ~ condition*PD + (1|patient), data = dm_270)
print(CoM_Excursion_Y_vs_mag_270)
summary(CoM_Excursion_Y_vs_mag_270)
emmeans(CoM_Excursion_Y_vs_mag_270,pairwise~condition)
emmeans(CoM_Excursion_Y_vs_mag_270,pairwise~PD)
VarCorr(CoM_Excursion_Y_vs_mag_270)
# compute F statistic for each factor - this gives a different result than the ANOVA in the prior section
CoM_Excursion_Y_vs_mag_270_tmp_table = anova(CoM_Excursion_Y_vs_mag_270)
print(CoM_Excursion_Y_vs_mag_270_tmp_table)
# Make table
tab_model(CoM_Excursion_Y_vs_mag_270,
          digits = 2, show.df = TRUE, show.stat = TRUE, p.val = "satterthwaite",
          show.reflvl = TRUE,collapse.ci = TRUE,show.icc =FALSE,linebreak=FALSE,dv.labels = "lmer(CoM_Excursion_Y ~ condition*PD + (1|patient), data = dm_270)",
          show.re.var=TRUE)
# save
sink("ctx_comp_ag_AUC_vs_mag_270.txt")
summary(CoM_Excursion_Y_vs_mag_270)
emmeans(CoM_Excursion_Y_vs_mag_270,pairwise~condition)
emmeans(CoM_Excursion_Y_vs_mag_270,pairwise~PD)
print(CoM_Excursion_Y_vs_mag_270_tmp_table)
sink()

### plot Gains_Ag_TotalDual_CoM_4 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 

# save forward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_4_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 

# save backward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_4_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 

# save forward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_4_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 

# save backward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_4_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_4") 
dev.off()
### plot Gains_Ag_TotalDual_CoM_8 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 

# save forward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_8_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 

# save backward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_8_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.5) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 

# save forward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_8_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 

# save backward pert
pdf("SRM_refit_Gains_Ag_TotalDual_CoM_8_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Ag_TotalDual_CoM_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Ag_TotalDual_CoM_8") 
dev.off()
### plot Gains_Antag_4 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 

# save forward pert
pdf("SRM_refit_Gains_Antag_4_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 

# save backward pert
pdf("SRM_refit_Gains_Antag_4_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 

# save forward pert
pdf("SRM_refit_Gains_Antag_4_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 

# save backward pert
pdf("SRM_refit_Gains_Antag_4_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Antag_4, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_4") 
dev.off()
### plot Gains_Antag_8 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 

# save forward pert
pdf("SRM_refit_Gains_Antag_8_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 

# save backward pert
pdf("SRM_refit_Gains_Antag_8_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 

# save forward pert
pdf("SRM_refit_Gains_Antag_8_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 

# save backward pert
pdf("SRM_refit_Gains_Antag_8_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = Gains_Antag_8, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Antag_8, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0.05, 0.25) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "Gains_Antag_8") 
dev.off()
### plot fit_agonist_TotalDual_CoM_1 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 

# save forward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_1_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 

# save backward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_1_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 

# save forward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_1_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 

# save backward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_1_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_1") 
dev.off()
### plot fit_agonist_TotalDual_CoM_2 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 

# save forward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_2_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 

# save backward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_2_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 

# save forward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_2_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 

# save backward pert
pdf("SRM_refit_fit_agonist_TotalDual_CoM_2_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_agonist_TotalDual_CoM_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_agonist_TotalDual_CoM_2") 
dev.off()
### plot fit_antagonist_1 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 

# save forward pert
pdf("SRM_refit_fit_antagonist_1_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 

# save backward pert
pdf("SRM_refit_fit_antagonist_1_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 

# save forward pert
pdf("SRM_refit_fit_antagonist_1_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 

# save backward pert
pdf("SRM_refit_fit_antagonist_1_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_antagonist_1, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_1") 
dev.off()
### plot fit_antagonist_2 for each participant ####
# plot OA
# forward pert
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 

# save forward pert
pdf("SRM_refit_fit_antagonist_2_dm_90_pd0.pdf")
ggplot(data = dm_90_pd0, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 
dev.off()

# backward pert
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 

# save backward pert
pdf("SRM_refit_fit_antagonist_2_dm_270_pd0.pdf")
ggplot(data = dm_270_pd0, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 
dev.off()

# plot PD
# forward pert
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 

# save forward pert
pdf("SRM_refit_fit_antagonist_2_dm_90_pd1.pdf")
ggplot(data = dm_90_pd1, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Forward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 
dev.off()

# backward pert
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 

# save backward pert
pdf("SRM_refit_fit_antagonist_2_dm_270_pd1.pdf")
ggplot(data = dm_270_pd1, aes(x = condition, y = fit_antagonist_2, colour = condition)) +
  geom_point() +
  geom_text(
    aes(label = round(Gains_Ag_TotalDual_CoM_4, 3)),  # Label values, rounded to 3 decimal places
    vjust = -0.5,                                     # Slightly above the points
    size = 3
  ) +
  facet_wrap(~patient) +
  ylim(0,1) +
  labs(title = "Backward Perturbation", x = "Magnitude", y = "fit_antagonist_2") 
dev.off()
#### height group Comparison ####
# Run t-test on original numeric PD variable
t_test_result <- t.test(height_cm ~ PD, data = dm_1cond)
p_val <- signif(t_test_result$p.value, 3)

# Plot
ggplot(dm_1cond, aes(x = PD, y = height_cm, fill = PD)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.1, height = 0, size = 2, alpha = 0.6) +
  scale_fill_manual(values = c("0" = "#f8992c", "1" = "#cb4e27")) +
  labs(
    x = "Group",
    y = "Height (cm)",
    title = "Height by Group",
    subtitle = paste("t-test p-value:", p_val)
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")
#### ####
std_by_patient <- dm_90 %>%
  group_by(patient) %>%
  summarise(
    sd_Gains = sd(Gains_Ag_TotalDual_CoM_8, na.rm = TRUE)
  ) %>%
  arrange(desc(sd_Gains))  # Sort by SD, highest first


print(n=36, std_by_patient)

# Assuming std_by_patient was created as before
average_sd <- mean(std_by_patient$sd_Gains, na.rm = TRUE)

# Print the result
print(paste("Average participant SD:", round(average_sd, 3)))

#### Latency ####
# Pivot the data longer for the two variables of interest
dm_long <- dm %>%
  select(PD, condition, N1_latency, Gains_Ag_TotalDual_CoM_8) %>%
  pivot_longer(
    cols = c(N1_latency, Gains_Ag_TotalDual_CoM_8),
    names_to = "variable",
    values_to = "value"
  ) %>%
  filter(!is.na(value))  # remove rows where the value is NA

# Plot with side-by-side boxplots for each variable per condition
ggplot(dm_long, aes(x = factor(condition), y = value, fill = variable)) +
  geom_boxplot(position = position_dodge(width = 0.75), outlier.shape = NA) +
  geom_jitter(
    aes(color = variable),
    position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.75),
    alpha = 0.5,
    size = 1.5
  ) +
  facet_wrap(~ PD) +
  labs(
    title = "N1 and Ag 2nd burst",
    x = "Perturbation Magnitude",
    y = "Latency (s)"
  ) +
  theme_minimal(base_size = 14)


ggplot(dm, aes(x = N1_amp, y = Gains_Ag_TotalDual_CoM_5)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "steelblue") +
  facet_wrap(~ PD) +
  labs(
    title = "N1 Amplitude vs ka2",
    x = "N1 Amplitude",
    y = "Gains_Ag_TotalDual_CoM_5"
  ) +
  theme_minimal(base_size = 14)

ggplot(dm, aes(x = N1_amp, y = ctx_comp_ag_AUC)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "darkgreen") +
  facet_wrap(~ PD) +
  labs(
    title = "N1 Amplitude vs Agonist Cortical AUC",
    x = "N1 Amplitude",
    y = "Cortical AUC (Agonist)"
  ) +
  theme_minimal(base_size = 14)

ggplot(dm, aes(x = N1_amp, y = ctx_comp_ag_AUC_percent)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "firebrick") +
  facet_wrap(~ PD) +
  labs(
    title = "N1 Amplitude vs Cortical AUC (%)",
    x = "N1 Amplitude",
    y = "Cortical AUC (Agonist, %)"
  ) +
  theme_minimal(base_size = 14)

