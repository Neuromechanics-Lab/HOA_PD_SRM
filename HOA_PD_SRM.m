%% Script to run the SRM on HOA/PD data

%% load data & add MATLAB utility functions
clear; close all; tic;
% change top which computer you are running this on
pcname = "cpu1"; % cpu1
% pcname = "PC"; %personal computer
if strcmp("cpu1",pcname)
    addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
    addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
    load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_interp_norm_18-Oct-2023.mat') %output measures Table (EEG, EMG, etc.)
    savedir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\';
    figdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\savedfigs\';
elseif strcmp("pc",pcname)
    addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM-Practice\SRMUtilities')
    addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')
    load('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\SRM Analysis\HOA_PD_DataTables_05-Oct-2023.mat') %output measures Table (EEG, EMG, etc.)
    
    figdir = 'C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\SRM Analysis\HOA_PD_SRM_savedfigs\';
end
% dataAv.Cz = double(dataAv.Cz); %convert Cz(t) to class double for SRM recon

%% User inputs
removeBackLev = 1;
% Saving options (if = 1 then will save)
saveopt = true; %Output
savefigopt = 0; %Figures
plotopt = false; %option to plot figures at all

% SRM reconstruction options
cSRMs_opt = true;

% Grouping Variables
direcs = unique(dataAv.pertdir_calc_round_deg); % directions to be analyzed (90 and 270)
mags = unique(dataAv.pert_mag);
groups = unique(dataAv.group); %Group marker ("HOA" or "PD" -- string)
% subj_IDs = unique(dataAv.patient); %Unique subject code (i.e. "HOA02" -- string)
participants = unique(dataAv.patient); %Unique subject code (i.e. "HOA02" -- string)

%% Add SRM Outputs to the data table
%Find common time span for all variables (MoCap, EEG, EMG)
% EEG times (time_eeg and time_ersp are in ms, atime is in s)
max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM

TableHeight = size(dataAv,1);
ReconLength = length(dataAv.atime(1,ind_time)); %length of SRM Recon
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
    Gains_Residual_CoM, Recon_Residual_CoM, fit_residual_CoM,...
    'VariableNames',{'Residual','Gains_Ag', 'Gains_Antag', 'Gains_Beta', 'Gains_Cz', 'Recon_Beta', 'Recon_Cz', 'Recon_Agonist',...
    'Recon_Antagonist', 'fit_beta', 'fit_Cz', 'fit_agonist', 'fit_antagonist', 'Gains_Ag_TotalDual_beta',...
    'Recon_Agonist_TotalDual_beta','fit_agonist_TotalDual_beta',...
    'Gains_Residual_beta', 'Recon_Residual_beta', 'fit_residual_beta', 'Gains_Ag_TotalDual_Cz',...
    'Recon_Agonist_TotalDual_Cz', 'fit_agonist_TotalDual_Cz',...
    'Gains_Residual_Cz', 'Recon_Residual_Cz', 'fit_residual_Cz',...
    'Gains_Ag_TotalDual_CoM',...
    'Recon_Agonist_TotalDual_CoM', 'fit_agonist_TotalDual_CoM',...
    'Gains_Residual_CoM', 'Recon_Residual_CoM', 'fit_residual_CoM'});

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
                dataAv.pertdir_calc_round_deg == direction & dataAv.pert_mag == mag);
            
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
            
            %% Run SRM on Antagonist
            % identify braking response in antagonist
            predictorsmSRM = [a_antag(ind_time); v_antag(ind_time); d_antag(ind_time)];
            
            [x1(1:4), eRecon_antag_Braking, fit] = fitBrakingSRM(antagonist(ind_time),atime(ind_time),predictorsmSRM);
            
            % identify destabilizing response in antagonist
            predictorsDestabilizing = [-a_antag(ind_time); -v_antag(ind_time); -d_antag(ind_time)];
            
            [xPrime([5:8]), eRecon_antag_Destabilizing, fitPrime] = fitDestabilizingSRM(antagonist(ind_time),atime(ind_time),predictorsDestabilizing,subjID,mag);
            
            % combine them into the initial guess for the final optimization
            X0Total = [x1([1:4]) xPrime([5:8])];
            predictorsTotal = [predictorsmSRM; predictorsDestabilizing];
            
            [xTotal_an, eTotalRecon_antag, fitTotal_an] = fitTotalSRM(antagonist(ind_time),atime(ind_time),predictorsTotal,X0Total);
            if removeBackLev
                eTotalRecon_antag = eTotalRecon_antag + backLev_antagonist;
                antagonist = antagonist + backLev_antagonist;
            end
            
            %% Run mSRM on Agonist
            % identify braking response in agonist
            predictorsmSRM = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)];
            
            [x_ag([1:4]), eRecon_ag, fit_ag] = fitTraditionalSRM(agonist(ind_time),atime(ind_time),predictorsmSRM,subjID,mag);
            if removeBackLev
                eRecon_ag = eRecon_ag + backLev_agonist;
                agonist = agonist + backLev_agonist;
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
    writetable(ExcelTable,[savedir 'HOA_PD_SRM_Output_StatsTable_' date '.xlsx'])
    save([savedir 'HOA_PD_SRM_Outputs_' date '.mat'], 'dataAv','ExcelTable')
