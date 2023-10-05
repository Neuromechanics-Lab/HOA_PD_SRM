clear; close all; clc
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')
fdir = 'C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\SRM Analysis\savedfigs';
savefigopt = 1;
analysisdate = '16-Nov-2021';

% load data
load(['C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\Beta Analysis\HOA_Beta_' analysisdate '.mat'])
HOA_dataTable_trial = dataTable_trial;
HOA_dataTable_trialavg = dataTable_trialavg;

load(['C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\Beta Analysis\PD_Beta_' analysisdate '.mat'])
PD_dataTable_trial = dataTable_trial;
PD_dataTable_trialavg = dataTable_trialavg;

clear dataTable_trial dataTable_trialavg
PD_dataTable_trial.group = string(PD_dataTable_trial.group);
HOA_dataTable_trial.group = string(HOA_dataTable_trial.group);
dataTable_trial = [HOA_dataTable_trial; PD_dataTable_trial];

PD_dataTable_trialavg.group = string(PD_dataTable_trialavg.group);
HOA_dataTable_trialavg.group = string(HOA_dataTable_trialavg.group);
dataTable_trialavg = [HOA_dataTable_trialavg; PD_dataTable_trialavg];

load('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM_Gio\SRMFits_12-Oct-2021.mat');
%index just PD
ind_PD = unique(SRMFits.patient);
ind_PD = ind_PD(20:end);

SRMFits.group(ismember(SRMFits.patient,ind_PD),:) = 1;

PD_HOA_table = readtable('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\HOA\PD_HOA_Summary.xlsx');

