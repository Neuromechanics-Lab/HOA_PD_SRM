%% Script to create output measures for analysis and add to dataAv
clear; close all; clc
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
% load data
fdir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\';
savedir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\';
filename = 'HOA_PD_SRM_Outputs__24-Apr-2024';
load([fdir filename '.mat'])


plotopt = true;
savefigopt = true;
figdir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\savedfigs\';
AnalysisType = ''; %analysis type
%% create time indexes
ind_50_150  = create_ind(0.05,0.15,dataAv.atime(1,:));
ind_100_200 = create_ind(0.10,0.20,dataAv.atime(1,:));
ind_150_250 = create_ind(0.15,0.25,dataAv.atime(1,:));
ind_200_300 = create_ind(0.20,0.30,dataAv.atime(1,:));
ind_250_350 = create_ind(0.25,0.35,dataAv.atime(1,:));
ind_300_400 = create_ind(0.30,0.40,dataAv.atime(1,:));
ind_350_450 = create_ind(0.35,0.45,dataAv.atime(1,:));
ind_400_500 = create_ind(0.40,0.50,dataAv.atime(1,:));
ind_300_500 = create_ind(0.30,0.50,dataAv.atime(1,:));

%% initialize output variables
%beta
beta_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
beta_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
beta_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
beta_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
beta_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
beta_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
beta_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
beta_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

beta_300_500 = nan(size(dataAv.pertdir_calc_round_deg));

%N1
N1_amp = nan(size(dataAv.pertdir_calc_round_deg));
N1_latency = nan(size(dataAv.pertdir_calc_round_deg));
% EMG_MGAS_R
EMG_MGAS_R_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_R_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_MGAS_R_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));

%EMG_MGAS_L
EMG_MGAS_L_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_MGAS_L_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_MGAS_L_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
% EMG_SOL_R
EMG_SOL_R_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_SOL_R_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
%EMG_SOL_L
EMG_SOL_L_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_SOL_L_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
%EMG_TA_L
EMG_TA_L_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_TA_L_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
%EMG_TA_R
EMG_TA_R_norm_50_150  = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_100_200 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_150_250 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_200_300 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_250_350 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_300_400 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_350_450 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_R_norm_400_500 = nan(size(dataAv.pertdir_calc_round_deg));

EMG_TA_R_norm_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
%Specificity
EMG_TA_R_specificity_early = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_specificity_early = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_specificity_early = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_specificity_early = nan(size(dataAv.pertdir_calc_round_deg));

EMG_TA_R_specificity_late = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_specificity_late = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_specificity_late = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_specificity_late = nan(size(dataAv.pertdir_calc_round_deg));