end
disp('SRM Pipeline Complete!')
toc

%% Functions used for SRM recon

function plotExemplarSRMFits(data)
% function plotExemplarSRMFits(data)
%
% plot three example cases

exemplarPatients = ["bat206" "bat114" "pdf027"];
pertdir = 270;
side = "L";

% bat206:
% 22F
% MoCA = 26

% bat114:
% 64M
% MoCA = 26

% pdf027:
% 62F
% pd duration 4.9y
% mds-updrs-iii 55/132
% no freezing


flipTA = false;

XL = [0 1];
YL = [0 1];

atime = data.atime(1,:);
lookup = atime>=min(XL)&atime<max(XL);
fig = figure;
for pi = 1:length(exemplarPatients)
    ta = data(data.patient==exemplarPatients(pi)&data.pertdir==pertdir&data.side==side&data.mus=="TA",:);
    mg = data(data.patient==exemplarPatients(pi)&data.pertdir==pertdir&data.side==side&data.mus=="MGAS",:);
    
    if flipTA
        s = subplot(2,3,pi);
        xlim(XL)
        ylim(YL)
        
        plot(atime(lookup),mg.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'g','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'k','linewidth',1,'clipping','off');
        
        s = subplot(2,3,pi+3)
        xlim(XL)
        ylim(sort(-1*YL))
        
        plot(atime(lookup),-ta.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.eRecon(lookup),'g','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.ePrimeRecon(lookup),'r','linewidth',0.5,'clipping','off');
        plot(atime(lookup),-ta.eTotalRecon(lookup),'k','linewidth',1,'clipping','off');
    else
        s = subplot(2,3,pi);
        xlim(XL)
        ylim(YL)
        
        a = area(atime(lookup),mg.eRecon(lookup));
        a.FaceColor = [0 1 0];
        a.EdgeColor = 'none';
        
        plot(atime(lookup),mg.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),mg.eRecon(lookup),'k','linewidth',1,'clipping','off');
        
        VAF = rsqr_uncentered(mg.e(lookup)',mg.eRecon(lookup)');
        R2 = rsqr(mg.e(lookup)',mg.eRecon(lookup)');
        VAFstr = "VAF = "+sprintf('%0.2f',VAF);
        R2str = "R2 = "+sprintf('%0.2f',R2);
        txt = text(max(s.XLim),max(s.YLim),[VAFstr;R2str]);
        txt.HorizontalAlignment = 'right';
        txt.VerticalAlignment = 'top';
        
        s = subplot(2,3,pi+3)
        xlim(XL)
        ylim(YL)
        
        a = area(atime(lookup),ta.eRecon(lookup));
        a.FaceColor = [0 1 0];
        a.EdgeColor = 'none';
        a = area(atime(lookup),ta.ePrimeRecon(lookup));
        a.FaceColor = [1 0 0];
        a.EdgeColor = 'none';
        plot(atime(lookup),ta.e(lookup),'k','linewidth',0.5,'clipping','off');
        plot(atime(lookup),ta.eTotalRecon(lookup),'k','linewidth',1,'clipping','off');
        
        VAF = rsqr_uncentered(ta.e(lookup)',ta.eTotalRecon(lookup)');
        R2 = rsqr(ta.e(lookup)',ta.eTotalRecon(lookup)');
        VAFstr = "VAF = "+sprintf('%0.2f',VAF);
        R2str = "R2 = "+sprintf('%0.2f',R2);
        txt = text(max(s.XLim),max(s.YLim),[VAFstr;R2str]);
        txt.HorizontalAlignment = 'right';
        txt.VerticalAlignment = 'top';
        
    end
end

end

function SRMFits = calculateExemplarSRMFits(fitsData)

% use a common copy of the atime vector
atime = fitsData.atime(1,:);

removeBackLev = true;
fitDestabMG = true;

% loop. note that randperm here does not affect functionality and is just
% used for debugging purposes (in order to prevent having to go through all
% of the TA records prior to doing MG.)
for idx = randperm(size(fitsData,1))
    e = fitsData.e(idx,:);
    
    if removeBackLev
        backLev = nanmean(e(atime<0.05));
        e = e - backLev;
    end
    if fitsData.mus(idx)=="TA"&fitsData.dir(idx)=="B"
        
        % identify braking response in TA in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitBrakingSRM(e,atime,predictorsBraking);
        
        % identify destabilizing response in TA in backward perturbations
        predictorsDestabilizing = [fitsData.aPrime(idx,:); fitsData.vPrime(idx,:); fitsData.dPrime(idx,:)];
        [fitsData.xPrime(idx,[5:8]), fitsData.ePrimeRecon(idx,:) fitsData.fitPrime(idx,:)] = fitDestabilizingSRM(e,atime,predictorsDestabilizing);
        
        % combine them into the initial guess for the final optimization
        X0Total = [fitsData.x(idx,[1:4]) fitsData.xPrime(idx,[5:8])];
        predictorsTotal = [predictorsBraking; predictorsDestabilizing];
        
        [fitsData.xTotal(idx,:), fitsData.eTotalRecon(idx,:) fitsData.fitTotal(idx,:)] = fitTotalSRM(e,atime,predictorsTotal,X0Total);
        if removeBackLev
            fitsData.eTotalRecon(idx,:) = fitsData.eTotalRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="MGAS"&fitsData.dir(idx)=="B"
        % identify braking response in MGAS in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitTraditionalSRM(e,atime,predictorsBraking);
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    end
end

SRMFits = fitsData;

end

function SRMFits = calculateSRMFits(fitsData)

% use a common copy of the atime vector
atime = fitsData.atime(1,:);

removeBackLev = true;
fitDestabMG = true;

% loop. note that randperm here does not affect functionality and is just
% used for debugging purposes (in order to prevent having to go through all
% of the TA records prior to doing MG.)
for idx = randperm(size(fitsData,1))
    e = fitsData.e(idx,:);
    
    if removeBackLev
        backLev = nanmean(e(atime<0.05));
        e = e - backLev;
    end
    if fitsData.mus(idx)=="TA"&fitsData.dir(idx)=="B"
        
        % identify braking response in TA in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitBrakingSRM(e,atime,predictorsBraking);
        
        % identify destabilizing response in TA in backward perturbations
        predictorsDestabilizing = [fitsData.aPrime(idx,:); fitsData.vPrime(idx,:); fitsData.dPrime(idx,:)];
        [fitsData.xPrime(idx,[5:8]), fitsData.ePrimeRecon(idx,:) fitsData.fitPrime(idx,:)] = fitDestabilizingSRM(e,atime,predictorsDestabilizing);
        
        % combine them into the initial guess for the final optimization
        X0Total = [fitsData.x(idx,[1:4]) fitsData.xPrime(idx,[5:8])];
        predictorsTotal = [predictorsBraking; predictorsDestabilizing];
        
        [fitsData.xTotal(idx,:), fitsData.eTotalRecon(idx,:) fitsData.fitTotal(idx,:)] = fitTotalSRM(e,atime,predictorsTotal,X0Total);
        if removeBackLev
            fitsData.eTotalRecon(idx,:) = fitsData.eTotalRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="TA"&fitsData.dir(idx)=="F"
        % identify braking response in TA in forward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitTraditionalSRM(e,atime,predictorsBraking);
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="MGAS"&fitsData.dir(idx)=="B"
        % identify braking response in MGAS in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitTraditionalSRM(e,atime,predictorsBraking);
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="MGAS"&fitsData.dir(idx)=="F"
        % identify braking response in MGAS in forward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitBrakingSRM(e,atime,predictorsBraking);
        
        if fitDestabMG
            % identify destabilizing response in MG in forward perturbations
            predictorsDestabilizing = [fitsData.aPrime(idx,:); fitsData.vPrime(idx,:); fitsData.dPrime(idx,:)];
            [fitsData.xPrime(idx,[5:8]), fitsData.ePrimeRecon(idx,:) fitsData.fitPrime(idx,:)] = fitDestabilizingSRM(e,atime,predictorsDestabilizing);
            
            % combine them into the initial guess for the final optimization
            X0Total = [fitsData.x(idx,[1:4]) fitsData.xPrime(idx,[5:8])];
            predictorsTotal = [predictorsBraking; predictorsDestabilizing];
            
            [fitsData.xTotal(idx,:), fitsData.eTotalRecon(idx,:) fitsData.fitTotal(idx,:)] = fitTotalSRM(e,atime,predictorsTotal,X0Total);
            if removeBackLev
                fitsData.eTotalRecon(idx,:) = fitsData.eTotalRecon(idx,:) + backLev;
            end
        end
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    end
end

SRMFits = fitsData;

end

function out = names(in)
out = string(in.Properties.VariableNames');
end

function out = makeDelayFigure(predictorsBraking,atime)

aOrig = predictorsBraking(1,:);
aDelayed = channelDelay(aOrig,0.1,atime);

figure
plot(atime, aOrig)
hold on
plot(atime, aDelayed)
legend("original","delayed")

end

function out = loadOptimizationParameters()
J_SE = 1;
J_ME = 1;
J_GM = 1;
display = "iter";
TolX = 1e-9;
MaxFunEvals = 1e+5;
TolFun = 1e-7;
out = table(J_SE,J_ME,J_GM,display,TolX,MaxFunEvals,TolFun);
end

function out = assembleChannelComponents(signals,gains,delay,atime,THRESH)

% note that we cannot just matrix multiply because we have to delay each signal
out = [];
if THRESH
    for i = 1:length(gains)
        out(i,:) = channelDelay(threshold(signals(i,:)*gains(i)),delay,atime);
    end
else
    for i = 1:length(gains)
        out(i,:) = channelDelay(signals(i,:)*gains(i),delay,atime);
    end
end
end

function out = assembleChannel(signals,gains,delay,atime)
out = channelDelay(threshold(signals'*gains'),delay,atime);
end

function out = channelDelay(in,delay,atime)
out = interp1(atime,in,atime-delay,'linear',0);
end

function out = threshold(in)
out = max(in,0);
end

function [xBraking, eBraking, fitsBraking] = fitTraditionalSRM(e,atime,predictors,subjID,magnitude) %mSRM
% fit "braking response" at end of perturbation.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% 60-250 ms search range from welch 2008

%Hand fit certain conditions
if (strcmp(subjID,'step01') & magnitude == 1) | (strcmp(subjID,'step01') & magnitude == 3)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step02')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.115];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step04') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step05') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step06') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step07') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step08') & magnitude == 1) | (strcmp(subjID,'step08') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step10') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step11')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step12') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step15') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step17') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step18') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step19')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step20') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step21')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
else
    X0 = [10.0 0.01 0.01 0.150]; %[10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.250]; %[15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
end
%         error('Bounds were changed')
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain & strcmp(subjID,'step08') & magnitude == 1 %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.110&atime<0.140))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step11') & magnitude == 2 %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step17') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.220))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step19') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step21') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.120&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
else
    burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end

