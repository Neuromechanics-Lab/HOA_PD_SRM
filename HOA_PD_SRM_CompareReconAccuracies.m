%% Script to compare reconstruction accuracies between SRM reconstructions
clear; close all; 

Thresholded = load('X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs_Threshold_27-Feb-2024.mat');

NotThresholded = load('X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs__26-Feb-2024.mat');

%Extract variables
thresholded_fit_ag_TotalDualCoM_R2 = Thresholded.dataAv.fit_agonist_TotalDual_CoM(:,1);
thresholded_fit_antag_R2 = Thresholded.dataAv.fit_antagonist(:,1);

not_thresholded_fit_ag_TotalDualCoM_R2 = NotThresholded.dataAv.fit_agonist_TotalDual_CoM(:,1);
not_thresholded_fit_antag_R2 = NotThresholded.dataAv.fit_antagonist(:,1);

thresholded_fit_ag_TotalDualCoM_VAF = Thresholded.dataAv.fit_agonist_TotalDual_CoM(:,2);
thresholded_fit_antag_VAF = Thresholded.dataAv.fit_antagonist(:,2);

not_thresholded_fit_ag_TotalDualCoM_VAF = NotThresholded.dataAv.fit_agonist_TotalDual_CoM(:,2);
not_thresholded_fit_antag_VAF = NotThresholded.dataAv.fit_antagonist(:,2);

% Create a bar plot comparing the 'fit' variable
figure;
subplot(2,2,1)
h = bar([mean(thresholded_fit_ag_TotalDualCoM_R2), mean(not_thresholded_fit_ag_TotalDualCoM_R2)], 'grouped');
xlabel('Group'); xticklabels({'Thresholded','Not Thresholded'})
ylabel('Mean R2'); ylim([0 1])
title('hSRM- CoM Reconstruction comparison');

subplot(2,2,2)
h2 = bar([mean(thresholded_fit_antag_R2), mean(not_thresholded_fit_antag_R2)], 'grouped');
xlabel('Group'); xticklabels({'Thresholded','Not Thresholded'})
ylabel('Mean R2'); ylim([0 1])
title('Antagonist SRM Reconstruction comparison');

subplot(2,2,3)
h = bar([mean(thresholded_fit_ag_TotalDualCoM_VAF), mean(not_thresholded_fit_ag_TotalDualCoM_VAF)], 'grouped');
xlabel('Group'); xticklabels({'Thresholded','Not Thresholded'})
ylabel('Mean VAF'); ylim([0 1])
title('hSRM- CoM Reconstruction comparison');

subplot(2,2,4)
h2 = bar([mean(thresholded_fit_antag_VAF), mean(not_thresholded_fit_antag_VAF)], 'grouped');
xlabel('Group'); xticklabels({'Thresholded','Not Thresholded'})
ylabel('Mean VAF');ylim([0 1])
title('Antagonist SRM Reconstruction comparison');



