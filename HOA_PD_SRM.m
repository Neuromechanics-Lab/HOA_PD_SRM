%% Script to run the SRM on HOA/PD data
clear; close all; tic;
%% load data & add MATLAB utility functions
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM-Practice\SRMUtilities')
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')

load('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\SRM Analysis\HOA_PD_DataTables_05-Oct-2023.mat') %output measures Table (EEG, EMG, etc.)
% DataAvTable.Cz = double(DataAvTable.Cz); %convert Cz(t) to class double for SRM recon
figdir = 'C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\Data\SRM Analysis\HOA_PD_SRM_savedfigs\';

%% User inputs
removeBackLev = 1;
% Saving options (if = 1 then will save)
saveopt = 1; %Output
savefigopt = 1; %Figures

% SRM reconstruction options
cSRMs_opt = false;

% Grouping Variables
direcs = unique(data.pertdir_calc_round_deg); % directions to be analyzed (90 and 270)
Participants = unique(DataAvTable.Participant); %Participant numerical marker (1, 2,3 -- double)
mags = unique(dataAv.condition)
Groups = unique(DataAvTable.Group); %Group marker ("HOA" or "PD" -- string)
subj_IDs = unique(DataAvTable.subj_ID); %Unique subject code (i.e. "HOA02" -- string)

%% Add SRM Outputs to the data table
%Find common time span for all variables (MoCap, EEG, EMG)
% EEG times (time_eeg and time_ersp are in ms, atime is in s)
max_time = 1.2;
min_time = -0.1;
ind_time = find(DataAvTable.atime(1,:) > min_time & DataAvTable.atime(1,:) <= max_time); % adjust window that will be fit by the SRM

TableHeight = size(DataAvTable,1);
ReconLength = length(DataAvTable.atime(1,ind_time)); %length of SRM Recon
% Feedback Gains
Ag_Gains = nan([TableHeight,4]);
Antag_Gains = nan([TableHeight,8]);
Beta_Gains = nan([TableHeight,4]);
Cz_Gains = nan([TableHeight,4]);
% SRM Reconstructions
BetaRecon = nan([TableHeight,ReconLength]);
AgonistRecon = nan([TableHeight,ReconLength]);
AntagonistRecon = nan([TableHeight,ReconLength]);
CzRecon = nan([TableHeight,ReconLength]);

% Reconstruction fits
fit_beta = nan([TableHeight,2]);
fit_agonist = nan([TableHeight,2]);
fit_antagonist = nan([TableHeight,2]);
fit_Cz = nan([TableHeight,2]);

% Residual SRM Outputs (w/ beta)
Residual = nan([TableHeight,ReconLength]);
Residual_Gains_beta = nan([TableHeight,2]);
ResidualRecon_beta = nan([TableHeight,ReconLength]);
fit_residual_beta = nan([TableHeight,2]);

% Dual SRM Outputs (w/ beta as predictor)
Ag_Gains_Dual_beta = nan([TableHeight,6]);
Ag_Gains_TotalDual_beta = nan([TableHeight,6]);
AgonistRecon_Dual_beta = nan([TableHeight,ReconLength]);
AgonistRecon_TotalDual_beta = nan([TableHeight,ReconLength]);
fit_agonist_Dual_beta = nan([TableHeight,2]);
fit_agonist_TotalDual_beta = nan([TableHeight,2]);

% Residual SRM Outputs (w/ Cz)
Residual_Gains_Cz = nan([TableHeight,2]);
ResidualRecon_Cz = nan([TableHeight,ReconLength]);
fit_residual_Cz = nan([TableHeight,2]);

% Dual SRM Outputs (w/ Cz as predictor)
Ag_Gains_TotalDual_Cz = nan([TableHeight,6]);
AgonistRecon_TotalDual_Cz = nan([TableHeight,ReconLength]);
fit_agonist_TotalDual_Cz = nan([TableHeight,2]);

% Residual SRM Outputs (w/ CoM)
Residual_Gains_CoM = nan([TableHeight,4]);
ResidualRecon_CoM = nan([TableHeight,ReconLength]);
fit_residual_CoM = nan([TableHeight,2]);

% Dual SRM Outputs (w/ CoM as predictor)
Ag_Gains_TotalDual_CoM = nan([TableHeight,8]);
AgonistRecon_TotalDual_CoM = nan([TableHeight,ReconLength]);
fit_agonist_TotalDual_CoM = nan([TableHeight,2]);

temp_Table = table(Residual, Ag_Gains, Antag_Gains, Beta_Gains, Cz_Gains, BetaRecon, CzRecon, AgonistRecon,...
    AntagonistRecon, fit_beta, fit_Cz, fit_agonist, fit_antagonist, Ag_Gains_Dual_beta, Ag_Gains_TotalDual_beta,...
    AgonistRecon_Dual_beta, AgonistRecon_TotalDual_beta, fit_agonist_Dual_beta, fit_agonist_TotalDual_beta,...
    Residual_Gains_beta, ResidualRecon_beta, fit_residual_beta, Ag_Gains_TotalDual_Cz,...
    AgonistRecon_TotalDual_Cz, fit_agonist_TotalDual_Cz,...
    Residual_Gains_Cz, ResidualRecon_Cz, fit_residual_Cz,...
    Ag_Gains_TotalDual_CoM,...
    AgonistRecon_TotalDual_CoM, fit_agonist_TotalDual_CoM,...
    Residual_Gains_CoM, ResidualRecon_CoM, fit_residual_CoM,...
    'VariableNames',{'Residual','Ag_Gains', 'Antag_Gains', 'Beta_Gains', 'Cz_Gains', 'BetaRecon', 'CzRecon', 'AgonistRecon',...
    'AntagonistRecon', 'fit_beta', 'fit_Cz', 'fit_agonist', 'fit_antagonist', 'Ag_Gains_Dual_beta', 'Ag_Gains_TotalDual_beta',...
    'AgonistRecon_Dual_beta', 'AgonistRecon_TotalDual_beta', 'fit_agonist_Dual_beta', 'fit_agonist_TotalDual_beta',...
    'Residual_Gains_beta', 'ResidualRecon_beta', 'fit_residual_beta', 'Ag_Gains_TotalDual_Cz',...
    'AgonistRecon_TotalDual_Cz', 'fit_agonist_TotalDual_Cz',...
    'Residual_Gains_Cz', 'ResidualRecon_Cz', 'fit_residual_Cz',...
    'Ag_Gains_TotalDual_CoM',...
    'AgonistRecon_TotalDual_CoM', 'fit_agonist_TotalDual_CoM',...
    'Residual_Gains_CoM', 'ResidualRecon_CoM', 'fit_residual_CoM'});

DataAvTable = [DataAvTable temp_Table];