function PI = jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters)

% calculate reconstruction
eRecon = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);

% calculate performance index
fitParameters = modelIPI('X',X,'eRecon',eRecon,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

PI = fitParameters.PI;

end

function fitParameters = modelIPI(varargin)

p = inputParser;
p.addOptional('X',[]);
p.addOptional('e',[]);
p.addOptional('eRecon',[]);
p.addOptional('gainWeight',[]);
p.addOptional('optimizationParameters',[]);
p.parse(varargin{:});

X = p.Results.X;
e = p.Results.e;
e_recon = p.Results.eRecon;
optimizationParameters = p.Results.optimizationParameters;
gainWeight = p.Results.gainWeight;

J_SE = optimizationParameters.J_SE;
J_ME = optimizationParameters.J_ME;
J_GM = optimizationParameters.J_GM;

fitParameters.r2 = rsqr(e',e_recon');
fitParameters.r2u = rsqr_uncentered(e',e_recon');

% Compute the errors between recorded and simulated EMG signals. We are
% minimizing a function of these error values:
% error   = recorded  - simulated
e_error = e - e_recon;
e_error(isnan(e_error)) = [];

% ### J = squared error + "min-max error" = terminal cost
% ### J = L1 + L2:
% L1 = squared error. L1 composes the bulk of the terminal cost. It is a
% linear combination of the squares of the error terms.
fitParameters.L1 = J_SE*(e_error*e_error');

% L2 = max of the abs of the error terms. L2 penalizes large deviations.
% Little terminal cost is contributed by L2, but L2 appears to "smooth out"
% the J manifold and make the optimization converge more consistently.
fitParameters.L2 = J_ME*max(abs(e_error));

% L3 = magnitude of the gain values. this term is just designed to zero out
% noncontributing gains, and improve convergence.
fitParameters.L3 = J_GM*(X.*gainWeight)*(X.*gainWeight)';

% PI is the sum of these individual costs. The function fmincon attempts to
% minimize J.
fitParameters.PI = fitParameters.L1 + fitParameters.L2 + fitParameters.L3;

end

function [xBraking, eBraking, fitsBraking] = fitBrakingSRM(e,atime,predictors)
% fit "braking response" at end of perturbation.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% 60-250 ms search range was welch 2008
X0 = [10.0 0.01 0.01 0.150];
UB = [15.0 0.04 0.04 0.250];
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
LB = [ 0.0 0.00 0.00 0.060];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.650&atime<0.800))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.8 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;

