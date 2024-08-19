%% Script to calculate AIC for different SRM models and concatinate it at the end of the datatable
clear; close all;

fdir = "X:\ting\shared_ting\Scott\HOA_PD SRM\"; % File directory
dataName = "HOA_PD_SRM_Outputs__24-Apr-2024_wAnalysis.mat"; % only acceleration Feedback

load(fdir + dataName)
max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % time window that was fit by the SRM

%% Calculate single AIC value for each model.
% get single vectors for each variable needed. i.e. concatinate each column in to a row vector

% Initialize the row vectors for time series data
Ag = []; Antag = []; mSRM_Recon = []; hSRM_CoM_Recon = []; AntagSRM_Recon = [];
Ag_270 = []; Antag_270 = []; mSRM_Recon_270 = []; hSRM_CoM_Recon_270 = [];
Ag_90 = []; Antag_90 = []; mSRM_Recon_90 = []; hSRM_CoM_Recon__90 = [];

% Initialize the row vectors for model parameters
mSRM_Gains = []; hSRM_CoM_Gains = []; AntagSRM_Gains = [];
mSRM_Gains_270 = []; hSRM_CoM_Gains_270 = [];
mSRM_Gains_90 = []; hSRM_CoM_Gains_90 = [];

% Iterate over each row in the table
for i = 1:size(dataAv, 1)
    % Extract the time series data to form a single row vector
    
    % specify agonist/antagonist
    if dataAv.pertdir_calc_round_deg(i) == 90 %forward pert
        agonist = dataAv.EMG_TA_L_norm(i,:); tag_ag='TA';
        antagonist = dataAv.EMG_MGAS_L_norm(i,:); tag_antag='MG';
    elseif dataAv.pertdir_calc_round_deg(i) == 270 %backward pert
        antagonist = dataAv.EMG_TA_L_norm(i,:); tag_antag='TA';
        agonist = dataAv.EMG_MGAS_L_norm(i,:); tag_ag='MG';
    else
        error('Unspecified Direction')
    end
    
    % all data
    Ag =                [Ag                 agonist(ind_time)];
    Antag =             [Antag              antagonist(ind_time)];
    mSRM_Recon =        [mSRM_Recon         dataAv.Recon_Agonist(i,:)]; 
    hSRM_CoM_Recon =    [hSRM_CoM_Recon     dataAv.Recon_Agonist_TotalDual_CoM(i,:)];
    AntagSRM_Recon =    [AntagSRM_Recon     dataAv.Recon_Antagonist(i,:)];
    mSRM_Gains =        [mSRM_Gains         dataAv.Gains_Ag(i,:)]; 
    hSRM_CoM_Gains =    [hSRM_CoM_Gains     dataAv.Gains_Ag_TotalDual_CoM(i,:)];
    AntagSRM_Gains =    [AntagSRM_Gains     dataAv.Gains_Antag(i,:)];
    
    %forward pert only - NEED TO FILL IN
    
    % backward pert only - NEED TO FILL IN
    
end
% remove NaN values that occur when certain participant/magntidue
% conditions have no trials
Ag = Ag(~isnan(Ag));
Antag = Antag(~isnan(Antag));

mSRM_Recon = mSRM_Recon(~isnan(mSRM_Recon));
hSRM_CoM_Recon = hSRM_CoM_Recon(~isnan(hSRM_CoM_Recon));
AntagSRM_Recon = AntagSRM_Recon(~isnan(AntagSRM_Recon));

mSRM_Gains = mSRM_Gains(~isnan(mSRM_Gains));
hSRM_CoM_Gains = hSRM_CoM_Gains(~isnan(hSRM_CoM_Gains));
AntagSRM_Gains = AntagSRM_Gains(~isnan(AntagSRM_Gains));


% Calcualte AIC using the following formula: 
% AIC = num_datapoints*log(residuals_ssr/num_datapoints) + 2*num_params
% where: num_datapoints = # of data points reconstructed by the SRMS
% residuals_ssr = sum squared error of the model residuals (data - fit)
% num_params = # of SRM parameters

Residual_mSRM = Ag - mSRM_Recon;
Residual_mSRM_ssr = sum(Residual_mSRM.^2);
num_datapoints_mSRM = length(Ag);
num_params_mSRM = length(mSRM_Gains);
AIC_mSRM = num_datapoints_mSRM*log(Residual_mSRM_ssr/num_datapoints_mSRM) + 2*num_params_mSRM;

Residual_hSRM_CoM = Ag - hSRM_CoM_Recon; 
Residual_hSRM_CoM_ssr = sum(Residual_hSRM_CoM.^2);
num_datapoints_hSRM_CoM = length(Ag);
num_params_hSRM_CoM = length(hSRM_CoM_Gains);
AIC_hSRM_CoM = num_datapoints_hSRM_CoM*log(Residual_hSRM_CoM_ssr/num_datapoints_hSRM_CoM) + 2*num_params_hSRM_CoM;

Residual_AntagSRM = Antag - AntagSRM_Recon; 
Residual_AntagSRM_ssr = sum(Residual_AntagSRM.^2);
num_datapoints_AntagSRM = length(Antag);
num_params_AntagSRM = length(AntagSRM_Gains);
AIC_AntagSRM = num_datapoints_AntagSRM*log(Residual_AntagSRM_ssr/num_datapoints_AntagSRM) + 2*num_params_AntagSRM;

