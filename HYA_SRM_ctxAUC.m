% to calculate AUC for cortical component in HYA SRM Data
clear; close all; clc
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
%% load data
fdir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\';
savedir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\';

load([fdir 'HYAStep_SRM_Outputs_15-Aug-2023.mat'])
%% User input
plotopt = true;
savefigopt = true;
figdir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\savedfigs\';
AnalysisType = ''; %analysis type

%% Calculate Cortical component Area under the curve
% initialize output variables
ctx_comp_ag  = nan(size(DataAvTable.AgonistRecon_TotalDual_CoM));
ctx_comp_ag_AUC  = nan(size(DataAvTable.direc));

subctx_comp_ag  = nan(size(DataAvTable.AgonistRecon_TotalDual_CoM));
subctx_comp_ag_AUC  = nan(size(DataAvTable.direc));

for i = 1:height(DataAvTable)
    %% specify CoM kinematics and time window
    atime = DataAvTable.atime(i,:); % Modify CoM acc with stiction model from Welch and Ting 2009
    a = DataAvTable.cacc(i,:);
    a = stictionTemplate('a',a,'t',atime);
    v = DataAvTable.cvel(i,:);
    d = DataAvTable.cpos_minus(i,:);
    % remove basline from CoM kinematics - not needed for "a" due to stiction model
    d = d-mean(d(DataAvTable.atime(1,:)<-0.1));
    v = v-mean(v(DataAvTable.atime(1,:)<-0.1));
    % specify time fit by SRM - FROM HYA_Step_SRM.m
    max_time = 1.2;
    min_time = -0.1;
    ind_time = find(DataAvTable.atime(1,:) > min_time & DataAvTable.atime(1,:) <= max_time); % adjust window that will be fit by the SRM
    
    %% flip the CoM kinematic signal depending on pert direction and specify ag/antag EMG
    if DataAvTable.direc(i) == 90 %forward pert
        a_ag = -a; v_ag = -v; d_ag = -d;
        a_antag = a; v_antag = v; d_antag = d;
    elseif DataAvTable.direc(i) == 270 %backward pert
        a_ag = a; v_ag = v; d_ag = d;
        a_antag = -a; v_antag = -v; d_antag = -d;
    end
    %% calculate subctx and ctx components for Agonist hSRM
    predictors_ag = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time);...
        a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % hSRM predictors
    Gains_ag = DataAvTable.Ag_Gains_TotalDual_CoM(i,:); %hSRM reconstruction gains
    [Recon_ag, tmp_subctx_comp_ag, tmp_ctx_comp_ag] = assembleTwoChannels(predictors_ag(1:3,:),Gains_ag(1:3),Gains_ag(4),...
        predictors_ag(4:6,:),Gains_ag(5:7),Gains_ag(end),atime(ind_time));
    ctx_comp_ag(i,:) = tmp_ctx_comp_ag;
    subctx_comp_ag(i,:) = tmp_subctx_comp_ag;
    
    ctx_comp_ag_AUC(i,:) = trapz(atime(ind_time), tmp_ctx_comp_ag);
    subctx_comp_ag_AUC(i,:) = trapz(atime(ind_time), tmp_subctx_comp_ag);
    
    %% plot components for confirmation
    if plotopt
        figure; set(gcf,'Position',[387.4000 427.4000 1432 489.6000])
        plotij(1,2,1,1); hold on
        plot(atime(ind_time), Recon_ag,'k','LineWidth',3)
        plot(atime(ind_time), tmp_subctx_comp_ag,'r','LineWidth',1)
        plot(atime(ind_time), tmp_ctx_comp_ag,'b','LineWidth',1)
        title('hSRM Components'); xlabel('time (s)')
        legend('Recon','subctx','ctx')
        
        plotij(1,2,1,2)
        bar([subctx_comp_ag_AUC(i,:) ctx_comp_ag_AUC(i,:)])
        xticklabels({'subctx AUC', 'ctx AUC'})
        xtickangle(45); ylim([0 0.5])
        
        sgtitle(DataAvTable.Participant(i) + " mag" + num2str(DataAvTable.mag(i)) + " dir" + num2str(DataAvTable.direc(i)))
        
        if savefigopt
            saveas(gcf,figdir + "HYA_" + num2str(DataAvTable.Participant(i)) + "_mag" + num2str(DataAvTable.mag(i)) +...
                "_dir" + num2str(DataAvTable.direc(i)) + '_SRMcomps_AUC.fig','fig')
            saveas(gcf,figdir + "HYA_" + num2str(DataAvTable.Participant(i)) + "_mag" + num2str(DataAvTable.mag(i)) +...
                "_dir" + num2str(DataAvTable.direc(i)) + '_SRMcomps_AUC.jpg','jpg')
            print(gcf,'-depsc2',figdir + "HYA_" + num2str(DataAvTable.Participant(i)) + "_mag" + num2str(DataAvTable.mag(i)) +...
                "_dir" + num2str(DataAvTable.direc(i)) + '_SRMcomps_AUC.eps')
        end
        close all
    end
    
    
end
%% concatinate data tables
%create data table
T = table(ctx_comp_ag, subctx_comp_ag, ctx_comp_ag_AUC, subctx_comp_ag_AUC);
T_excel = table(ctx_comp_ag_AUC, subctx_comp_ag_AUC);
% concatinate tables
DataAvTable = [DataAvTable T];
ExcelTable(ExcelTable.Participant == 3,:) = [];
ExcelTable(ExcelTable.Participant == 8,:) = [];
ExcelTable = [ExcelTable T_excel]; clear T T_excel
%% save output
save([savedir 'HYA_Step_SRM_AUC_Analysis_' AnalysisType date '.mat'], 'DataAvTable','ExcelTable')
writetable(ExcelTable,[savedir 'HYA_Step_SRM_AUC_Analysis_' AnalysisType date '.xlsx'])