fitsBraking(isnan(fitsBraking)) = 0;

end

function [xDestabilizing, eDestabilizing, fitsDestabilizing] = fitDestabilizingSRM(e,atime,predictors,subjID,magnitude)
% fit "Destabilizing response" at end of perturbation.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% note slightly different gain limits for destabilizing SRM TA gain
if strcmp(subjID,'') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.110];
    UB = [15.0 0.04 0.04 0.120];
    LB = [ 0.0 0.00 0.00 0.090];
else
    X0 = [10.0 0.01 0.01 0.140];
    UB = [15.0 0.04 0.04 0.210];
    LB = [ 0.0 0.00 0.00 0.090];
end
% X0 = [10.0 0.01 0.01 0.150];
% UB = [15.0 0.04 0.04 0.250];
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
% LB = [ 0.0 0.00 0.00 0.060];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.275))/max(predictors(1,:));
    % burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xDestabilizing = X;

eDestabilizing = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eDestabilizing,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsDestabilizing(1) = fitParameters.r2;
fitsDestabilizing(2) = fitParameters.r2u;
fitsDestabilizing(isnan(fitsDestabilizing)) = 0;

end

function [xTotal, eTotal,fitsTotal] = fitTotalSRM(e,atime,predictors,X0)

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% allow the gains to vary within +/-20%, allow the delays to vary within +/- 20 msec. note that lower bound for gains must be positive.
gainFlag = [true true true false true true true false];
UB(gainFlag) = 1.1*X0(gainFlag);
LB(gainFlag) = max(0.9*X0(gainFlag),0);
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));

