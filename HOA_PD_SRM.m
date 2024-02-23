%% Script to run the SRM on HOA/PD data

%% load data & add MATLAB utility functions
clear; close all; tic;
% change top which computer you are running this on
% addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
% addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM-Practice\SRMUtilities')
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')

load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_interp_norm_06-Dec-2023.mat') %output measures Table (EEG, EMG, etc.)

% dataAv.Cz = double(dataAv.Cz); %convert Cz(t) to class double for SRM recon
savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Scott\HOA_PD SRM\';

%% User inputs
removeBackLev = 1;
% Saving options (if true then will save output)
saveopt = true; %Output
% SRM reconstruction options
cSRMs_opt = true;
% Grouping Variables
direcs = unique(dataAv.pertdir_calc_round_deg); % directions to be analyzed (90 and 270)
% direcs = 270;
mags = unique(dataAv.condition);
% mags = mags(3);
% groups = unique(dataAv.group); %Group marker ("HOA" or "PD" -- string)
participants = unique(dataAv.patient); %Unique subject code (i.e. "HOA02" -- string)
% participants = ["HOA02"; "HOA04"; "HOA08"; "HOA13"; "HOA19";...
%     "PD03"; "PD11"; "PD12"; "PD13"; "PD15"; "PD17"; "PD20"]; % fit specific participants only
% participants = ["HOA09"; "PD02";];
dataAv = dataAv(ismember(dataAv.patient, participants),:); % eliminate rows of dataAv if they are not part of "participants"
analysisType = ''; % to modify save name with unique identifier

%% Add SRM Outputs to the data table
%Find common time span for all variables (MoCap, EEG, EMG)
% EEG times (time_eeg and time_ersp are in ms, atime is in s)
max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM - To do: Add to ouput table

TableHeight = size(dataAv,1);
ReconLength = length(dataAv.atime(1,ind_time)); %length of SRM Recon
% Recon Time 
Recon_time = nan([TableHeight,ReconLength]);
% Feedback Gains
Gains_Ag = nan([TableHeight,4]);
Gains_Antag = nan([TableHeight,8]);
Gains_Beta = nan([TableHeight,4]);
Gains_Cz = nan([TableHeight,4]);
% SRM Reconstructions
Recon_Beta = nan([TableHeight,ReconLength]);
Recon_Agonist = nan([TableHeight,ReconLength]);
Recon_Antagonist = nan([TableHeight,ReconLength]);
Recon_Cz = nan([TableHeight,ReconLength]);

% Reconstruction fits
fit_beta = nan([TableHeight,2]);
fit_agonist = nan([TableHeight,2]);
fit_antagonist = nan([TableHeight,2]);
fit_Cz = nan([TableHeight,2]);

% Residual SRM Outputs (w/ beta)
Residual = nan([TableHeight,ReconLength]);
Gains_Residual_beta = nan([TableHeight,2]);
Recon_Residual_beta = nan([TableHeight,ReconLength]);
fit_residual_beta = nan([TableHeight,2]);

% Dual SRM Outputs (w/ beta as predictor)
Gains_Ag_TotalDual_beta = nan([TableHeight,6]);
Recon_Agonist_TotalDual_beta = nan([TableHeight,ReconLength]);
fit_agonist_TotalDual_beta = nan([TableHeight,2]);

% Residual SRM Outputs (w/ Cz)
Gains_Residual_Cz = nan([TableHeight,2]);
Recon_Residual_Cz = nan([TableHeight,ReconLength]);
fit_residual_Cz = nan([TableHeight,2]);

% Dual SRM Outputs (w/ Cz as predictor)
Gains_Ag_TotalDual_Cz = nan([TableHeight,6]);
Recon_Agonist_TotalDual_Cz = nan([TableHeight,ReconLength]);
fit_agonist_TotalDual_Cz = nan([TableHeight,2]);

% Residual SRM Outputs (w/ CoM)
Gains_Residual_CoM = nan([TableHeight,4]);
Recon_Residual_CoM = nan([TableHeight,ReconLength]);
fit_residual_CoM = nan([TableHeight,2]);

% Dual SRM Outputs (w/ CoM as predictor)
Gains_Ag_TotalDual_CoM = nan([TableHeight,8]);
Recon_Agonist_TotalDual_CoM = nan([TableHeight,ReconLength]);
fit_agonist_TotalDual_CoM = nan([TableHeight,2]);