EMG_TA_R_specificity_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_TA_L_specificity_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_R_specificity_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
EMG_SOL_L_specificity_300_500 = nan(size(dataAv.pertdir_calc_round_deg));
%% calculate mean output measures
for i = 1:height(dataAv)
    try % if no EEG data in dataAv then skip this
        % mean beta
        beta_50_150 (i, :) = mean(dataAv.beta_ersp(i,ind_50_150));
        beta_100_200(i, :) = mean(dataAv.beta_ersp(i,ind_100_200));
        beta_150_250(i, :) = mean(dataAv.beta_ersp(i,ind_150_250));
        beta_200_300(i, :) = mean(dataAv.beta_ersp(i,ind_200_300));
        beta_250_350(i, :) = mean(dataAv.beta_ersp(i,ind_250_350));
        beta_300_400(i, :) = mean(dataAv.beta_ersp(i,ind_300_400));
        beta_350_450(i, :) = mean(dataAv.beta_ersp(i,ind_350_450));
        beta_400_500(i, :) = mean(dataAv.beta_ersp(i,ind_400_500));
        
        beta_300_500(i, :) = mean(dataAv.beta_ersp(i,ind_300_500));
        
        %N1
        [N1_amp_tmp, ind_tmp] = min(dataAv.Cz(i,ind_100_200));
        N1_amp(i, :) = N1_amp_tmp; ind_N1_latency = find(ind_100_200);
        N1_latency(i, :) = dataAv.atime(i,ind_N1_latency(ind_tmp));
    catch
    end
    
    % mean EMG_MGAS_R_norm
    EMG_MGAS_R_norm_50_150 (i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_50_150));
    EMG_MGAS_R_norm_100_200(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_100_200));
    EMG_MGAS_R_norm_150_250(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_150_250));
    EMG_MGAS_R_norm_200_300(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_200_300));
    EMG_MGAS_R_norm_250_350(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_250_350));
    EMG_MGAS_R_norm_300_400(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_300_400));
    EMG_MGAS_R_norm_350_450(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_350_450));
    EMG_MGAS_R_norm_400_500(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_400_500));
    EMG_MGAS_R_norm_300_500(i, :) = mean(dataAv.EMG_MGAS_R_norm(i,ind_300_500));
    % mean EMG_MGAS_L_norm
    EMG_MGAS_L_norm_50_150 (i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_50_150));
    EMG_MGAS_L_norm_100_200(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_100_200));
    EMG_MGAS_L_norm_150_250(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_150_250));
    EMG_MGAS_L_norm_200_300(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_200_300));
    EMG_MGAS_L_norm_250_350(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_250_350));
    EMG_MGAS_L_norm_300_400(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_300_400));
    EMG_MGAS_L_norm_350_450(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_350_450));
    EMG_MGAS_L_norm_400_500(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_400_500));
    EMG_MGAS_L_norm_300_500(i, :) = mean(dataAv.EMG_MGAS_L_norm(i,ind_300_500));
    % mean EMG_SOL_R_norm
    EMG_SOL_R_norm_50_150 (i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_50_150));
    EMG_SOL_R_norm_100_200(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_100_200));
    EMG_SOL_R_norm_150_250(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_150_250));
    EMG_SOL_R_norm_200_300(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_200_300));
    EMG_SOL_R_norm_250_350(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_250_350));
    EMG_SOL_R_norm_300_400(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_300_400));
    EMG_SOL_R_norm_350_450(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_350_450));
    EMG_SOL_R_norm_400_500(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_400_500));
    EMG_SOL_R_norm_300_500(i, :) = mean(dataAv.EMG_SOL_R_norm(i,ind_300_500));
    % mean EMG_SOL_L_norm
    EMG_SOL_L_norm_50_150 (i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_50_150));
    EMG_SOL_L_norm_100_200(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_100_200));
    EMG_SOL_L_norm_150_250(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_150_250));
    EMG_SOL_L_norm_200_300(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_200_300));
    EMG_SOL_L_norm_250_350(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_250_350));
    EMG_SOL_L_norm_300_400(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_300_400));
    EMG_SOL_L_norm_350_450(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_350_450));
    EMG_SOL_L_norm_400_500(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_400_500));
    EMG_SOL_L_norm_300_500(i, :) = mean(dataAv.EMG_SOL_L_norm(i,ind_300_500));
    % mean EMG_TA_L_norm
    EMG_TA_L_norm_50_150 (i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_50_150));
    EMG_TA_L_norm_100_200(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_100_200));
    EMG_TA_L_norm_150_250(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_150_250));
    EMG_TA_L_norm_200_300(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_200_300));
    EMG_TA_L_norm_250_350(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_250_350));
    EMG_TA_L_norm_300_400(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_300_400));
    EMG_TA_L_norm_350_450(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_350_450));
    EMG_TA_L_norm_400_500(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_400_500));
    EMG_TA_L_norm_300_500(i, :) = mean(dataAv.EMG_TA_L_norm(i,ind_300_500));
    % mean EMG_TA_R_norm
    EMG_TA_R_norm_50_150 (i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_50_150));
    EMG_TA_R_norm_100_200(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_100_200));
    EMG_TA_R_norm_150_250(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_150_250));
    EMG_TA_R_norm_200_300(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_200_300));
    EMG_TA_R_norm_250_350(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_250_350));
    EMG_TA_R_norm_300_400(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_300_400));
    EMG_TA_R_norm_350_450(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_350_450));
    EMG_TA_R_norm_400_500(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_400_500));
    EMG_TA_R_norm_300_500(i, :) = mean(dataAv.EMG_TA_R_norm(i,ind_300_500));