% allow the final delays to vary within +/- 10sec
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));
UB(~gainFlag) = min(X0(~gainFlag)+0.010,0.250);
LB(~gainFlag) = max(X0(~gainFlag)-0.010,0.060);

% add a very small offset to improve convergence when LB and UB are very
% close.
UB((UB-LB)<1e-6) = UB((UB-LB)<1e-6)+1e-6;

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xTotal = X;
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end

function [xBraking, eBraking, fitsBraking] = fitTraditionalSRM_eeg(e,atime,predictors)
% fit "braking response" at end of perturbation.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

%[ka, kv, kd, lambda]
X0 = [10.0 0.01 0.01 0.050];
UB = [15.0 0.04 0.04 0.100];
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
LB = [ 0.0 0.00 0.00 0.020];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.050&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end %cSRM

function [xBraking, eBraking, fitsBraking] = fitResidualSRM_eeg(e,atime,predictors,subjID,magnitude,LB, UB)
% fit residuals using beta power.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

%Initial guess is midpoint of lower and upper bounds (LB and UB, respectively)
X0 = (UB-LB)/2; %[k_beta, lambda_beta]
gainFlag = [true false];

fixBurstGain = true;

if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.600))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end %Residual SRM (pre dSRM) w/ EEG

function [xTotal, eTotal,fitsTotal] = fitTotalDualSRM_eeg(e,atime,predictors,X0,subjID,magnitude,type)
% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% allow the gains to vary within +/-XX%, allow the delays to vary within +/- 20 msec. note that lower bound for gains must be positive.
gainFlag = [true true true false true false];
% UB(gainFlag) = 1.5*X0(gainFlag);
UB(gainFlag) = [1.1,1.5,1.5,1.5].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - Keep 1.1 the same for ka
% LB(gainFlag) = max(0.9*X0(gainFlag),0);
% LB(gainFlag) = max(0.3*X0(gainFlag),0);
LB(gainFlag) = [0.9,0,0,0].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - keep 0.9 the same for ka
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));