temp_Table = table(Residual, Gains_Ag, Gains_Antag, Gains_Beta, Gains_Cz, Recon_Beta, Recon_Cz, Recon_Agonist,...
    Recon_Antagonist, fit_beta, fit_Cz, fit_agonist, fit_antagonist, Gains_Ag_TotalDual_beta,...
    Recon_Agonist_TotalDual_beta, fit_agonist_TotalDual_beta,...
    Gains_Residual_beta, Recon_Residual_beta, fit_residual_beta, Gains_Ag_TotalDual_Cz,...
    Recon_Agonist_TotalDual_Cz, fit_agonist_TotalDual_Cz,...
    Gains_Residual_Cz, Recon_Residual_Cz, fit_residual_Cz,...
    Gains_Ag_TotalDual_CoM,...
    Recon_Agonist_TotalDual_CoM, fit_agonist_TotalDual_CoM,...
    Gains_Residual_CoM, Recon_Residual_CoM, fit_residual_CoM,Recon_time,...
    'VariableNames',{'Residual','Gains_Ag', 'Gains_Antag', 'Gains_Beta', 'Gains_Cz', 'Recon_Beta', 'Recon_Cz', 'Recon_Agonist',...
    'Recon_Antagonist', 'fit_beta', 'fit_Cz', 'fit_agonist', 'fit_antagonist', 'Gains_Ag_TotalDual_beta',...
    'Recon_Agonist_TotalDual_beta','fit_agonist_TotalDual_beta',...
    'Gains_Residual_beta', 'Recon_Residual_beta', 'fit_residual_beta', 'Gains_Ag_TotalDual_Cz',...
    'Recon_Agonist_TotalDual_Cz', 'fit_agonist_TotalDual_Cz',...
    'Gains_Residual_Cz', 'Recon_Residual_Cz', 'fit_residual_Cz',...
    'Gains_Ag_TotalDual_CoM',...
    'Recon_Agonist_TotalDual_CoM', 'fit_agonist_TotalDual_CoM',...
    'Gains_Residual_CoM', 'Recon_Residual_CoM', 'fit_residual_CoM','Recon_time'});