end
%% concatinate data tables
%create data table
try
    T = table(beta_50_150, beta_100_200, beta_150_250, beta_200_300, beta_250_350,beta_300_400, beta_350_450, beta_400_500,beta_300_500,...
        N1_amp,N1_latency,...
        EMG_MGAS_R_norm_50_150,EMG_MGAS_R_norm_100_200,EMG_MGAS_R_norm_150_250,EMG_MGAS_R_norm_200_300,EMG_MGAS_R_norm_250_350,EMG_MGAS_R_norm_300_400,EMG_MGAS_R_norm_350_450,EMG_MGAS_R_norm_400_500, EMG_MGAS_R_norm_300_500,...
        EMG_MGAS_L_norm_50_150,EMG_MGAS_L_norm_100_200,EMG_MGAS_L_norm_150_250,EMG_MGAS_L_norm_200_300,EMG_MGAS_L_norm_250_350,EMG_MGAS_L_norm_300_400,EMG_MGAS_L_norm_350_450,EMG_MGAS_L_norm_400_500, EMG_MGAS_L_norm_300_500,...
        EMG_SOL_R_norm_50_150,EMG_SOL_R_norm_100_200,EMG_SOL_R_norm_150_250,EMG_SOL_R_norm_200_300,EMG_SOL_R_norm_250_350,EMG_SOL_R_norm_300_400,EMG_SOL_R_norm_350_450,EMG_SOL_R_norm_400_500, EMG_SOL_R_norm_300_500,...
        EMG_SOL_L_norm_50_150,EMG_SOL_L_norm_100_200,EMG_SOL_L_norm_150_250,EMG_SOL_L_norm_200_300,EMG_SOL_L_norm_250_350,EMG_SOL_L_norm_300_400,EMG_SOL_L_norm_350_450,EMG_SOL_L_norm_400_500, EMG_SOL_L_norm_300_500,...
        EMG_TA_L_norm_50_150, EMG_TA_L_norm_100_200,EMG_TA_L_norm_150_250,EMG_TA_L_norm_200_300,EMG_TA_L_norm_250_350,EMG_TA_L_norm_300_400,EMG_TA_L_norm_350_450,EMG_TA_L_norm_400_500, EMG_TA_L_norm_300_500,...
        EMG_TA_R_norm_50_150, EMG_TA_R_norm_100_200,EMG_TA_R_norm_150_250,EMG_TA_R_norm_200_300,EMG_TA_R_norm_250_350,EMG_TA_R_norm_300_400,EMG_TA_R_norm_350_450,EMG_TA_R_norm_400_500, EMG_TA_R_norm_300_500);