%% Run SRM
loopbreak = false;
for Group = Groups' % group for loop
    zz = 0; % group counter
    ii = 0; % DataAvTable Row Counter
    for Participant = Participants'
        if ~loopbreak
            zz = zz + 1;
            xx = 0; yy = 0; % direction & magnitude counter
        elseif loopbreak
            xx = 1; yy = 1;
        end
        for direction = direcs' %iterate across each direction
            if ~loopbreak
                xx = xx + 1;
            end
            if xx == 2
                yy = 0;
            end

            %% pull variables from data table for SRM fit
            %condition index - to pull correct variables for SRM
            %analysis (i.e. correct row in DataAvTable)
            ind_cond = find(DataAvTable.Participant == Participant & ...
                DataAvTable.direc == direction & strcmp(DataAvTable.Group,Group));

            % Break if there are no participants that fit the unique group/participant ## pair (i.e. there is no HOA01 due to protocol change, but there is PD01)
            if isempty(ind_cond)
                loopbreak = true;
                break
            else
                ii = ii + 1;
                subjID = DataAvTable.subj_ID(ind_cond);
                loopbreak = false;
            end

            %specify which muscle is acting as an agonist/antagonist
            if direction == 90 %forward pert
                agonist = DataAvTable.TA_L(ind_cond,:); tag_ag='TA'; ag_norm = DataAvTable.TA_L_norm(ind_cond,:);
                antagonist = DataAvTable.MG_L(ind_cond,:); tag_antag='MG'; antag_norm = DataAvTable.MG_L_norm(ind_cond,:);
            elseif direction == 270 %backward pert
                antagonist = DataAvTable.TA_L(ind_cond,:); tag_antag='TA'; antag_norm = DataAvTable.TA_L_norm(ind_cond,:);
                agonist = DataAvTable.MG_L(ind_cond,:); tag_ag='MG'; ag_norm = DataAvTable.MG_L_norm(ind_cond,:);
            else
                error('Unspecified Direction')
            end

            %Modify CoM acc with stiction model
            % modifies CoM acceleration to fit the stiction model in Welch and Ting 2009
            atime = DataAvTable.atime(ind_cond,:);
            a = DataAvTable.cacc(ind_cond,:);
            a = stictionTemplate('a',a,'t',atime);

            %% interpolate everything to be same length as atime
            %mtime
            mtime = DataAvTable.mtime(ind_cond,:);
            v = DataAvTable.cvel(ind_cond,:);
            v = interp1(mtime, v, atime);

            d = DataAvTable.cposminus(ind_cond,:);
            d = interp1(mtime,d,atime);

            if cSRMs_opt
                %EEG outcome measures
                time_eeg = DataAvTable.time_eeg(ind_cond,:);
                Cz = DataAvTable.Cz(ind_cond,:);
                Cz = Cz/abs(DataAvTable.N1_amp(ind_cond,:)); %normalize Cz(t) to N1 amplitude (abs() b/c N1_amp is negative)
                Cz = interp1(time_eeg/1000, Cz, atime);

                time_ersp = DataAvTable.time_ersp(ind_cond,:);
                beta = DataAvTable.beta_ersp(ind_cond,:);
                beta  = interp1(time_ersp/1000, beta,  atime);
            end

            %% remove basline from CoM kinematics
            d = d-mean(d(DataAvTable.atime(1,:)<-0.1));
            v = v-mean(v(DataAvTable.atime(1,:)<-0.1));
            %% flip the CoM kinematic signal depending on pert direction
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

            [xPrime([5:8]), eRecon_antag_Destabilizing, fitPrime] = fitDestabilizingSRM(antagonist(ind_time),atime(ind_time),predictorsDestabilizing,subjID,magnitude);

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

            [x_ag([1:4]), eRecon_ag, fit_ag] = fitTraditionalSRM(agonist(ind_time),atime(ind_time),predictorsmSRM,subjID,magnitude);
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
                if Participant == 12 & magnitude == 3
                    LB(end) = 0.150;
                end
                [x_residual_beta([1:2]), eRecon_residual_beta, fit_residual_beta] = fitResidualSRM_eeg(residual, atime(ind_time), predictorsResiduals_beta, subjID, magnitude,LB, UB);

                %% Fit dual SRM (fit EMG w/ CoM & beta)
                X0Dual = [x_ag(1:4) x_residual_beta(1:2)];
                predictorsDual_beta = [predictorsmSRM; predictorsResiduals_beta];
                [xTotal_ag_dual_beta, eTotalRecon_ag_dual_beta, fitTotal_ag_dual_beta] = fitTotalDualSRM_eeg(agonist(ind_time), atime(ind_time), predictorsDual_beta, X0Dual, subjID, magnitude, type);
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
                [x_residual_Cz([1:2]), eRecon_residual_Cz, fit_residual_Cz] = fitResidualSRM_eeg(residual, atime(ind_time), predictorsResiduals_Cz, subjID, magnitude,LB, UB);

                %% Fit dual SRM (fit EMG w/ CoM & Cz)

                X0Dual = [x_ag(1:4) x_residual_Cz(1:2)];
                predictorsDual_Cz = [predictorsmSRM; predictorsResiduals_Cz];
                [xTotal_ag_dual_Cz, eTotalRecon_ag_dual_Cz, fitTotal_ag_dual_Cz] = fitTotalDualSRM_eeg(agonist(ind_time), atime(ind_time), predictorsDual_Cz, X0Dual, subjID, magnitude, type);
                clear type
            end
            %% Fit Residuals of eRecon_ag w/ CoM Kinematics
            predictorsResiduals_CoM = predictorsmSRM;
            UB = [15.0 0.04 0.04 0.300]; %[ka, kv, kd, lambda] - taken from fitTraditionalSRM (for gains) & fitResidual_eeg (for delay)
            LB = [ 0.0 0.00 0.00 x_ag(4)+0.010]; %set LB of delay based of mSRM fit
            if Participant == 12 & magnitude == 3
                LB(end) = 0.180;
            elseif Participant == 15 & magnitude == 3
                LB(end) = 0.300; UB(end) = 0.500;
            elseif Participant == 16 & magnitude == 3
                LB(end) = 0.400; UB(end) = 0.500;
            end
            [x_residual_CoM([1:4]), eRecon_residual_CoM, fit_residual_CoM] = fitResidualSRM_CoM(residual, atime(ind_time), predictorsResiduals_CoM, subjID, magnitude,LB, UB);

            %% Fit dual SRM (fit EMG w/ double CoM Feedback)
            X0Dual = [x_ag(1:4) x_residual_CoM(1:4)];
            predictorsDual_CoM = [predictorsmSRM; predictorsmSRM];
            [xTotal_ag_dual_CoM, eTotalRecon_ag_dual_CoM, fitTotal_ag_dual_CoM] = fitTotalDualSRM_CoM(agonist(ind_time), atime(ind_time), predictorsDual_CoM, X0Dual, subjID, magnitude);

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
            %% Plot single trial and mean EMG, EEG, and CoM kinematics
            %                 fig_RawData = figure(2); set(fig_RawData,'WindowState','maximized');
            %                 c = (xx-1).*3+yy; % counter for plot position % xx = direction counter;  y == magnitude counter
            %                 yl_EMG = 'auto'; % [0 0.3];
            %                 % Agonist Muscle Activity
            %                 plotij(7,3,1,c); hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     if direction == 270
            %                         plot_tag(DataAvTable.atime(ind_cond_singletrial(1),:),DataAvTable.MGL(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     elseif direction == 90
            %                         plot_tag(DataAvTable.atime(ind_cond_singletrial(1),:),DataAvTable.TAL(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     end
            %                 end
            %                 plot(atime,agonist*ag_norm,'k','LineWidth', 1)
            %                 ylabel([tag_ag ' EMG']); ylim(yl_EMG); title(['Mag = ' num2str(magnitude)])
            %                 if yy == 1
            %                     tmp_AgEMG_axis_mag1 = gca;
            %                     tmp_AgEMG_yl_mag1 = tmp_AgEMG_axis_mag1.YLim;
            %                 elseif yy == 2
            %                     tmp_AgEMG_axis_mag2 = gca;
            %                     tmp_AgEMG_yl_mag2 = tmp_AgEMG_axis_mag2.YLim;
            %                 elseif yy == 3
            %                     tmp_AgEMG_axis_mag3 = gca;
            %                     tmp_AgEMG_yl_mag3 = tmp_AgEMG_axis_mag3.YLim;
            %
            %                     tmp_AgEMG_yl = [tmp_AgEMG_yl_mag1; tmp_AgEMG_yl_mag2; tmp_AgEMG_yl_mag3];
            %                     tmp_AgEMG_yl = [min(tmp_AgEMG_yl(:)) max(tmp_AgEMG_yl(:))];
            %                     set(tmp_AgEMG_axis_mag1,'YLim',tmp_AgEMG_yl)
            %                     set(tmp_AgEMG_axis_mag2,'YLim',tmp_AgEMG_yl)
            %                     set(tmp_AgEMG_axis_mag3,'YLim',tmp_AgEMG_yl)
            %                 end
            %
            %                 % Antagonist Muscle Activity
            %                 plotij(7,3,2,c);  hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     if direction == 270
            %                         plot_tag(DataAvTable.atime(ind_cond_singletrial(1),:),DataAvTable.TAL(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     elseif direction == 90
            %                         plot_tag(DataAvTable.atime(ind_cond_singletrial(1),:),DataAvTable.MGL(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     end
            %                 end
            %                 plot(atime,antagonist*antag_norm,'k','LineWidth', 1)
            %                 ylabel([tag_antag ' EMG']); ylim(yl_EMG)
            %
            %                 if yy == 1
            %                     tmp_AnEMG_axis_mag1 = gca;
            %                     tmp_AnEMG_yl_mag1 = tmp_AnEMG_axis_mag1.YLim;
            %                 elseif yy == 2
            %                     tmp_AnEMG_axis_mag2 = gca;
            %                     tmp_AnEMG_yl_mag2 = tmp_AnEMG_axis_mag2.YLim;
            %                 elseif yy == 3
            %                     tmp_AnEMG_axis_mag3 = gca;
            %                     tmp_AnEMG_yl_mag3 = tmp_AnEMG_axis_mag3.YLim;
            %
            %                     tmp_AnEMG_yl = [tmp_AnEMG_yl_mag1; tmp_AnEMG_yl_mag2; tmp_AnEMG_yl_mag3];
            %                     tmp_AnEMG_yl = [min(tmp_AnEMG_yl(:)) max(tmp_AnEMG_yl(:))];
            %                     set(tmp_AnEMG_axis_mag1,'YLim',tmp_AnEMG_yl)
            %                     set(tmp_AnEMG_axis_mag2,'YLim',tmp_AnEMG_yl)
            %                     set(tmp_AnEMG_axis_mag3,'YLim',tmp_AnEMG_yl)
            %                 end
            %
            %                 % Beta Power
            %                 plotij(7,3,3,c);  hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     plot_tag(DataAvTable.time(ind_cond_singletrial(1),:)/1000,DataAvTable.beta_ersp(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                 end
            %                 plot(atime,beta*DataAvTable.beta_norm(ind_cond),'k','LineWidth', 1)
            %                 ylabel(['Beta']); xlim([-0.5 2]); %ylim(yl)
            %
            %                 if magnitude == 1
            %                     tmp_betadata_axis_mag1 = gca;
            %                     tmp_betadata_yl_mag1 = tmp_betadata_axis_mag1.YLim;
            %                 elseif magnitude == 2
            %                     tmp_betadata_axis_mag2 = gca;
            %                     tmp_betadata_yl_mag2 = tmp_betadata_axis_mag2.YLim;
            %                 elseif magnitude == 3
            %                     tmp_betadata_axis_mag3 = gca;
            %                     tmp_betadata_yl_mag3 = tmp_betadata_axis_mag3.YLim;
            %
            %                     tmp_betadata_yl = [tmp_betadata_yl_mag1; tmp_betadata_yl_mag2; tmp_betadata_yl_mag3];
            %                     tmp_betadata_yl = [min(tmp_betadata_yl(:)) max(tmp_betadata_yl(:))];
            %                     set(tmp_betadata_axis_mag1,'YLim',tmp_betadata_yl)
            %                     set(tmp_betadata_axis_mag2,'YLim',tmp_betadata_yl)
            %                     set(tmp_betadata_axis_mag3,'YLim',tmp_betadata_yl)
            %                 end
            %
            %                 % Cz Power
            %                 plotij(7,3,4,c);  hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     plot_tag(DataAvTable.time_eeg(ind_cond_singletrial(1),:)/1000,DataAvTable.Cz(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                 end
            %                 plot(atime,Cz*abs(DataAvTable.N1_amp)(ind_cond),'k','LineWidth', 1)
            %                 ylabel(['Cz']); xlim([-0.5 2]); %ylim(yl)
            %
            %                 if magnitude == 1
            %                     tmp_Czdata_axis_mag1 = gca;
            %                     tmp_Czdata_yl_mag1 = tmp_Czdata_axis_mag1.YLim;
            %                 elseif magnitude == 2
            %                     tmp_Czdata_axis_mag2 = gca;
            %                     tmp_Czdata_yl_mag2 = tmp_Czdata_axis_mag2.YLim;
            %                 elseif magnitude == 3
            %                     tmp_Czdata_axis_mag3 = gca;
            %                     tmp_Czdata_yl_mag3 = tmp_Czdata_axis_mag3.YLim;
            %
            %                     tmp_Czdata_yl = [tmp_Czdata_yl_mag1; tmp_Czdata_yl_mag2; tmp_Czdata_yl_mag3];
            %                     tmp_Czdata_yl = [min(tmp_Czdata_yl(:)) max(tmp_Czdata_yl(:))];
            %                     set(tmp_Czdata_axis_mag1,'YLim',tmp_Czdata_yl)
            %                     set(tmp_Czdata_axis_mag2,'YLim',tmp_Czdata_yl)
            %                     set(tmp_Czdata_axis_mag3,'YLim',tmp_Czdata_yl)
            %                 end
            %
            %                 % CoM Acceleration
            %                 plotij(7,3,5,c); hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     if strcmp(subjID,'step08')
            %                         plot_tag(DataAvTable.atime(1,:),-DataAvTable.cacc(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     else
            %                         plot_tag(DataAvTable.atime(1,:),DataAvTable.cacc(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     end
            %                 end
            %                 plot(atime,a,'k','LineWidth', 1)
            %                 ylabel('A')
            %                 if yy == 1
            %                     tmp7_axis_mag1 = gca;
            %                     tmp7_yl_mag1 = tmp7_axis_mag1.YLim;
            %                 elseif yy == 2
            %                     tmp7_axis_mag2 = gca;
            %                     tmp7_yl_mag2 = tmp7_axis_mag2.YLim;
            %                 elseif yy == 3
            %                     tmp7_axis_mag3 = gca;
            %                     tmp7_yl_mag3 = tmp7_axis_mag3.YLim;
            %
            %                     tmp7_yl = [tmp7_yl_mag1; tmp7_yl_mag2; tmp7_yl_mag3];
            %                     tmp7_yl = [min(tmp7_yl(:)) max(tmp7_yl(:))];
            %                     set(tmp7_axis_mag1,'YLim',tmp7_yl)
            %                     set(tmp7_axis_mag2,'YLim',tmp7_yl)
            %                     set(tmp7_axis_mag3,'YLim',tmp7_yl)
            %                 end
            %
            %                 % CoM Velocity
            %                 plotij(7,3,6,c); hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     if strcmp(subjID,'step08')
            %                         plot_tag(DataAvTable.mtime(1,:),-DataAvTable.cvel(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     else
            %                         plot_tag(DataAvTable.mtime(1,:),DataAvTable.cvel(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     end
            %                 end
            %                 plot(DataAvTable.atime(1,:),v,'k','LineWidth', 1)
            %                 ylabel('V')
            %                 if yy == 1
            %                     tmp8_axis_mag1 = gca;
            %                     tmp8_yl_mag1 = tmp8_axis_mag1.YLim;
            %                 elseif yy == 2
            %                     tmp8_axis_mag2 = gca;
            %                     tmp8_yl_mag2 = tmp8_axis_mag2.YLim;
            %                 elseif yy == 3
            %                     tmp8_axis_mag3 = gca;
            %                     tmp8_yl_mag3 = tmp8_axis_mag3.YLim;
            %
            %                     tmp8_yl = [tmp8_yl_mag1; tmp8_yl_mag2; tmp8_yl_mag3];
            %                     tmp8_yl = [min(tmp8_yl(:)) max(tmp8_yl(:))];
            %                     set(tmp8_axis_mag1,'YLim',tmp8_yl)
            %                     set(tmp8_axis_mag2,'YLim',tmp8_yl)
            %                     set(tmp8_axis_mag3,'YLim',tmp8_yl)
            %                 end
            %
            %                 % CoM Position
            %                 plotij(7,3,7,c); hold on
            %                 for j = 1:length(ind_cond_singletrial)
            %                     if strcmp(subjID,'step08')
            %                         plot_tag(DataAvTable.mtime(1,:),-DataAvTable.cposminus(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     else
            %                         plot_tag(DataAvTable.mtime(1,:),DataAvTable.cposminus(ind_cond_singletrial(j),:),string(ind_cond_singletrial(j)),'color',0.5.*[1 1 1])
            %                     end
            %                 end
            %                 plot(DataAvTable.atime,d,'k','LineWidth', 1);
            %                 ylabel('D')
            %                 xlabel('Time (s)')
            %                 if yy == 1
            %                     tmp9_axis_mag1 = gca;
            %                     tmp9_yl_mag1 = tmp9_axis_mag1.YLim;
            %                 elseif yy == 2
            %                     tmp9_axis_mag2 = gca;
            %                     tmp9_yl_mag2 = tmp9_axis_mag2.YLim;
            %                 elseif yy == 3
            %                     tmp9_axis_mag3 = gca;
            %                     tmp9_yl_mag3 = tmp9_axis_mag3.YLim;
            %
            %                     tmp9_yl = [tmp9_yl_mag1; tmp9_yl_mag2; tmp9_yl_mag3];
            %                     tmp9_yl = [min(tmp9_yl(:)) max(tmp9_yl(:))];
            %                     set(tmp9_axis_mag1,'YLim',tmp9_yl)
            %                     set(tmp9_axis_mag2,'YLim',tmp9_yl)
            %                     set(tmp9_axis_mag3,'YLim',tmp9_yl)
            %                 end
            %                 if Participant < 10
            %                     sgtitle([subjID])
            %                 elseif Participant >= 10
            %                     sgtitle([subjID])
            %                 end

            %% Plot Dual SRM Comparisons
            yl = [0 0.5];
            figure(magnitude+direction+1000); set(gcf,'WindowState','maximized');
            %mSRM
            ax1 = plotij(4,2,1,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),eRecon_ag,'g','LineWidth',2)
            title({['mSRM']...
                [sprintf('ka=%1.2g', x_ag(1)) ' ' sprintf('kv=%1.2g',x_ag(2)) ' ' sprintf('kd=%1.2g',x_ag(3))]})
            legend('Data','mSRM'); ylabel([tag_ag ' EMG']);
            text(-0.4,0.15,sprintf('R^{2} = %1.2g',fit_ag(1)))
            text(-0.4,0.1,sprintf('VAF = %1.2g',fit_ag(2)))
            % dSRM (beta)
            ax2 = plotij(4,2,2,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_beta,'r','LineWidth',2)
            title({['dSRM - beta predictor']...
                [sprintf('ka=%1.2g', xTotal_ag_dual_beta(1)) ' ' sprintf('kv=%1.2g',xTotal_ag_dual_beta(2))...
                ' ' sprintf('kd=%1.2g',xTotal_ag_dual_beta(3)) ' ' sprintf('kb=%1.2g',xTotal_ag_dual_beta(5))]})
            legend('Data','dSRM (beta)'); ylabel([tag_ag ' EMG']);
            text(-0.4,0.15,sprintf('R^{2} = %1.2g',fitTotal_ag_dual_beta(1)))
            text(-0.4,0.1,sprintf('VAF = %1.2g',fitTotal_ag_dual_beta(2)))
            % dSRM (Cz)
            ax3 = plotij(4,2,3,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_Cz,'b','LineWidth',2)
            title({['dSRM - Cz predictor']...
                [sprintf('ka=%1.2g', xTotal_ag_dual_Cz(1)) ' ' sprintf('kv=%1.2g',xTotal_ag_dual_Cz(2))...
                ' ' sprintf('kd=%1.2g',xTotal_ag_dual_Cz(3)) ' ' sprintf('kCz=%1.2g',xTotal_ag_dual_Cz(5))]})
            legend('Data','dSRM (Cz)'); ylabel([tag_ag ' EMG']);
            text(-0.4,0.15,sprintf('R^{2} = %1.2g',fitTotal_ag_dual_Cz(1)))
            text(-0.4,0.1,sprintf('VAF = %1.2g',fitTotal_ag_dual_Cz(2)))
            % dSRM (double CoM)
            ax4 = plotij(4,2,4,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_CoM,'m','LineWidth',2)
            title({['dSRM - double CoM predictor']...
                [sprintf('ka1=%1.2g', xTotal_ag_dual_CoM(1)) ' ' sprintf('kv1=%1.2g',xTotal_ag_dual_CoM(2))...
                ' ' sprintf('kd1=%1.2g',xTotal_ag_dual_CoM(3)) ' ' sprintf('ka2=%1.2g',xTotal_ag_dual_CoM(5))...
                ' ' sprintf('kv1=%1.2g',xTotal_ag_dual_CoM(6)) ' ' sprintf('kd2=%1.2g',xTotal_ag_dual_CoM(7))]})
            legend('Data','dSRM (CoM)'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            text(-0.4,0.15,sprintf('R^{2} = %1.2g',fitTotal_ag_dual_CoM(1)))
            text(-0.4,0.1,sprintf('VAF = %1.2g',fitTotal_ag_dual_CoM(2)))
            % all on same plot
            ax5 = plotij(1,2,1,2); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),eRecon_ag,'g','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_beta,'r','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_Cz,'b','LineWidth',2)
            plot(atime(ind_time),eTotalRecon_ag_dual_CoM,'m','LineWidth',2)
            title('All SRMs'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            legend('Data','mSRM','dSRM (beta)','dSRM (Cz)','dSRM (CoM')

            sgtitle([subjID + ' Mag' + num2str(magnitude) + " direc" + num2str(direction)])

            %Set ylim to be the same between plots
            ylims = [ax1.YLim ax2.YLim ax3.YLim ax4.YLim];
            yl = max(ylims); yl = [0 yl];
            set(ax1,'YLim',yl)
            set(ax2,'YLim',yl)
            set(ax3,'YLim',yl)
            set(ax4,'YLim',yl)
            set(ax5,'YLim',yl)

            if savefigopt
                saveas(gcf,[figdir + subjID + '_DualSRMCompare_mag' + num2str(magnitude) + '_direc' + num2str(direction) + '.fig'],'fig')
                saveas(gcf,[figdir + subjID + '_DualSRMCompare_mag' + num2str(magnitude) + '_direc' + num2str(direction) + '.jpg'],'jpg')
            end

            %% Plot SRM components
            % two figures - 1 for mSRM and cSRMs 1 for dSRMs
            fig_SRMReconComponents_1 = figure(direction+10000); set(fig_SRMReconComponents_1,'WindowState','maximized')
            % cSRM  - Beta
            plotij(3,3,1,yy)
            hold on
            plot(atime(ind_time),eegRecon_beta*DataAvTable.beta_norm(ind_cond),'k','LineWidth',1);
            %SRM Output
            plot(atime(ind_time)+x_eeg_beta(4), (predictorsTrad_eeg(1,:).*x_eeg_beta(1) + backLev_beta)*DataAvTable.beta_norm(ind_cond),'r')
            plot(atime(ind_time)+x_eeg_beta(4), (predictorsTrad_eeg(2,:).*x_eeg_beta(2) + backLev_beta)*DataAvTable.beta_norm(ind_cond),'b')
            plot(atime(ind_time)+x_eeg_beta(4), (predictorsTrad_eeg(3,:).*x_eeg_beta(3) + backLev_beta)*DataAvTable.beta_norm(ind_cond),'g')
            legend('Recon', 'ka', 'kv', 'kd')
            ylabel(['cSRM  - Beta '])
            title({['Mag = ' num2str(yy) '     \beta Norm = ' num2str(DataAvTable.beta_norm(ind_cond))]...
                [sprintf('ka=%1.2g', x_eeg_beta(1)) ' ' sprintf('kv=%1.2g',x_eeg_beta(2)) ' ' sprintf('kd=%1.2g',x_eeg_beta(3))]})

            if yy == 1
                tmp3_axis_cSRM_B_mag1 = gca;
                tmp3_yl_cSRM_B_mag1 = tmp3_axis_cSRM_B_mag1.YLim;
            elseif yy == 2
                tmp3_axis_cSRM_B_mag2 = gca;
                tmp3_yl_cSRM_B_mag2 = tmp3_axis_cSRM_B_mag2.YLim;
            elseif yy == 3
                tmp3_axis_cSRM_B_mag3 = gca;
                tmp3_yl_cSRM_B_mag3 = tmp3_axis_cSRM_B_mag3.YLim;

                tmp3_yl_cSRM_B = [tmp3_yl_cSRM_B_mag1; tmp3_yl_cSRM_B_mag2; tmp3_yl_cSRM_B_mag3];
                tmp3_yl_cSRM_B = [min(tmp3_yl_cSRM_B(:)) max(tmp3_yl_cSRM_B(:))];
                set(tmp3_axis_cSRM_B_mag1,'YLim',tmp3_yl_cSRM_B)
                set(tmp3_axis_cSRM_B_mag2,'YLim',tmp3_yl_cSRM_B)
                set(tmp3_axis_cSRM_B_mag3,'YLim',tmp3_yl_cSRM_B)
            end

            % cSRM - Cz
            plotij(3,3,2,yy)
            hold on
            plot(atime(ind_time),-(eegRecon_Cz)*abs(DataAvTable.N1_amp(ind_cond)),'k','LineWidth',1);
            %SRM Output
            plot(atime(ind_time)+x_eeg_Cz(4), (predictorsTrad_eeg(1,:).*x_eeg_Cz(1))*abs(DataAvTable.N1_amp(ind_cond)),'r')
            plot(atime(ind_time)+x_eeg_Cz(4), (predictorsTrad_eeg(2,:).*x_eeg_Cz(2))*abs(DataAvTable.N1_amp(ind_cond)),'b')
            plot(atime(ind_time)+x_eeg_Cz(4), (predictorsTrad_eeg(3,:).*x_eeg_Cz(3))*abs(DataAvTable.N1_amp(ind_cond)),'g')
            ylabel(['cSRM - Cz '])
            title({['Mag = ' num2str(yy) '     N1 Amp = ' num2str(abs(DataAvTable.N1_amp(ind_cond)))]...
                [sprintf('ka=%1.2g', x_eeg_Cz(1)) ' ' sprintf('kv=%1.2g',x_eeg_Cz(2)) ' ' sprintf('kd=%1.2g',x_eeg_Cz(3))]})

            if yy == 1
                tmp3_axis_cSRM_Cz_mag1 = gca;
                tmp3_yl_cSRM_Cz_mag1 = tmp3_axis_cSRM_Cz_mag1.YLim;
            elseif yy == 2
                tmp3_axis_cSRM_Cz_mag2 = gca;
                tmp3_yl_cSRM_Cz_mag2 = tmp3_axis_cSRM_Cz_mag2.YLim;
            elseif yy == 3
                tmp3_axis_cSRM_Cz_mag3 = gca;
                tmp3_yl_cSRM_Cz_mag3 = tmp3_axis_cSRM_Cz_mag3.YLim;

                tmp3_yl_cSRM_B = [tmp3_yl_cSRM_Cz_mag1; tmp3_yl_cSRM_Cz_mag2; tmp3_yl_cSRM_Cz_mag3];
                tmp3_yl_cSRM_B = [min(tmp3_yl_cSRM_B(:)) max(tmp3_yl_cSRM_B(:))];
                set(tmp3_axis_cSRM_Cz_mag1,'YLim',tmp3_yl_cSRM_B)
                set(tmp3_axis_cSRM_Cz_mag2,'YLim',tmp3_yl_cSRM_B)
                set(tmp3_axis_cSRM_Cz_mag3,'YLim',tmp3_yl_cSRM_B)
            end


            % mSRM
            plotij(3,3,3,yy)
            hold on
            plot(atime(ind_time),eRecon_ag,'k','LineWidth',1);
            %SRM Output
            plot(atime(ind_time)+x_ag(4), (predictorsmSRM(1,:).*x_ag(1)),'r')
            plot(atime(ind_time)+x_ag(4), (predictorsmSRM(2,:).*x_ag(2)),'b')
            plot(atime(ind_time)+x_ag(4), (predictorsmSRM(3,:).*x_ag(3)),'g')
            ylabel(['mSRM']); xlabel('Time (s)')
            title({['Mag = ' num2str(yy)]...
                [sprintf('ka=%1.2g', x_ag(1)) ' ' sprintf('kv=%1.2g',x_ag(2)) ' ' sprintf('kd=%1.2g',x_ag(3))]})

            if yy == 1
                tmp3_axis_mSRM_mag1 = gca;
                tmp3_yl_mSRM_mag1 = tmp3_axis_mSRM_mag1.YLim;
            elseif yy == 2
                tmp3_axis_mSRM_mag2 = gca;
                tmp3_yl_mSRM_mag2 = tmp3_axis_mSRM_mag2.YLim;
            elseif yy == 3
                tmp3_axis_mSRM_mag3 = gca;
                tmp3_yl_mSRM_mag3 = tmp3_axis_mSRM_mag3.YLim;

                tmp3_yl_mSRM = [tmp3_yl_mSRM_mag1; tmp3_yl_mSRM_mag2; tmp3_yl_mSRM_mag3];
                tmp3_yl_mSRM = [min(tmp3_yl_mSRM(:)) max(tmp3_yl_mSRM(:))];
                set(tmp3_axis_mSRM_mag1,'YLim',tmp3_yl_mSRM)
                set(tmp3_axis_mSRM_mag2,'YLim',tmp3_yl_mSRM)
                set(tmp3_axis_mSRM_mag3,'YLim',tmp3_yl_mSRM)
            end

            % second SRM components figure
            fig_SRMReconComponents_2 = figure(direction+10000); set(fig_SRMReconComponents_2,'WindowState','maximized')
            % dSRM  (beta)
            plotij(3,3,1,yy); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_beta,'k','LineWidth',1);
            plot(atime+xTotal_ag_dual_beta(4), a_ag.*xTotal_ag_dual_beta(1),'r')
            plot(atime+xTotal_ag_dual_beta(4), v_ag.*xTotal_ag_dual_beta(2),'b')
            plot(atime+xTotal_ag_dual_beta(4), d_ag.*xTotal_ag_dual_beta(3),'g')
            plot(atime+xTotal_ag_dual_beta(6), beta.*xTotal_ag_dual_beta(5),'m')

            ylabel(['dSRM (beta)'])
            title({['Mag = ' num2str(yy)]...
                [sprintf('ka=%1.2g', xTotal_ag_dual_beta(1)) ' ' sprintf('kv=%1.2g',xTotal_ag_dual_beta(2))...
                ' ' sprintf('kd=%1.2g',xTotal_ag_dual_beta(3)) ' ' sprintf('kb=%1.2g',xTotal_ag_dual_beta(5))]})
            legend('dSRM (beta)', 'ka', 'kv', 'kd','kb')

            if yy == 1
                tmp4_axis_dSRM_B_mag1 = gca;
                tmp4_yl_dSRM_B_mag1 = tmp4_axis_dSRM_B_mag1.YLim;
            elseif yy == 2
                tmp4_axis_dSRM_B_mag2 = gca;
                tmp4_yl_dSRM_B_mag2 = tmp4_axis_dSRM_B_mag2.YLim;
            elseif yy == 3
                tmp4_axis_dSRM_B_mag3 = gca;
                tmp4_yl_dSRM_B_mag3 = tmp4_axis_dSRM_B_mag3.YLim;

                tmp4_yl_dSRM_B = [tmp4_yl_dSRM_B_mag1; tmp4_yl_dSRM_B_mag2; tmp4_yl_dSRM_B_mag3];
                tmp4_yl_dSRM_B = [min(tmp4_yl_dSRM_B(:)) max(tmp4_yl_dSRM_B(:))];
                set(tmp4_axis_dSRM_B_mag1,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_B_mag2,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_B_mag3,'YLim',tmp4_yl_dSRM_B)
            end

            % dSRM  (Cz)
            plotij(3,3,2,yy); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_Cz,'k','LineWidth',1);
            plot(atime+xTotal_ag_dual_Cz(4), a_ag.*xTotal_ag_dual_Cz(1),'r')
            plot(atime+xTotal_ag_dual_Cz(4), v_ag.*xTotal_ag_dual_Cz(2),'b')
            plot(atime+xTotal_ag_dual_Cz(4), d_ag.*xTotal_ag_dual_Cz(3),'g')
            plot(atime+xTotal_ag_dual_Cz(6), -Cz.*xTotal_ag_dual_Cz(5),'m')

            ylabel(['dSRM (Cz)'])
            title({['Mag = ' num2str(yy)]...
                [sprintf('ka=%1.2g', xTotal_ag_dual_Cz(1)) ' ' sprintf('kv=%1.2g',xTotal_ag_dual_Cz(2))...
                ' ' sprintf('kd=%1.2g',xTotal_ag_dual_Cz(3)) ' ' sprintf('kCz=%1.2g',xTotal_ag_dual_Cz(5))]})
            legend('dSRM (Cz)', 'ka', 'kv', 'kd','kCz')
            %         if norm_emg
            %             ylim(yl_emg)
            %         end
            %         ylim([-0.4 0.4])
            if yy == 1
                tmp4_axis_dSRM_Cz_mag1 = gca;
                tmp4_yl_dSRM_Cz_mag1 = tmp4_axis_dSRM_Cz_mag1.YLim;
            elseif yy == 2
                tmp4_axis_dSRM_Cz_mag2 = gca;
                tmp4_yl_dSRM_Cz_mag2 = tmp4_axis_dSRM_Cz_mag2.YLim;
            elseif yy == 3
                tmp4_axis_dSRM_Cz_mag3 = gca;
                tmp4_yl_dSRM_Cz_mag3 = tmp4_axis_dSRM_Cz_mag3.YLim;

                tmp4_yl_dSRM_B = [tmp4_yl_dSRM_Cz_mag1; tmp4_yl_dSRM_Cz_mag2; tmp4_yl_dSRM_Cz_mag3];
                tmp4_yl_dSRM_B = [min(tmp4_yl_dSRM_B(:)) max(tmp4_yl_dSRM_B(:))];
                set(tmp4_axis_dSRM_Cz_mag1,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_Cz_mag2,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_Cz_mag3,'YLim',tmp4_yl_dSRM_B)
            end


            % dSRM  (CoM)
            plotij(3,3,3,yy); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_CoM,'k','LineWidth',1);
            plot(atime+xTotal_ag_dual_CoM(4), a_ag.*xTotal_ag_dual_CoM(1),'r')
            plot(atime+xTotal_ag_dual_CoM(4), v_ag.*xTotal_ag_dual_CoM(2),'b')
            plot(atime+xTotal_ag_dual_CoM(4), d_ag.*xTotal_ag_dual_CoM(3),'g')
            plot(atime+xTotal_ag_dual_CoM(8), a_ag.*xTotal_ag_dual_CoM(5),'r--')
            plot(atime+xTotal_ag_dual_CoM(8), v_ag.*xTotal_ag_dual_CoM(6),'b--')
            plot(atime+xTotal_ag_dual_CoM(8), d_ag.*xTotal_ag_dual_CoM(7),'g--')

            ylabel(['dSRM (CoM)']); xlabel('Time (s)')
            title({['Mag = ' num2str(yy)]...
                [sprintf('ka1=%1.2g', xTotal_ag_dual_CoM(1)) ' ' sprintf('kv1=%1.2g',xTotal_ag_dual_CoM(2))...
                ' ' sprintf('kd1=%1.2g',xTotal_ag_dual_CoM(3)) ' ' sprintf('ka2=%1.2g',xTotal_ag_dual_CoM(5))...
                ' ' sprintf('kv2=%1.2g',xTotal_ag_dual_CoM(6)) ' ' sprintf('kd2=%1.2g',xTotal_ag_dual_CoM(7))]})
            legend('dSRM (CoM)', 'ka1', 'kv1', 'kd1','ka2','kv2','kd2')
            %         if norm_emg
            %             ylim(yl_emg)
            %         end
            %         ylim([-0.4 0.4])
            if yy == 1
                tmp4_axis_dSRM_CoM_mag1 = gca;
                tmp4_yl_dSRM_CoM_mag1 = tmp4_axis_dSRM_CoM_mag1.YLim;
            elseif yy == 2
                tmp4_axis_dSRM_CoM_mag2 = gca;
                tmp4_yl_dSRM_CoM_mag2 = tmp4_axis_dSRM_CoM_mag2.YLim;
            elseif yy == 3
                tmp4_axis_dSRM_CoM_mag3 = gca;
                tmp4_yl_dSRM_CoM_mag3 = tmp4_axis_dSRM_CoM_mag3.YLim;

                tmp4_yl_dSRM_B = [tmp4_yl_dSRM_CoM_mag1; tmp4_yl_dSRM_CoM_mag2; tmp4_yl_dSRM_CoM_mag3];
                tmp4_yl_dSRM_B = [min(tmp4_yl_dSRM_B(:)) max(tmp4_yl_dSRM_B(:))];
                set(tmp4_axis_dSRM_CoM_mag1,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_CoM_mag2,'YLim',tmp4_yl_dSRM_B)
                set(tmp4_axis_dSRM_CoM_mag3,'YLim',tmp4_yl_dSRM_B)
            end

            % set title
            sgtitle([subjID + " direc" + num2str(direction)])
            %% plot Recons and Data
            XLim = [-0.4 1.2];
            YLim=[-0.1 1];
            fig_SRMRecon = figure(direction); set(fig_SRMRecon,'WindowState','maximized')
            % cSRM - Beta
            plotij(6,3,1,yy)
            plot(atime,beta*DataAvTable.beta_norm(ind_cond),'k','LineWidth',1); hold on
            plot(atime(ind_time),eegRecon_beta*DataAvTable.beta_norm(ind_cond),'b','LineWidth',1);
            VAF = fit_eeg_beta(2);
            R2 = fit_eeg_beta(1);
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            legend('Data', 'Recon')
            title({[sprintf('mag = %1.0f',yy)] [VAFstr ' ' R2str ' ' sprintf('beta Norm = %1.2g',DataAvTable.beta_norm(ind_cond))]})
            ylabel(['Beta cSRM'])
            % to set the ylims the same across
            if yy == 1
                tmp_axis_cSRM_B_mag1 = gca;
                tmp_yl_cSRM_B_mag1 = tmp_axis_cSRM_B_mag1.YLim;
            elseif yy == 2
                tmp_axis_cSRM_B_mag2 = gca;
                tmp_yl_cSRM_B_mag2 = tmp_axis_cSRM_B_mag2.YLim;
            elseif yy == 3
                tmp_axis_cSRM_B_mag3 = gca;
                tmp_yl_cSRM_B_mag3 = tmp_axis_cSRM_B_mag3.YLim;

                tmp_yl_cSRM_B = [tmp_yl_cSRM_B_mag1; tmp_yl_cSRM_B_mag2; tmp_yl_cSRM_B_mag3];
                tmp_yl_cSRM_B = [min(tmp_yl_cSRM_B(:)) max(tmp_yl_cSRM_B(:))];
                set(tmp_axis_cSRM_B_mag1,'YLim',tmp_yl_cSRM_B)
                set(tmp_axis_cSRM_B_mag2,'YLim',tmp_yl_cSRM_B)
                set(tmp_axis_cSRM_B_mag3,'YLim',tmp_yl_cSRM_B)
            end

            % cSRM - Cz
            plotij(6,3,2,yy)
            plot(atime,Cz*abs(DataAvTable.N1_amp(ind_cond)),'k','LineWidth',1); hold on
            plot(atime(ind_time),eegRecon_Cz*abs(DataAvTable.N1_amp(ind_cond)),'b','LineWidth',1);
            VAF = fit_eeg_Cz(2);
            R2 = fit_eeg_Cz(1);
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            title([VAFstr ' ' R2str ' ' sprintf('N1 Amp = %1.2g',abs(DataAvTable.N1_amp(ind_cond)))])
            ylabel(['Cz cSRM'])
            % to set the ylims the same across
            if yy == 1
                tmp_axis_cSRM_Cz_mag1 = gca;
                tmp_yl_cSRM_Cz_mag1 = tmp_axis_cSRM_Cz_mag1.YLim;
            elseif yy == 2
                tmp_axis_cSRM_Cz_mag2 = gca;
                tmp_yl_cSRM_Cz_mag2 = tmp_axis_cSRM_Cz_mag2.YLim;
            elseif yy == 3
                tmp_axis_cSRM_Cz_mag3 = gca;
                tmp_yl_cSRM_Cz_mag3 = tmp_axis_cSRM_Cz_mag3.YLim;

                tmp_yl_cSRM_B = [tmp_yl_cSRM_Cz_mag1; tmp_yl_cSRM_Cz_mag2; tmp_yl_cSRM_Cz_mag3];
                tmp_yl_cSRM_B = [min(tmp_yl_cSRM_B(:)) max(tmp_yl_cSRM_B(:))];
                set(tmp_axis_cSRM_Cz_mag1,'YLim',tmp_yl_cSRM_B)
                set(tmp_axis_cSRM_Cz_mag2,'YLim',tmp_yl_cSRM_B)
                set(tmp_axis_cSRM_Cz_mag3,'YLim',tmp_yl_cSRM_B)
            end
            %         ylim([-0.1 0.4])
            %         if norm_eeg
            %             ylim(yl_eeg)
            %         end

            % mSRM
            plotij(6,3,3,yy)
            plot(atime,agonist,'k','LineWidth',1); hold on
            plot(atime(ind_time),eRecon_ag,'b','LineWidth',1);

            VAF = fit_ag(2); %rsqr_uncentered(ag',eTotalRecon_ag');
            R2 = fit_ag(1); %rsqr(ag',eTotalRecon_ag');
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            title([VAFstr ' ' R2str])
            ylabel('mSRM')
            if yy == 1
                tmp1_axis_mSRM_mag1 = gca;
                tmp1_yl_mSRM_mag1 = tmp1_axis_mSRM_mag1.YLim;
            elseif yy == 2
                tmp1_axis_mSRM_mag2 = gca;
                tmp1_yl_mSRM_mag2 = tmp1_axis_mSRM_mag2.YLim;
            elseif yy == 3
                tmp1_axis_mSRM_mag3 = gca;
                tmp1_yl_mSRM_mag3 = tmp1_axis_mSRM_mag3.YLim;

                tmp1_yl_mSRM = [tmp1_yl_mSRM_mag1; tmp1_yl_mSRM_mag2; tmp1_yl_mSRM_mag3];
                tmp1_yl_mSRM = [min(tmp1_yl_mSRM(:)) max(tmp1_yl_mSRM(:))];
                set(tmp1_axis_mSRM_mag1,'YLim',tmp1_yl_mSRM)
                set(tmp1_axis_mSRM_mag2,'YLim',tmp1_yl_mSRM)
                set(tmp1_axis_mSRM_mag3,'YLim',tmp1_yl_mSRM)
            end

            % dSRM (Beta)
            plotij(6,3,4,yy)
            plot(atime,agonist,'k','LineWidth',1); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_beta,'b','LineWidth',1);

            VAF = fitTotal_ag_dual_beta(2); %rsqr_uncentered(ag',eTotalRecon_ag');
            R2 = fitTotal_ag_dual_beta(1); %rsqr(ag',eTotalRecon_ag');
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            title([VAFstr ' ' R2str])
            ylabel('dSRM (Beta)')
            if yy == 1
                tmp1_axis_dSRM_B_mag1 = gca;
                tmp1_yl_dSRM_B_mag1 = tmp1_axis_dSRM_B_mag1.YLim;
            elseif yy == 2
                tmp1_axis_dSRM_B_mag2 = gca;
                tmp1_yl_dSRM_B_mag2 = tmp1_axis_dSRM_B_mag2.YLim;
            elseif yy == 3
                tmp1_axis_dSRM_B_mag3 = gca;
                tmp1_yl_dSRM_B_mag3 = tmp1_axis_dSRM_B_mag3.YLim;

                tmp1_yl_dSRM_B = [tmp1_yl_dSRM_B_mag1; tmp1_yl_dSRM_B_mag2; tmp1_yl_dSRM_B_mag3];
                tmp1_yl_dSRM_B = [min(tmp1_yl_dSRM_B(:)) max(tmp1_yl_dSRM_B(:))];
                set(tmp1_axis_dSRM_B_mag1,'YLim',tmp1_yl_dSRM_B)
                set(tmp1_axis_dSRM_B_mag2,'YLim',tmp1_yl_dSRM_B)
                set(tmp1_axis_dSRM_B_mag3,'YLim',tmp1_yl_dSRM_B)
            end
            %         ylim([-0.1 0.4])
            %         if norm_emg
            %             ylim(yl_emg)
            %         end

            % dSRM (Cz)
            plotij(6,3,5,yy)
            plot(atime,agonist,'k','LineWidth',1); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_Cz,'b','LineWidth',1);

            VAF = fitTotal_ag_dual_Cz(2); %rsqr_uncentered(ag',eTotalRecon_ag');
            R2 = fitTotal_ag_dual_Cz(1); %rsqr(ag',eTotalRecon_ag');
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            title([VAFstr ' ' R2str])
            ylabel('dSRM (Cz)')
            xlabel('Time (s)')
            if yy == 1
                tmp1_axis_dSRM_Cz_mag1 = gca;
                tmp1_yl_dSRM_Cz_mag1 = tmp1_axis_dSRM_Cz_mag1.YLim;
            elseif yy == 2
                tmp1_axis_dSRM_Cz_mag2 = gca;
                tmp1_yl_dSRM_Cz_mag2 = tmp1_axis_dSRM_Cz_mag2.YLim;
            elseif yy == 3
                tmp1_axis_dSRM_Cz_mag3 = gca;
                tmp1_yl_dSRM_Cz_mag3 = tmp1_axis_dSRM_Cz_mag3.YLim;

                tmp1_yl_dSRM_Cz = [tmp1_yl_dSRM_Cz_mag1; tmp1_yl_dSRM_Cz_mag2; tmp1_yl_dSRM_Cz_mag3];
                tmp1_yl_dSRM_Cz = [min(tmp1_yl_dSRM_Cz(:)) max(tmp1_yl_dSRM_Cz(:))];
                set(tmp1_axis_dSRM_Cz_mag1,'YLim',tmp1_yl_dSRM_Cz)
                set(tmp1_axis_dSRM_Cz_mag2,'YLim',tmp1_yl_dSRM_Cz)
                set(tmp1_axis_dSRM_Cz_mag3,'YLim',tmp1_yl_dSRM_Cz)
            end


            % dSRM (CoM)
            plotij(6,3,6,yy)
            plot(atime,agonist,'k','LineWidth',1); hold on
            plot(atime(ind_time),eTotalRecon_ag_dual_CoM,'b','LineWidth',1);

            VAF = fitTotal_ag_dual_CoM(2); %rsqr_uncentered(ag',eTotalRecon_ag');
            R2 = fitTotal_ag_dual_CoM(1); %rsqr(ag',eTotalRecon_ag');
            VAFstr = ['VAF = ' sprintf('%0.2f',VAF)];
            R2str = ['R^{2} = ' sprintf('%0.2f',R2)];
            title([VAFstr ' ' R2str])
            ylabel('dSRM (CoM)')
            xlabel('Time (s)')
            if yy == 1
                tmp1_axis_dSRM_CoM_mag1 = gca;
                tmp1_yl_dSRM_CoM_mag1 = tmp1_axis_dSRM_CoM_mag1.YLim;
            elseif yy == 2
                tmp1_axis_dSRM_CoM_mag2 = gca;
                tmp1_yl_dSRM_CoM_mag2 = tmp1_axis_dSRM_CoM_mag2.YLim;
            elseif yy == 3
                tmp1_axis_dSRM_CoM_mag3 = gca;
                tmp1_yl_dSRM_CoM_mag3 = tmp1_axis_dSRM_CoM_mag3.YLim;

                tmp1_yl_dSRM_CoM = [tmp1_yl_dSRM_CoM_mag1; tmp1_yl_dSRM_CoM_mag2; tmp1_yl_dSRM_CoM_mag3];
                tmp1_yl_dSRM_CoM = [min(tmp1_yl_dSRM_CoM(:)) max(tmp1_yl_dSRM_CoM(:))];
                set(tmp1_axis_dSRM_CoM_mag1,'YLim',tmp1_yl_dSRM_CoM)
                set(tmp1_axis_dSRM_CoM_mag2,'YLim',tmp1_yl_dSRM_CoM)
                set(tmp1_axis_dSRM_CoM_mag3,'YLim',tmp1_yl_dSRM_CoM)
            end

            %title
            sgtitle([subjID + " direc" + num2str(direction)])

            %% Put SRM Outputs into DataAvTable
            DataAvTable.Ag_Gains(ind_cond,:) = x_ag;
            DataAvTable.Antag_Gains(ind_cond,:) = xTotal_an;
            DataAvTable.Beta_Gains(ind_cond,:) = x_eeg_beta;
            DataAvTable.BetaRecon(ind_cond,:) = eegRecon_beta;
            DataAvTable.AgonistRecon(ind_cond,:) = eRecon_ag;
            DataAvTable.AntagonistRecon(ind_cond,:) = eTotalRecon_antag;
            DataAvTable.fit_beta(ind_cond,:) = fit_eeg_beta;
            DataAvTable.fit_agonist(ind_cond,:) = fit_ag;
            DataAvTable.fit_antagonist(ind_cond,:) = fitTotal_an;

            DataAvTable.Cz_Gains(ind_cond,:) = x_eeg_Cz;
            DataAvTable.CzRecon(ind_cond,:) = eegRecon_Cz;
            DataAvTable.fit_Cz(ind_cond,:) = fit_eeg_Cz;

            %DualSRM outputs (beta predictor)
            DataAvTable.Ag_Gains_Dual_beta(ind_cond,:) = x_ag_dual;
            DataAvTable.Ag_Gains_TotalDual_beta(ind_cond,:) = xTotal_ag_dual_beta;
            DataAvTable.AgonistRecon_Dual_beta(ind_cond,:) = eRecon_ag_dual;
            DataAvTable.AgonistRecon_TotalDual_beta(ind_cond,:) = eTotalRecon_ag_dual_beta;
            DataAvTable.fit_agonist_Dual_beta(ind_cond,:) = fit_ag_dual;
            DataAvTable.fit_agonist_TotalDual_beta(ind_cond,:) = fitTotal_ag_dual_beta;

            %ResidualSRM outputs (Beta)
            DataAvTable.Residual(ind_cond,:) = residual;
            DataAvTable.Residual_Gains_beta(ind_cond,:) = x_residual_beta;
            DataAvTable.ResidualRecon_beta(ind_cond,:) = eRecon_residual_beta;
            DataAvTable.fit_residual_beta(ind_cond,:) = fit_residual_beta;

            %DualSRM outputs (Cz predictor)
            DataAvTable.Ag_Gains_TotalDual_Cz(ind_cond,:) = xTotal_ag_dual_Cz;
            DataAvTable.AgonistRecon_TotalDual_Cz(ind_cond,:) = eTotalRecon_ag_dual_Cz;
            DataAvTable.fit_agonist_TotalDual_Cz(ind_cond,:) = fitTotal_ag_dual_Cz;

            %ResidualSRM outputs (Cz)
            DataAvTable.Residual_Gains_Cz(ind_cond,:) = x_residual_Cz;
            DataAvTable.ResidualRecon_Cz(ind_cond,:) = eRecon_residual_Cz;
            DataAvTable.fit_residual_Cz(ind_cond,:) = fit_residual_Cz;

            %DualSRM outputs (Cz CoM)
            DataAvTable.Ag_Gains_TotalDual_CoM(ind_cond,:) = xTotal_ag_dual_CoM;
            DataAvTable.AgonistRecon_TotalDual_CoM(ind_cond,:) = eTotalRecon_ag_dual_CoM;
            DataAvTable.fit_agonist_TotalDual_CoM(ind_cond,:) = fitTotal_ag_dual_CoM;

            %ResidualSRM outputs (CoM)
            DataAvTable.Residual_Gains_CoM(ind_cond,:) = x_residual_CoM;
            DataAvTable.ResidualRecon_CoM(ind_cond,:) = eRecon_residual_CoM;
            DataAvTable.fit_residual_CoM(ind_cond,:) = fit_residual_CoM;


            %% Save SRM Figures
            if savefigopt & ~loopbreak
                % SRM Recon vs Raw data
                saveas(fig_SRMRecon, [figdir + subjID + '_SRMRecon_direc' + num2str(direction) + '.fig'],'fig')
                saveas(fig_SRMRecon, [figdir + subjID + '_SRMRecon_direc' + num2str(direction) + '.jpg'],'jpg')
                % SRM Components
                saveas(fig_SRMReconComponents_1,[figdir + subjID + '_SRMReconComps_direc' + num2str(direction) + '.fig'],'fig')
                saveas(fig_SRMReconComponents_1,[figdir + subjID + '_SRMReconComps_direc' + num2str(direction) + '.jpg'],'jpg')

                saveas(fig_SRMReconComponents_2,[figdir + subjID + '_SRMReconComps_dSRMs_direc' + num2str(direction) + '.fig'],'fig')
                saveas(fig_SRMReconComponents_2,[figdir + subjID + '_SRMReconComps_dSRMs_direc' + num2str(direction) + '.jpg'],'jpg')
            end
        end % direction loop
        if ~loopbreak
            close all
        end
    end % Participant loop
end
%% Save output
if saveopt
    ExcelTable = DataAvTable;

    %Remove timeseries data to save for statistics
    ind_delete = [];
    for i = 1:width(ExcelTable)
        tempVar = table2array(ExcelTable(1,i));
        if length(tempVar) > 10
            ind_delete = [ind_delete i]; % index for columns that are time series data
        end
    end


    writetable(ExcelTable,[pwd '\HOA_PD_SRM_Output_StatsTable_' date '.xlsx'])
    save(['HOA_PD_SRM_Outputs_' date '.mat'], 'DataAvTable','DataTable','ExcelTable')
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
if strcmp(subjID,'step05') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.110];
    UB = [15.0 0.04 0.04 0.120];
    LB = [ 0.0 0.00 0.00 0.090];
elseif strcmp(subjID,'step08') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.120];
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.090];
elseif strcmp(subjID,'step10') & magnitude == 3
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