% allow the final delays to vary within +/- 10sec
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));
UB(~gainFlag) = min(X0(~gainFlag)+0.010,0.250);
LB(~gainFlag) = max(X0(~gainFlag)-0.010,0.060);
% if (strcmp(subjID,'step02') & magnitude == 2) | (strcmp(subjID,'step02') & magnitude == 3)
%     X0(4) = 0.100; %manually set brainstem CoM delay
% end
if strcmp(subjID,'step05') & magnitude == 2 & strcmp(type,'beta')
    X0(end) = 0.2; %manually set EEG delay initial guess to try to improve fit
    X0(5) = 0.01; LB(5) = 0;
elseif strcmp(subjID,'step09') & magnitude == 3 & strcmp(type,'beta')
    X0(end) = 0.27; %manually set EEG delay initial guess to try to improve fit
    X0(5) = 0.3; %manually set k_beta initial guess to try to improve fit
    % elseif strcmp(subjID,'step11') & magnitude == 2 & strcmp(type,'Cz')
    %     X0(end) = 0.220; LB(end) = 0.150; UB(end) = 0.400;
    %     LB(5) = 0.10;
end

% add a very small offset to improve convergence when LB and UB are very
% close.
UB((UB-LB)<1e-6) = UB((UB-LB)<1e-6)+1e-6;

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xTotal = X;
% eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4,:),X(5),X(6),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end %dSRM for EEG predictors