catch
    T = table(EMG_MGAS_R_norm_50_150,EMG_MGAS_R_norm_100_200,EMG_MGAS_R_norm_150_250,EMG_MGAS_R_norm_200_300,EMG_MGAS_R_norm_250_350,EMG_MGAS_R_norm_300_400,EMG_MGAS_R_norm_350_450,EMG_MGAS_R_norm_400_500, EMG_MGAS_R_norm_300_500,...
        EMG_MGAS_L_norm_50_150,EMG_MGAS_L_norm_100_200,EMG_MGAS_L_norm_150_250,EMG_MGAS_L_norm_200_300,EMG_MGAS_L_norm_250_350,EMG_MGAS_L_norm_300_400,EMG_MGAS_L_norm_350_450,EMG_MGAS_L_norm_400_500, EMG_MGAS_L_norm_300_500,...
        EMG_SOL_R_norm_50_150,EMG_SOL_R_norm_100_200,EMG_SOL_R_norm_150_250,EMG_SOL_R_norm_200_300,EMG_SOL_R_norm_250_350,EMG_SOL_R_norm_300_400,EMG_SOL_R_norm_350_450,EMG_SOL_R_norm_400_500, EMG_SOL_R_norm_300_500,...
        EMG_SOL_L_norm_50_150,EMG_SOL_L_norm_100_200,EMG_SOL_L_norm_150_250,EMG_SOL_L_norm_200_300,EMG_SOL_L_norm_250_350,EMG_SOL_L_norm_300_400,EMG_SOL_L_norm_350_450,EMG_SOL_L_norm_400_500, EMG_SOL_L_norm_300_500,...
        EMG_TA_L_norm_50_150, EMG_TA_L_norm_100_200,EMG_TA_L_norm_150_250,EMG_TA_L_norm_200_300,EMG_TA_L_norm_250_350,EMG_TA_L_norm_300_400,EMG_TA_L_norm_350_450,EMG_TA_L_norm_400_500, EMG_TA_L_norm_300_500,...
        EMG_TA_R_norm_50_150, EMG_TA_R_norm_100_200,EMG_TA_R_norm_150_250,EMG_TA_R_norm_200_300,EMG_TA_R_norm_250_350,EMG_TA_R_norm_300_400,EMG_TA_R_norm_350_450,EMG_TA_R_norm_400_500, EMG_TA_R_norm_300_500);
    