z = PD_HOA_table.z(PD_HOA_table.PD ==1 | PD_HOA_table.PD ==0);
minibest = PD_HOA_table.minibest(PD_HOA_table.PD ==1 | PD_HOA_table.PD ==0);
idx_grp = [0 1];
idx_group = ["0","1"];
%%
yl = [0 1]; ylim(yl)
for i = 1:length(idx_grp)
    grp = idx_grp(i);
    group = idx_group(i);
    %% Plot SRM Recon Accuracy against beta_0_500
    figure; set(gcf,'WindowState','maximized')
    plotij(3,2,1,1)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L"),'go','MarkerFaceColor','g')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Forward Low Mag'); ylim(yl)
    
    plotij(3,2,1,2)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L"),'go','MarkerFaceColor','g')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Backward Low Mag'); ylim(yl)
    
    plotij(3,2,2,1)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M"),'bo','MarkerFaceColor','b')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Forward Med Mag'); ylim(yl)
    
    plotij(3,2,2,2)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M"),'bo','MarkerFaceColor','b')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Backward Med Mag'); ylim(yl)
    
    plotij(3,2,3,1)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H"),'ro','MarkerFaceColor','r')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Forward High Mag'); ylim(yl)
    
    plotij(3,2,3,2)
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H"),'ro','MarkerFaceColor','r')
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms')
    title('Backward High Mag'); ylim(yl)
    
    if grp == 1
        sgtitle('PD Beta Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\PD Beta R2 vs beta_0_500_indv cond.fig'],'fig')
            saveas(gcf,[fdir '\PD Beta R2 vs beta_0_500_indv cond.jpg'],'jpg')
            print([fdir '\PD Beta R2 vs beta_0_500_indv cond.eps'], '-depsc','-painters')
        end
    elseif grp == 0
        sgtitle('HOA Beta Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\HOA Beta R2 vs beta_0_500_indv cond.fig'],'fig')
            saveas(gcf,[fdir '\HOA Beta R2 vs beta_0_500_indv cond.jpg'],'jpg')
            print([fdir '\HOA Beta R2 vs beta_0_500_indv cond.eps'], '-depsc','-painters')
        end
    end
    %% Plot Beta 0-400 vs SRM beta recon
    figure; set(gcf,'WindowState','maximized')
    plotij(1,2,1,1); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_BetaR2_F = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L");...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M");...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H")]);
    plot(lm_beta_0_500_BetaR2_F,'Marker','none')
    
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms'); legend('off'); ylim(yl)
    title({['Forward All Mags'];...
        ['R2 = ' num2str(lm_beta_0_500_BetaR2_F.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_BetaR2_F.Coefficients.pValue(2))]})
    
    plotij(1,2,1,2); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_BetaR2_B = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L");...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M");...
        SRMFits.fit(SRMFits.mus == "beta_norm" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H")]);
    plot(lm_beta_0_500_BetaR2_B,'Marker','none')
    
    ylabel('Beta Recon R2');xlabel('Beta 0-500ms'); ylim(yl)
    title({['Backward All Mags'];...
        ['R2 = ' num2str(lm_beta_0_500_BetaR2_B.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_BetaR2_B.Coefficients.pValue(2))]})
    legend('L','M','H')
    
    if grp == 1
        sgtitle('PD Beta Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\PD Beta R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\PD Beta R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\PD Beta R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    elseif grp == 0
        sgtitle('HOA Beta Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\HOA Beta R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\HOA Beta R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\HOA Beta R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    end
    %% Plot Beta TA_EMG vs SRM beta recon
    figure; set(gcf,'WindowState','maximized')
    plotij(1,2,1,1); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L" & SRMFits.side == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M" & SRMFits.side == "L"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H" & SRMFits.side == "L"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_TAR2_F = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L" & SRMFits.side == "L");...
        SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M" & SRMFits.side == "L");...
        SRMFits.fit(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H" & SRMFits.side == "L")]);
    plot(lm_beta_0_500_TAR2_F,'Marker','none')
    
    ylabel('TA Recon R2'); xlabel('Beta 0-500ms'); legend('off'); ylim(yl)
    title({['Forward All Mags (TA = Agonist)'];...
        ['R2 = ' num2str(lm_beta_0_500_TAR2_F.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_TAR2_F.Coefficients.pValue(2))]})
    
    plotij(1,2,1,2); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1),...
        SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L" & SRMFits.side == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2),...
        SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M" & SRMFits.side == "L"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3),...
        SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H" & SRMFits.side == "L"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_TAR2_B = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L" & SRMFits.side == "L");...
        SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M" & SRMFits.side == "L");...
        SRMFits.fitTotal(SRMFits.mus == "TA" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H" & SRMFits.side == "L")]);
    plot(lm_beta_0_500_TAR2_B,'Marker','none')
    
    ylabel('TA Recon R2'); xlabel('Beta 0-500ms'); ylim(yl)
    title({['Backward All Mags (TA = Antagonist)'];...
        ['R2 = ' num2str(lm_beta_0_500_TAR2_B.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_TAR2_B.Coefficients.pValue(2))]})
    legend('L','M','H')
    
    if grp == 1
        sgtitle('PD TA Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\PD TA R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\PD TA R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\PD TA R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    elseif grp == 0
        sgtitle('HOA TA Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\HOA TA R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\HOA TA R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\HOA TA R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    end
    
    %% Plot Beta MG EMG vs SRM beta recon
    figure; set(gcf,'WindowState','maximized')
    plotij(1,2,1,1); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1),...
        SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L" & SRMFits.side == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2),...
        SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M" & SRMFits.side == "L"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3),...
        SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H" & SRMFits.side == "L"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_MGASR2_F = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 90 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "L" & SRMFits.side == "L");...
        SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "M" & SRMFits.side == "L");...
        SRMFits.fitTotal(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 90 & SRMFits.pertmagn == "H" & SRMFits.side == "L")]);
    plot(lm_beta_0_500_MGASR2_F,'Marker','none')
    
    ylabel('MG Recon R2'); xlabel('Beta 0-500ms'); legend('off'); ylim(yl)
    title({['Forward All Mags (MG = Antagonist)'];...
        ['R2 = ' num2str(lm_beta_0_500_MGASR2_F.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_MGASR2_F.Coefficients.pValue(2))]})
    
    
    plotij(1,2,1,2); hold on
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1),...
        SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L" & SRMFits.side == "L"),'go','MarkerFaceColor','g')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2),...
        SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M" & SRMFits.side == "L"),'bo','MarkerFaceColor','b')
    plot(dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3),...
        SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H" & SRMFits.side == "L"),'ro','MarkerFaceColor','r')
    
    lm_beta_0_500_TAR2_B = fitlm([dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 1);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 2);...
        dataTable_trialavg.avg_beta_0_500(dataTable_trialavg.group == group & dataTable_trialavg.direc == 270 & dataTable_trialavg.mag == 3)],...
        [SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "L" & SRMFits.side == "L");...
        SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "M" & SRMFits.side == "L");...
        SRMFits.fit(SRMFits.mus == "MGAS" & SRMFits.group == grp & SRMFits.pertdir == 270 & SRMFits.pertmagn == "H" & SRMFits.side == "L")]);
    plot(lm_beta_0_500_TAR2_B,'Marker','none')
    
    ylabel('MG Recon R2');xlabel('Beta 0-500ms'); ylim(yl)
    title({['Backward All Mags (MG = Agonist)'];...
        ['R2 = ' num2str(lm_beta_0_500_TAR2_B.Rsquared.Adjusted) '     p = ' num2str(lm_beta_0_500_TAR2_B.Coefficients.pValue(2))]})
    legend('L','M','H')
    
    if grp == 1
        sgtitle('PD MG Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\PD MG R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\PD MG R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\PD MG R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    elseif grp == 0
        sgtitle('HOA MG Recon vs Evoked Beta (0-500ms)')
        if savefigopt == 1
            saveas(gcf,[fdir '\HOA MG R2 vs beta_0_500.fig'],'fig')
            saveas(gcf,[fdir '\HOA MG R2 vs beta_0_500.jpg'],'jpg')
            print([fdir '\HOA MG R2 vs beta_0_500.eps'], '-depsc','-painters')
        end
    end
    1;
end