function [xBraking, eBraking, fitsBraking] = fitTraditionalSRM_DualSRM(e,atime,predictors,subjID,magnitude)
%Fit EMG w/ CoM Kinematics and Beta simultaneously

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% 60-250 ms search range from welch 2008

%Hand fit certain conditions (Identical to fitTraditionalSRM that only fits
%w/ CoM kinematics
%Hand fit certain conditions
if (strcmp(subjID,'step01') & magnitude == 1) | (strcmp(subjID,'step01') & magnitude == 3)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step04') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step05') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step06') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step07') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step08') & magnitude == 1) | (strcmp(subjID,'step08') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step10') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step11')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step12') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step15') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step17') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step18') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step19')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step20') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step21')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
else
    X0 = [10.0 0.01 0.01 0.150]; %[10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.250]; %[15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
end
%         error('Bounds were changed')
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false true false];
% add in k_beta and lambda_beta to UB, LB, and X0
X0(5:6) = [1 UB(4)+0.050];
LB(5:6) = [0 UB(4)+0.010];
UB(5:6) = [15 0.400];

fixBurstGain = true;
if fixBurstGain & strcmp(subjID,'step08') & magnitude == 1 %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step11') & magnitude == 2 %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step17') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step19') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step21') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.120&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
else
    burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end
% set constraints to force lambda_beta > lambda_EMG + 10ms
% A*x <= b; A is an M-by-N matrix, where M is the number of inequalities, and N is the number of variables (number of elements in x0).
A = [0 0 0 1 0 -1];
b = [-0.010];

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),...
    X0,A,b,[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4,:),X(5),X(6),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end %dSRM - Not used (fits EMG w/ CoM and EEG simultaneously (no jiggling)

function [xBraking, eBraking, fitsBraking] = fitResidualSRM_CoM(e,atime,predictors,subjID,magnitude,LB,UB)
% fit residuals using beta power.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

%Initial guess is midpoint of lower and upper bounds (LB and UB, respectively)
X0 = (UB-LB)/2; %[k_beta, lambda_beta]
gainFlag = [true true true false];

fixBurstGain = true;

if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.600))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end % fit residusls w/ coM

function [xTotal, eTotal,fitsTotal] = fitTotalDualSRM_CoM(e,atime,predictors,X0,subjID,magnitude)

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% allow the gains to vary within +/-XX%, allow the delays to vary within +/- 20 msec. note that lower bound for gains must be positive.
gainFlag = [true true true false true true true false];
% UB(gainFlag) = 1.5*X0(gainFlag);
UB(gainFlag) = [1.1, 1.5, 1.5,   1.1, 1.5, 1.5].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - Keep 1.1 the same for kas
% LB(gainFlag) = max(0.9*X0(gainFlag),0);
% LB(gainFlag) = max(0.3*X0(gainFlag),0);
LB(gainFlag) = [0.9, 0, 0,    0.9, 0.0, 0.0].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - keep 0.9 the same for ka to force fit with burst
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));

% allow the final delays to vary within +/- 10sec
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));
UB(~gainFlag) = min(X0(~gainFlag)+0.010,0.250);
LB(~gainFlag) = max(X0(~gainFlag)-0.010,0.060);

% try to hand fit participants
if (strcmp(subjID,'step04') & magnitude == 3)
    X0(end) = 0.300; %manually set ctx CoM delay
    UB(end) = 0.400;
elseif (strcmp(subjID,'step05') & magnitude == 3)
    X0(end) = 0.300; %manually set ctx CoM delay
    UB(end) = 0.400;
elseif (strcmp(subjID,'step08') & magnitude == 3)
    %     X0(2) = 0.005; LB(2) = 0; UB(2) = 0.025;
    X0(end) = 0.370; LB(end) = 200; UB(end) = 0.500;
end

% add a very small offset to improve convergence when LB and UB are very
% close.
UB((UB-LB)<1e-6) = UB((UB-LB)<1e-6)+1e-6;

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xTotal = X;
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end %dSRM for CoM Predictors