end
% concatinate tables
dataAv = [dataAv T];
ExcelTable = [ExcelTable T]; clear T
%% calculate specificity
participants = unique(dataAv.patient);
mags = unique(dataAv.condition);
for i = 1:length(participants)
    participant = participants(i);
    for ii = 1:length(mags)
        mag = mags(ii);
        ind = strcmp(dataAv.patient,participant) & dataAv.condition == mag;
        if isempty(find(ind)) % skip this loop if there is no participant/magnitude/direction pair
            break
        end
        % calculate specificity:
        % specificity = abs((EMG_forward - EMG_backward))/max(EMG_forward,EMG_backward);
        TA_R_F_early = dataAv.EMG_TA_R_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_R_B_early = dataAv.EMG_TA_R_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_R_specificity_early(ind,:) = calc_specificity(TA_R_F_early, TA_R_B_early);
        
        TA_L_F_early = dataAv.EMG_TA_L_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_L_B_early = dataAv.EMG_TA_L_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_L_specificity_early(ind,:) = calc_specificity(TA_L_F_early, TA_L_B_early);
        
        SOL_R_F_early = dataAv.EMG_SOL_R_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_R_B_early = dataAv.EMG_SOL_R_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_R_specificity_early(ind,:) = calc_specificity(SOL_R_F_early, SOL_R_B_early);
        
        SOL_L_F_early = dataAv.EMG_SOL_L_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_L_B_early = dataAv.EMG_SOL_L_norm_100_200(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_L_specificity_early(ind,:) = calc_specificity(SOL_L_F_early, SOL_L_B_early);
        
        TA_R_F_late = dataAv.EMG_TA_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_R_B_late = dataAv.EMG_TA_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_R_specificity_late(ind,:) = calc_specificity(TA_R_F_late, TA_R_B_late);
        
        TA_L_F_late = dataAv.EMG_TA_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_L_B_late = dataAv.EMG_TA_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_L_specificity_late(ind,:) = calc_specificity(TA_L_F_late, TA_L_B_late);
        
        SOL_R_F_late = dataAv.EMG_SOL_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_R_B_late = dataAv.EMG_SOL_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_R_specificity_late(ind,:) = calc_specificity(SOL_R_F_late, SOL_R_B_late);
        
        SOL_L_F_late = dataAv.EMG_SOL_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_L_B_late = dataAv.EMG_SOL_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_L_specificity_late(ind,:) = calc_specificity(SOL_L_F_late, SOL_L_B_late);
        
        TA_R_F_300_500 = dataAv.EMG_TA_R_norm_300_400(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_R_B_300_500 = dataAv.EMG_TA_R_norm_300_400(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_R_specificity_300_500(ind,:) = calc_specificity(TA_R_F_300_500,  TA_R_B_300_500);
        
        TA_L_F_300_500 = dataAv.EMG_TA_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        TA_L_B_300_500 = dataAv.EMG_TA_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_TA_L_specificity_300_500(ind,:) = calc_specificity(TA_L_F_300_500, TA_L_B_300_500);
        
        SOL_R_F_300_500 = dataAv.EMG_SOL_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_R_B_300_500 = dataAv.EMG_SOL_R_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_R_specificity_300_500(ind,:) = calc_specificity(SOL_R_F_300_500, SOL_R_B_300_500);
        
        SOL_L_F_300_500 = dataAv.EMG_SOL_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 90,:);
        SOL_L_B_300_500 = dataAv.EMG_SOL_L_norm_200_300(ind & dataAv.pertdir_calc_round_deg == 270,:);
        EMG_SOL_L_specificity_300_500(ind,:) = calc_specificity(SOL_L_F_300_500, SOL_L_B_300_500);
        
        if plotopt
            figure;
            plotij(2,2,1,1); hold on
            plot(dataAv.atime(1,:),dataAv.EMG_SOL_L_norm(ind & dataAv.pertdir_calc_round_deg == 90,:),'r')
            plot(dataAv.atime(1,:),dataAv.EMG_SOL_L_norm(ind & dataAv.pertdir_calc_round_deg == 270,:),'b')
            plot([0 0], [0 1],'k--'); plot([0.1 0.2],[1.1 1.1],'k-'); plot([0.2 0.3],[1 1],'k-');
            xlim([-0.1 1])
            title('SOL_L'); legend('Forward','Backward');
            plotij(2,2,1,2); hold on
            plot(dataAv.atime(1,:),dataAv.EMG_SOL_R_norm(ind & dataAv.pertdir_calc_round_deg == 90,:),'r')
            plot(dataAv.atime(1,:),dataAv.EMG_SOL_R_norm(ind & dataAv.pertdir_calc_round_deg == 270,:),'b')
            plot([0 0], [0 1],'k--'); plot([0.1 0.2],[1.1 1.1],'k-'); plot([0.2 0.3],[1 1],'k-');
            xlim([-0.1 1])
            title('SOL_R');
            plotij(2,2,2,1); hold on
            plot(dataAv.atime(1,:),dataAv.EMG_TA_L_norm(ind & dataAv.pertdir_calc_round_deg == 90,:),'r')
            plot(dataAv.atime(1,:),dataAv.EMG_TA_L_norm(ind & dataAv.pertdir_calc_round_deg == 270,:),'b')
            plot([0 0], [0 1],'k--'); plot([0.1 0.2],[1.1 1.1],'k-'); plot([0.2 0.3],[1 1],'k-');
            xlim([-0.1 1])
            title('TA_L'); xlabel('time (s)')
            plotij(2,2,2,2); hold on
            plot(dataAv.atime(1,:),dataAv.EMG_TA_R_norm(ind & dataAv.pertdir_calc_round_deg == 90,:),'r')
            plot(dataAv.atime(1,:),dataAv.EMG_TA_R_norm(ind & dataAv.pertdir_calc_round_deg == 270,:),'b')
            plot([0 0], [0 1],'k--'); plot([0.1 0.2],[1.1 1.1],'k-'); plot([0.2 0.3],[1 1],'k-');
            xlim([-0.1 1])
            title('TA_R'); xlabel('time (s)')
            sgtitle(participant + " mag" + num2str(mag))
            
            if savefigopt
                saveas(gcf,figdir + participant + '_Specificity_mag' + num2str(mag) + '.fig','fig')
                saveas(gcf,figdir + participant + '_Specificity_mag' + num2str(mag) + '.jpg','jpg')
                print(gcf,'-depsc2',figdir + participant + '_Specificity_mag' + num2str(mag) + '.eps')
            end
        end
        close all
    end
end
%% concatinate data tables
%create data table
T = table(EMG_TA_R_specificity_early, EMG_TA_L_specificity_early, EMG_SOL_R_specificity_early, EMG_SOL_L_specificity_early,...
    EMG_TA_R_specificity_late, EMG_TA_L_specificity_late, EMG_SOL_R_specificity_late, EMG_SOL_L_specificity_late,...
    EMG_TA_R_specificity_300_500, EMG_TA_L_specificity_300_500, EMG_SOL_R_specificity_300_500, EMG_SOL_L_specificity_300_500);
% concatinate tables
dataAv = [dataAv T];
ExcelTable = [ExcelTable T]; clear T


%% Calculate Cortical component Area under the curve
% initialize output variables
ctx_comp_ag  = nan(size(dataAv.Recon_Agonist));
destabilizing_comp_antag = nan(size(dataAv.Recon_Antagonist));
ctx_comp_ag_AUC  = nan(size(dataAv.pertdir_calc_round_deg));
destabilizing_comp_antag_AUC = nan(size(dataAv.pertdir_calc_round_deg));

subctx_comp_ag  = nan(size(dataAv.Recon_Agonist));
braking_comp_antag = nan(size(dataAv.Recon_Antagonist));
subctx_comp_ag_AUC  = nan(size(dataAv.pertdir_calc_round_deg));
braking_comp_antag_AUC = nan(size(dataAv.pertdir_calc_round_deg));

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
    %% calculate subctx and ctx components for Agonist hSRM
    predictors_ag = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time);...
        a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % hSRM predictors
    Gains_ag = dataAv.Gains_Ag_TotalDual_CoM(i,:); %hSRM reconstruction gains
    [Recon_ag, tmp_subctx_comp_ag, tmp_ctx_comp_ag] = assembleTwoChannels(predictors_ag(1:3,:),Gains_ag(1:3),Gains_ag(4),...
        predictors_ag(4:6,:),Gains_ag(5:7),Gains_ag(end),atime(ind_time));
    ctx_comp_ag(i,:) = tmp_ctx_comp_ag;
    subctx_comp_ag(i,:) = tmp_subctx_comp_ag;
    
    ctx_comp_ag_AUC(i,:) = trapz(atime(ind_time), tmp_ctx_comp_ag);
    subctx_comp_ag_AUC(i,:) = trapz(atime(ind_time), tmp_subctx_comp_ag);
    
    %% calculate subctx and ctx components for Antagonist hSRM
    predictors_antag = [a_antag(ind_time); v_antag(ind_time); d_antag(ind_time);....
        -a_antag(ind_time); -v_antag(ind_time); -d_antag(ind_time)]; % Antagonist SRM predictors
    Gains_antag = dataAv.Gains_Antag(i,:); %Antagonist SRM reconstruction gains
    [Recon_antag, tmp_braking_comp_antag, tmp_destabilizing_comp_antag] = assembleTwoChannels(predictors_antag(1:3,:),Gains_antag(1:3),Gains_antag(4),...
        predictors_antag(4:6,:),Gains_antag(5:7),Gains_antag(end),atime(ind_time));
    destabilizing_comp_antag(i,:) = tmp_destabilizing_comp_antag;
    braking_comp_antag(i,:) = tmp_braking_comp_antag;
    
    destabilizing_comp_antag_AUC(i,:) = trapz(atime(ind_time),tmp_destabilizing_comp_antag);
    braking_comp_antag_AUC(i,:) = trapz(atime(ind_time),tmp_braking_comp_antag);
    
    %% plot components for confirmation
    if plotopt
        figure; set(gcf,'Position',[387.4000 427.4000 1432 489.6000])
        plotij(2,2,1,1); hold on
        plot(atime(ind_time), Recon_ag,'k','LineWidth',3)
        plot(atime(ind_time), tmp_subctx_comp_ag,'r','LineWidth',1)
        plot(atime(ind_time), tmp_ctx_comp_ag,'b','LineWidth',1)
        title('hSRM Components'); xlabel('time (s)')
        legend('Recon','subctx','ctx')
        
        plotij(2,2,2,1); hold on
        plot(atime(ind_time), Recon_antag,'k','LineWidth',3)
        plot(atime(ind_time), tmp_braking_comp_antag,'g','LineWidth',1)
        plot(atime(ind_time), tmp_destabilizing_comp_antag,'r','LineWidth',1)
        title('Antag SRM Components'); xlabel('time (s)')
        legend('Recon','braking','destabilizing')
        
        plotij(2,2,1,2)
        bar([subctx_comp_ag_AUC(i,:) ctx_comp_ag_AUC(i,:)])
        xticklabels({'subctx AUC', 'ctx AUC'})
        xtickangle(45); ylim([0 0.5])
        
        plotij(2,2,2,2)
        bar([destabilizing_comp_antag_AUC(i,:) ctx_comp_ag_AUC(i,:)])
        xticklabels({'destabilizing AUC', 'braking AUC'})
        xtickangle(45);  ylim([0 0.5])
        
        sgtitle(dataAv.patient(i) + " mag" + num2str(dataAv.condition(i)) + " dir" + num2str(dataAv.pertdir_calc_round_deg(i)))
        
        if savefigopt
            saveas(gcf,figdir + dataAv.patient(i) + "_mag" + num2str(dataAv.condition(i)) +...
                "_dir" + num2str(dataAv.pertdir_calc_round_deg(i)) + '_SRMcomps_AUC.fig','fig')
            saveas(gcf,figdir + dataAv.patient(i) + "_mag" + num2str(dataAv.condition(i)) +...
                "_dir" + num2str(dataAv.pertdir_calc_round_deg(i)) + '_SRMcomps_AUC.jpg','jpg')
            print(gcf,'-depsc2',figdir + dataAv.patient(i) + "_mag" + num2str(dataAv.condition(i)) +...
                "_dir" + num2str(dataAv.pertdir_calc_round_deg(i)) + '_SRMcomps_AUC.eps')
        end
        close all
    end
    
    
end
%% concatinate data tables
%create data table
T = table(ctx_comp_ag, subctx_comp_ag, ctx_comp_ag_AUC, subctx_comp_ag_AUC,...
    destabilizing_comp_antag, braking_comp_antag, destabilizing_comp_antag_AUC, braking_comp_antag_AUC);
T_excel = table(ctx_comp_ag_AUC, subctx_comp_ag_AUC,...
    destabilizing_comp_antag_AUC, braking_comp_antag_AUC);
% concatinate tables
dataAv = [dataAv T];
ExcelTable = [ExcelTable T_excel]; clear T T_excel
%% save output
save([savedir filename '_wAnalysis' AnalysisType '.mat'], 'dataAv','ExcelTable')
writetable(ExcelTable,[savedir filename '_StatsTable_wAnalysis' AnalysisType  '.xlsx'])

%% functions
% create time index
function ind = create_ind(start_time, end_time, data)
ind = data > start_time & data <= end_time;
end
% calculate specificty
function specificity = calc_specificity(EMG_Forward, EMG_Backward)
% specificity = abs(EMG_Forward - EMG_Backward)/max([EMG_Forward, EMG_Backward]);
specificity = (EMG_Forward - EMG_Backward)/max([EMG_Forward, EMG_Backward]);

end
