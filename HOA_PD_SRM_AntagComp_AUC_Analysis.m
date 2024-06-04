%% Script to calculate area under the curve for destabilizing antagonist EMG 
clear; close all;
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')
% load data
fdir = '\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\';
savedir = '\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\';
filename = 'HOA_PD_SRM_Outputs__24-Apr-2024_wAnalysis';
load([fdir filename '.mat'])

dataAv.ka_comp = []; dataAv.ka_comp_AUC = [];
dataAv.kv_kd_comp = []; dataAv.kv_kd_comp_AUC = [];
ExcelTable.ka_comp_AUC = [];
ExcelTable.kv_kd_comp_AUC = [];


plotopt = true;
savefigopt = true;
figdir = '\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\savedfigs\';
AnalysisType = ''; %analysis type

ka_comp = nan(size(dataAv.Recon_Antagonist));
ka_comp_AUC = nan(size(dataAv.condition));

kv_kd_comp = nan(size(dataAv.Recon_Antagonist));
kv_kd_comp_AUC = nan(size(dataAv.condition));

%% Calculate Area under the curve for each row of dataAv
for i = 1:height(dataAv)
    %% specify CoM kinematics and time window
    atime = dataAv.atime(i,:); % Modify CoM acc with stiction model from Welch and Ting 2009
    a = dataAv.COMAccel_Y(i,:);
    a = stictionTemplate('a',a,'t',atime);
    v = dataAv.COMVelo_Y(i,:);
    d = dataAv.COMPosminusLVDT_Y(i,:);
    % remove basline from CoM kinematics - not needed for "a" due to stiction model
    d = d-mean(d(dataAv.atime(1,:)<-0.1));
    v = v-mean(v(dataAv.atime(1,:)<-0.1));
    % specify time fit by SRM - FROM HOA_PD_SRM.m
    max_time = 1.2;
    min_time = -0.2;
    ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM
    
    %% flip the CoM kinematic signal depending on pert direction and specify ag/antag EMG
    if dataAv.pertdir_calc_round_deg(i) == 90 %forward pert
        a_ag = -a; v_ag = -v; d_ag = -d;
        a_antag = a; v_antag = v; d_antag = d;
    elseif dataAv.pertdir_calc_round_deg(i) == 270 %backward pert
        a_ag = a; v_ag = v; d_ag = d;
        a_antag = -a; v_antag = -v; d_antag = -d;
    end
    %% calculate destabilizing and braking components for Antagonist SRM
    predictorsDestabilizing = [-a_antag(ind_time); -v_antag(ind_time); -d_antag(ind_time)];
    Gains_antag = dataAv.Gains_Antag(i,:); %Antagonist SRM reconstruction gains

    %% ka' component AUC
    tmp_ka_comp = channelDelay(threshold(predictorsDestabilizing(1,:)'*Gains_antag(5)'),Gains_antag(8),atime(ind_time));    
    ka_comp(i,:) = tmp_ka_comp;

    ka_comp_AUC(i,:) = trapz(atime(ind_time),tmp_ka_comp);
    
    %% kv' + kd' (destabilizing) component AUC
    tmp_kv_kd_comp = channelDelay(threshold(predictorsDestabilizing(2:3,:)'*Gains_antag(6:7)'),Gains_antag(8),atime(ind_time));    
    kv_kd_comp(i,:) = tmp_kv_kd_comp;

    kv_kd_comp_AUC(i,:) = trapz(atime(ind_time),tmp_kv_kd_comp);
end

%% save
T = table(ka_comp,ka_comp_AUC, kv_kd_comp, kv_kd_comp_AUC);
T_excel = table(ka_comp_AUC, kv_kd_comp_AUC);

dataAv = [dataAv T];
ExcelTable = [ExcelTable T_excel];
fdir = '\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\';
savedir = '\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\';
filename = 'HOA_PD_SRM_Outputs__24-Apr-2024_wAnalysis';
save([fdir filename '.mat'],'dataAv','ExcelTable')