dataAv = [dataAv temp_Table];
% clear dummy variables from above
clear Residual Gains_Ag  Gains_Antag  Gains_Beta  Gains_Cz  Recon_Beta  Recon_Cz  Recon_Agonist Recon_Antagonist  fit_beta  fit_Cz  fit_agonist  fit_antagonist  Gains_Ag_Dual_beta  Gains_Ag_TotalDual_beta Recon_Agonist_Dual_beta  Recon_Agonist_TotalDual_beta  fit_agonist_Dual_beta  fit_agonist_TotalDual_beta Gains_Residual_beta  Recon_Residual_beta  fit_residual_beta  Gains_Ag_TotalDual_Cz Recon_Agonist_TotalDual_Cz  fit_agonist_TotalDual_Cz Gains_Residual_Cz  Recon_Residual_Cz  fit_residual_Cz Gains_Ag_TotalDual_CoM Recon_Agonist_TotalDual_CoM  fit_agonist_TotalDual_CoM Gains_Residual_CoM  Recon_Residual_CoM  fit_residual_CoM
%% Run SRM
loopbreak = false;
for Participant = participants' % iterate across each participant
    zz = 0; % participant counter
    ii = 0; % dataAv Row Counter
    for direction = direcs' %iterate across each direction
        if ~loopbreak
            zz = zz + 1; % participant counter
            xx = 0; yy = 0; % direction & magnitude counter
        elseif loopbreak
            xx = 1; yy = 1;
        end
        for mag = mags' %iterate across each magnitude
            if ~loopbreak
                xx = xx + 1;
            end
            %             if xx == 2 %not sure what this was for?
            %                 yy = 0;
            %             end
            
            %% pull variables from data table for SRM fit
            %condition index - to pull correct variables for SRM
            %analysis (i.e. correct row in dataAv)
            ind_cond = find(dataAv.patient == Participant & ...
                dataAv.pertdir_calc_round_deg == direction & dataAv.condition == mag);
            
            % Break if there are no participants that fit the unique group/participant
            if isempty(ind_cond)
                loopbreak = true;
                break
            else
                ii = ii + 1;
                subjID = dataAv.patient(ind_cond);
                loopbreak = false;
            end
            
            %specify which muscle is acting as an agonist/antagonist
            if direction == 90 %forward pert
                agonist = dataAv.EMG_TA_L_norm(ind_cond,:); tag_ag='TA'; ag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                antagonist = dataAv.EMG_MGAS_L_norm(ind_cond,:); tag_antag='MG'; antag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
            elseif direction == 270 %backward pert
                antagonist = dataAv.EMG_TA_L_norm(ind_cond,:); tag_antag='TA'; antag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                agonist = dataAv.EMG_MGAS_L_norm(ind_cond,:); tag_ag='MG'; ag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
            else
                error('Unspecified Direction')
            end
            if cSRMs_opt
                Cz = dataAv.Cz_norm(ind_cond,:);
                beta = dataAv.beta_ersp_norm(ind_cond,:);
            end
            
            %% specify CoM kinematics
            atime = dataAv.atime(ind_cond,:); % Modify CoM acc with stiction model from Welch and Ting 2009
            a = dataAv.COMAccel_Y(ind_cond,:);
            a = stictionTemplate('a',a,'t',atime);
            v = dataAv.COMVelo_Y(ind_cond,:);
            d = dataAv.COMPosminusLVDT_Y(ind_cond,:);
            
            % remove basline from CoM kinematics - not needed for a due to stiction model
            d = d-mean(d(dataAv.atime(1,:)<-0.1));
            v = v-mean(v(dataAv.atime(1,:)<-0.1));
            
            % flip the CoM kinematic signal depending on pert direction
            if direction == 90 %forward pert
                a_ag = -a; v_ag = -v; d_ag = -d;
                a_antag = a; v_antag = v; d_antag = d;
            else %backward pert
                a_ag = a; v_ag = v; d_ag = d;
                a_antag = -a; v_antag = -v; d_antag = -d;
            end
            
            
            
            %% Prime variables for SRM - remove back lev and make gain variables
            x_ag = nan; % agonist gain
            x1 = nan; % part of antagonist gain
            if removeBackLev % remove background level from average EMG and beta traces
                backLev_agonist = mean(agonist(atime < -0.1),'omitnan');
                agonist = agonist - backLev_agonist;
                
                backLev_antagonist = mean(antagonist(atime < -0.1),'omitnan');
                antagonist = antagonist - backLev_antagonist;
                if cSRMs_opt
                    backLev_beta = mean(beta(atime < -0.1),'omitnan');
                    beta = beta - backLev_beta;
                    
                    backLev_Cz = mean(Cz(atime < -0.1),'omitnan');
                    Cz = Cz - backLev_Cz;
                end
            end
            
            %% Run mSRM on Agonist
            % identify braking response in agonist
            predictorsmSRM = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)];
            
            [x_ag([1:4]), eRecon_ag, fit_ag] = fitTraditionalSRM(agonist(ind_time),atime(ind_time),predictorsmSRM,subjID,mag,direction);
            if removeBackLev
                eRecon_ag = eRecon_ag + backLev_agonist;
                agonist = agonist + backLev_agonist;
            end

            %% Run SRM on Antagonist
            % identify braking response in antagonist
            predictorsBraking = [a_antag(ind_time); v_antag(ind_time); d_antag(ind_time)];
            
            [x1(1:4), eRecon_antag_Braking, fit] = fitBrakingSRM(...
                antagonist(ind_time),atime(ind_time),predictors_antag,subjID,mag,direction);
            
            % identify destabilizing response in antagonist
            predictorsDestabilizing = [-a_antag(ind_time); -v_antag(ind_time); -d_antag(ind_time)];
            
            [xPrime([5:8]), eRecon_antag_Destabilizing, fitPrime] = fitDestabilizingSRM(...
                antagonist(ind_time),atime(ind_time),predictorsDestabilizing,subjID,mag,direction);
            
            % combine them into the initial guess for the final optimization
            X0Total = [x1([1:4]) xPrime([5:8])];
            predictorsTotal = [predictorsBraking; predictorsDestabilizing];
            
            [xTotal_an, eTotalRecon_antag, fitTotal_an] = fitTotalSRM(...
                antagonist(ind_time),atime(ind_time),predictorsTotal,X0Total,subjID,mag,direction);
            if removeBackLev
                eTotalRecon_antag = eTotalRecon_antag + backLev_antagonist;
                antagonist = antagonist + backLev_antagonist;
            end
            
            %% Calculate Residuals
            residual = agonist(ind_time) - eRecon_ag; % Difference
            %% Fit Residuals of eRecon_ag w/ Beta power
            if cSRMs_opt
                type = 'beta';
                predictorsResiduals_beta = beta(ind_time);
                LB = [0 x_ag(4)+0.010]; %[k_beta lambda_beta];
                UB = [15.0 0.300];%[k_beta lambda_beta];
                [x_residual_beta([1:2]), eRecon_residual_beta, fit_residual_beta] = fitResidualSRM_eeg(residual, atime(ind_time), predictorsResiduals_beta, subjID, mag,LB, UB);
                
                %% Fit dual SRM (fit EMG w/ CoM & beta)
                X0Dual = [x_ag(1:4) x_residual_beta(1:2)];
                predictorsDual_beta = [predictorsmSRM; predictorsResiduals_beta];
                [xTotal_ag_dual_beta, eTotalRecon_ag_dual_beta, fitTotal_ag_dual_beta] = fitTotalDualSRM_eeg(agonist(ind_time), atime(ind_time), predictorsDual_beta, X0Dual, subjID, mag, type);
                clear type
                if removeBackLev
                    eTotalRecon_ag_dual_beta = eTotalRecon_ag_dual_beta + backLev_agonist;
                end
                %% Fit Residuals of eRecon_ag w/ Cz(t)
                type = 'Cz';
                predictorsResiduals_Cz = -Cz(ind_time);
                LB = [0 x_ag(4)+0.010]; %[k_Cz lambda_Cz];
                if strcmp(subjID,"HOA02")
                    UB = [15.0 0.200];%[k_Cz lambda_Cz];
                else
                    UB = [15.0 0.300]; %[k_Cz lambda_Cz];
                end
                [x_residual_Cz([1:2]), eRecon_residual_Cz, fit_residual_Cz] = fitResidualSRM_eeg(residual, atime(ind_time), predictorsResiduals_Cz, subjID, mag,LB, UB);
                
                %% Fit dual SRM (fit EMG w/ CoM & Cz)
                
                X0Dual = [x_ag(1:4) x_residual_Cz(1:2)];
                predictorsDual_Cz = [predictorsmSRM; predictorsResiduals_Cz];
                [xTotal_ag_dual_Cz, eTotalRecon_ag_dual_Cz, fitTotal_ag_dual_Cz] = fitTotalDualSRM_eeg(agonist(ind_time), atime(ind_time), predictorsDual_Cz, X0Dual, subjID, mag, type);
                clear type
                if removeBackLev
                    eTotalRecon_ag_dual_Cz = eTotalRecon_ag_dual_Cz + backLev_agonist;
                end
            end
            %% Fit Residuals of eRecon_ag w/ CoM Kinematics
            predictorsResiduals_CoM = predictorsmSRM;
            UB = [15.0 0.04 0.04 0.300]; %[ka, kv, kd, lambda] - taken from fitTraditionalSRM (for gains) & fitResidual_eeg (for delay)
            LB = [ 0.0 0.00 0.00 x_ag(4)+0.010]; %set LB of delay based of mSRM fit
            %             if strcmp(Participant,"HOA12") & mag == 10 % May be an artifact from HYA_SRM
            %                 LB(end) = 0.180;
            %             end
            [x_residual_CoM([1:4]), eRecon_residual_CoM, fit_residual_CoM] = fitResidualSRM_CoM(residual, atime(ind_time), predictorsResiduals_CoM, subjID, mag,LB, UB);
            
            %% Fit dual SRM (fit EMG w/ double CoM Feedback)
            X0Dual = [x_ag(1:4) x_residual_CoM(1:4)];
            predictorsDual_CoM = [predictorsmSRM; predictorsmSRM];
            [xTotal_ag_dual_CoM, eTotalRecon_ag_dual_CoM, fitTotal_ag_dual_CoM] = fitTotalDualSRM_CoM(agonist(ind_time), atime(ind_time), predictorsDual_CoM, X0Dual, subjID, mag);
            if removeBackLev
                eTotalRecon_ag_dual_CoM = eTotalRecon_ag_dual_CoM + backLev_agonist;
            end
            %% Fit cSRM to the EEG beta power trace
            if cSRMs_opt
                % fit in EEG beta power with TraditionalSRM
                predictorsTrad_eeg = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; %CoM kinematics
                
                [x_eeg_beta(1:4), eegRecon_beta, fit_eeg_beta] = fitTraditionalSRM_eeg(beta(ind_time),atime(ind_time),predictorsTrad_eeg);
                
                if removeBackLev
                    %                 eegTotalRecon = eegTotalRecon + backLev_beta;
                    eegRecon_beta = eegRecon_beta + backLev_beta;
                    beta = beta + backLev_beta;
                end
                
                %% Fit cSRM to the EEG Cz trace
                % fit in EEG beta power with TraditionalSRM
                predictorsTrad_eeg = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; %CoM kinematics
                
                [x_eeg_Cz(1:4), eegRecon_Cz, fit_eeg_Cz] = fitTraditionalSRM_eeg(-Cz(ind_time),atime(ind_time),predictorsTrad_eeg); % Negate Cz to prevent threshold issue
                eegRecon_Cz = -eegRecon_Cz; %Flip Cz back to original sign
                
                if removeBackLev
                    %                 eegTotalRecon = eegTotalRecon + backLev_beta;
                    eegRecon_Cz = eegRecon_Cz + backLev_Cz;
                    Cz = Cz + backLev_Cz;
                end
            end
            
            %% Put SRM Outputs into dataAv
            dataAv.Recon_time(ind_cond,:) = atime(ind_time);
            dataAv.Gains_Ag(ind_cond,:) = x_ag;
            dataAv.Gains_Antag(ind_cond,:) = xTotal_an;
            dataAv.Gains_Beta(ind_cond,:) = x_eeg_beta;
            dataAv.Recon_Beta(ind_cond,:) = eegRecon_beta;
            dataAv.Recon_Agonist(ind_cond,:) = eRecon_ag;
            dataAv.Recon_Antagonist(ind_cond,:) = eTotalRecon_antag;
            dataAv.fit_beta(ind_cond,:) = fit_eeg_beta;
            dataAv.fit_agonist(ind_cond,:) = fit_ag;
            dataAv.fit_antagonist(ind_cond,:) = fitTotal_an;
            
            dataAv.Gains_Cz(ind_cond,:) = x_eeg_Cz;
            dataAv.Recon_Cz(ind_cond,:) = eegRecon_Cz;
            dataAv.fit_Cz(ind_cond,:) = fit_eeg_Cz;
            
            %DualSRM outputs (beta predictor)
            dataAv.Gains_Ag_TotalDual_beta(ind_cond,:) = xTotal_ag_dual_beta;
            dataAv.Recon_Agonist_TotalDual_beta(ind_cond,:) = eTotalRecon_ag_dual_beta;
            dataAv.fit_agonist_TotalDual_beta(ind_cond,:) = fitTotal_ag_dual_beta;
            
            %ResidualSRM outputs (Beta)
            dataAv.Residual(ind_cond,:) = residual;
            dataAv.Gains_Residual_beta(ind_cond,:) = x_residual_beta;
            dataAv.Recon_Residual_beta(ind_cond,:) = eRecon_residual_beta;
            dataAv.fit_residual_beta(ind_cond,:) = fit_residual_beta;
            
            %DualSRM outputs (Cz predictor)
            dataAv.Gains_Ag_TotalDual_Cz(ind_cond,:) = xTotal_ag_dual_Cz;
            dataAv.Recon_Agonist_TotalDual_Cz(ind_cond,:) = eTotalRecon_ag_dual_Cz;
            dataAv.fit_agonist_TotalDual_Cz(ind_cond,:) = fitTotal_ag_dual_Cz;
            
            %ResidualSRM outputs (Cz)
            dataAv.Gains_Residual_Cz(ind_cond,:) = x_residual_Cz;
            dataAv.Recon_Residual_Cz(ind_cond,:) = eRecon_residual_Cz;
            dataAv.fit_residual_Cz(ind_cond,:) = fit_residual_Cz;
            
            %DualSRM outputs (CoM)
            dataAv.Gains_Ag_TotalDual_CoM(ind_cond,:) = xTotal_ag_dual_CoM;
            dataAv.Recon_Agonist_TotalDual_CoM(ind_cond,:) = eTotalRecon_ag_dual_CoM;
            dataAv.fit_agonist_TotalDual_CoM(ind_cond,:) = fitTotal_ag_dual_CoM;
            
            %ResidualSRM outputs (CoM)
            dataAv.Gains_Residual_CoM(ind_cond,:) = x_residual_CoM;
            dataAv.Recon_Residual_CoM(ind_cond,:) = eRecon_residual_CoM;
            dataAv.fit_residual_CoM(ind_cond,:) = fit_residual_CoM;
            
        end % direction loop
        if ~loopbreak
            close all
        end
    end % Participant loop
end
%% Save output
if saveopt
    ExcelTable = dataAv;
    
    %Remove timeseries data to save for statistics
    ind_delete = [];
    for i = 1:width(ExcelTable)
        tempVar = table2array(ExcelTable(1,i));
        if length(tempVar) > 10
            ind_delete = [ind_delete i]; % index for columns that are time series data
        end
    end
    
    ExcelTable(:,ind_delete) = [];
    writetable(ExcelTable,[savedir 'HOA_PD_SRM_Output_StatsTable_' analysisType '_' date '.xlsx'])
    save([savedir 'HOA_PD_SRM_Outputs_' analysisType '_' date '.mat'], 'dataAv','ExcelTable')
end
disp('SRM Pipeline Complete!')
toc