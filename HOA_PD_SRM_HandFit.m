function [output] = HOA_PD_SRM_HandFit(dataAv, participant, direction, mag, ReconName, New_Gains)
%HOA_PD_SRM_HandFit() to provide hand corrections to SRM reconstruction
%   Load in SRM output data table and plot the old reconstruction as well
%   as reconstruction with gains provided in NewGains.
% Inputs: 1) dataAv - SRM output table (class = table) Example: load('\\cosmic.bme.emory.edu\labs\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs__06-Dec-2023.mat')
% 2) participant - Participant ID (dataAv.patient) (class = char or string)
% Example: participant = "HOA02"
% 3) direction - direction of perturbation (class = double) Example: direction = 90 or 270
% 4) ReconName - Name of SRM that will be hand corrected, must be same name
% the variable name in dataAv(class = string or char) Example: ReconName = "Recon_Agonist"
% NewGains - gains selected for hand correction (class = double)
% Example:NewGains = [10 0 0 0.100] for mSRM
% Outputs: New SRM reconstruction with associated R2 and VAF along with a plot of original SRM reconstruction (from dataAv) and plot of
% new SRM reconstruction based on NewGains specified by the user

%% Add Utilities folders - May give warnings depending on which PC you are using
addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
% addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM-Practice\SRMUtilities')
% addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')
%% index which row of dataAv
ind_row = find(strcmp(dataAv.patient,participant) & dataAv.pertdir_calc_round_deg == direction & dataAv.condition == mag); % participant/condition index
% ind_col = find(strcmp(ReconName,dataAv.Properties.VariableNames)); % Recon index
%% specify CoM kinematics and time window
atime = dataAv.atime(ind_row,:); % Modify CoM acc with stiction model from Welch and Ting 2009
a = dataAv.COMAccel_Y(ind_row,:);
a = stictionTemplate('a',a,'t',atime);
v = dataAv.COMVelo_Y(ind_row,:);
d = dataAv.COMPosminusLVDT_Y(ind_row,:);
% remove basline from CoM kinematics - not needed for "a" due to stiction model
d = d-mean(d(dataAv.atime(1,:)<-0.1));
v = v-mean(v(dataAv.atime(1,:)<-0.1));
% specify time fit by SRM - FROM HOA_PD_SRM.m
max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM

%% flip the CoM kinematic signal depending on pert direction and specify ag/antag EMG
if direction == 90 %forward pert
    a_ag = -a; v_ag = -v; d_ag = -d;
%     a_antag = a; v_antag = v; d_antag = d;
    agonist = dataAv.EMG_TA_L_norm(ind_row,:); tag_ag = 'TA'; %ag_norm = dataAv.EMG_TA_L_norm(ind_row,:);
%     antagonist = dataAv.EMG_MGAS_L_norm(ind_row,:); tag_antag = 'MG'; antag_norm = dataAv.EMG_MGAS_L_norm(ind_row,:);
elseif direction == 270 %backward pert
    a_ag = a; v_ag = v; d_ag = d;
%     a_antag = -a; v_antag = -v; d_antag = -d;
%     antagonist = dataAv.EMG_TA_L_norm(ind_row,:); tag_antag = 'TA'; antag_norm = dataAv.EMG_TA_L_norm(ind_row,:);
    agonist = dataAv.EMG_MGAS_L_norm(ind_row,:); tag_ag = 'MG'; %ag_norm = dataAv.EMG_MGAS_L_norm(ind_row,:);
end
%% specify EEG data
Cz = dataAv.Cz_norm(ind_row,:);
beta = dataAv.beta_ersp_norm(ind_row,:);

%% Specify appropriate neurophysiological data, SRM recon, and gains
if strcmp(ReconName,"Recon_Agonist")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % SRM predictors
    measuredData = agonist(ind_time); % what the SRM is reconstructing
    Old_Recon = dataAv.Recon_Agonist(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Ag(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_agonist(ind_row,:); %SRM reconstruction accuracy
    
    New_Recon = assembleChannel(predictors,New_Gains(1:3),New_Gains(end),atime(ind_time));
    
elseif strcmp(ReconName,"Recon_Agonist_TotalDual_CoM")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time);...
        a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % SRM predictors
    measuredData = agonist(ind_time); % what the SRM is reconstructing
    Old_Recon = dataAv.Recon_Agonist_TotalDual_CoM(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Ag_TotalDual_CoM(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_agonist_TotalDual_CoM(ind_row,:); %SRM reconstruction accuracy
    
    New_Recon = assembleTwoChannels(predictors(1:3,:),New_Gains(1:3),New_Gains(4),...
        predictors(4:6,:),New_Gains(5:7),New_Gains(end),atime(ind_time));

elseif strcmp(ReconName,"Recon_Agonist_TotalDual_Cz")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time); -Cz(ind_time)]; % SRM predictors
    measuredData = agonist(ind_time); % what the SRM is reconstructing
    Old_Recon = dataAv.Recon_Agonist_TotalDual_Cz(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Ag_TotalDual_Cz(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_agonist_TotalDual_Cz(ind_row,:); %SRM reconstruction accuracy

    New_Recon = assembleTwoChannels(predictors(1:3,:),New_Gains(1:3),New_Gains(4),...
        predictors(4,:),New_Gains(5),New_Gains(end),atime(ind_time));

elseif strcmp(ReconName,"Recon_Agonist_TotalDual_beta")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time); beta(ind_time)]; % SRM predictors
    measuredData = agonist(ind_time); % what the SRM is reconstructing
    Old_Recon = dataAv.Recon_Agonist_TotalDual_beta(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Ag_TotalDual_beta(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_agonist_TotalDual_beta(ind_row,:); %SRM reconstruction accuracy
    
    New_Recon = assembleTwoChannels(predictors(1:3,:),New_Gains(1:3),New_Gains(4),...
        predictors(4,:),New_Gains(5),New_Gains(end),atime(ind_time));
    
elseif strcmp(ReconName,"Recon_Cz")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % SRM predictors
    measuredData = -Cz(ind_time); % what the SRM is reconstructing
    Old_Recon = -dataAv.Recon_Cz(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Cz(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_Cz(ind_row,:); %SRM reconstruction accuracy
    
    New_Recon = assembleChannel(predictors,New_Gains(1:3),New_Gains(end),atime(ind_time));
    
elseif strcmp(ReconName,"Recon_beta")
    predictors = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)]; % SRM predictors
    measuredData = beta(ind_time); % what the SRM is reconstructing
    Old_Recon = dataAv.Recon_Beta(ind_row,:); %SRM reconstruction time series
    Old_Gains = dataAv.Gains_Beta(ind_row,:); %SRM reconstruction gains
    Old_fit = dataAv.fit_beta(ind_row,:); %SRM reconstruction accuracy
    
    New_Recon = assembleChannel(predictors,New_Gains(1:3),New_Gains(end),atime(ind_time));
    
    % elseif strcmp(ReconName,"Recon_Antagonist")
    %     predictors = [a_antag(ind_time); v_antag(ind_time); d_antag(ind_time);....
    %         a_antag(ind_time); v_antag(ind_time); d_antag(ind_time)]; % SRM predictors
    %     measuredData = beta(ind_time); % what the SRM is reconstructing
    %     old_Recon = dataAv.Recon_Beta(ind_row,:); %SRM reconstruction time series
    %     Old_Gains = dataAv.Gains_Beta(ind_row,:); %SRM reconstruction gains
    %     old_fit = dataAv.fit_beta(ind_row,:); %SRM reconstruction accuracy
    
else
    error('Specified SRMType is not in dataAv')
end
%% Calculate R2 and VAF for new fit
New_fit = [NaN NaN];
New_fit(1) = rsqr(measuredData',New_Recon');
New_fit(2) = rsqr_uncentered(measuredData',New_Recon');
output = table(participant, direction, mag, ReconName, New_Gains, New_fit, New_Recon, Old_Gains, Old_Recon);
%% plot Old and New SRM Recons
backLev = mean(measuredData(atime(ind_time) < -0.1),'omitnan');
title_string = {participant + " Mag: " + string(mag) + " direc: " + string(direction) + " " + ReconName};
figure; set(gcf,'WindowStyle','docked')
%% Old Recon
plotij(2,1,1,1); hold on
plot(atime(ind_time),measuredData,'b','LineWidth',2) % raw data
plot(atime(ind_time),Old_Recon,'m','LineWidth',2) % Reconstruction
if strcmp(ReconName,"Recon_Agonist") || strcmp(ReconName,"Recon_beta") || strcmp(ReconName,"Recon_Cz") % for SRMs w/ only 3 predictors
    plot(atime(ind_time) + Old_Gains(4),...
        predictors(1,:)*Old_Gains(1)+backLev,...
        'g-','LineWidth',1.2) % CoM Acc Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(2,:)*Old_Gains(2)+backLev,...
        'g-','LineWidth',0.5) % CoM Vel Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(3,:)*Old_Gains(3)+backLev,...
        'g--','LineWidth',0.5) % CoM Disp component
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',Old_Gains(1)), sprintf('k_{v1}=%1.2g',Old_Gains(2)), sprintf('k_{d1}=%1.2g',Old_Gains(3)),'Interpreter','none');
    ylabel([tag_ag ' EMG']); xlabel('Time (s)');
elseif strcmp(ReconName,"Recon_Agonist_TotalDual_CoM") % for SRMs w/ 6 predictors
    plot(atime(ind_time) + Old_Gains(4),...
        predictors(1,:)*Old_Gains(1)+backLev,...
        'g-','LineWidth',1.2) % CoM Acc Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(2,:)*Old_Gains(2)+backLev,...
        'g.','LineWidth',0.4) % CoM Vel Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(3,:)*Old_Gains(3)+backLev,...
        'g--','LineWidth',0.5) % CoM Disp component
    plot(atime(ind_time)+Old_Gains(end),...
        predictors(4,:)*Old_Gains(5)+backLev,...
        'g-','LineWidth',1.2) % CoM Acc - ctx
    plot(atime(ind_time)+Old_Gains(end),...
        predictors(5,:)*Old_Gains(6)+backLev,...
        'g.','LineWidth',0.5) % CoM Vel - ctx
    plot(atime(ind_time)+Old_Gains(end),...
        predictors(6,:)*Old_Gains(7)+backLev,...
        'g--','LineWidth',0.5)% CoM Disp - ctx
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',Old_Gains(1)), sprintf('k_{v1}=%1.2g',Old_Gains(2)), sprintf('k_{d1}=%1.2g',Old_Gains(3)),...
        sprintf('k_{a2}=%1.2g',Old_Gains(5)), sprintf('k_{v2}=%1.2g',Old_Gains(6)), sprintf('k_{d2}=%1.2g',Old_Gains(7)),'Interpreter','none');
    ylabel([tag_ag ' EMG']); xlabel('Time (s)');
elseif strcmp(ReconName,"Recon_Agonist_TotalDual_Cz") || strcmp(ReconName,"Recon_Agonist_TotalDual_beta")
    plot(atime(ind_time) + Old_Gains(4),...
        predictors(1,:)*Old_Gains(1)+backLev,...
        'g-','LineWidth',1.2) % CoM Acc Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(2,:)*Old_Gains(2)+backLev,...
        'g.','LineWidth',0.5) % CoM Vel Component
    plot(atime(ind_time)+Old_Gains(4),...
        predictors(3,:)*Old_Gains(3)+backLev,...
        'g--','LineWidth',0.5) % CoM Disp component
    plot(atime(ind_time)+Old_Gains(end),...
        predictors(4,:)*Old_Gains(5)+backLev,...
        'r-','LineWidth',1) % Ctx component
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',Old_Gains(1)), sprintf('k_{v1}=%1.2g',Old_Gains(2)), sprintf('k_{d1}=%1.2g',Old_Gains(3)),...
        sprintf('k_{Ctx}=%1.2g',Old_Gains(5)),'Interpreter','none')
    ylabel(ReconName); xlabel('Time (s)');
end
title("Original Reconstruction" + " R2 = " + num2str(round(Old_fit(1),2)) + " VAF = " + num2str(round(Old_fit(2),2)))
% xlim([-0.2 1.4]); ylim([-1 1])

%% New Recon
plotij(2,1,2,1); hold on
plot(atime(ind_time),measuredData,'b','LineWidth',2) % raw data
plot(atime(ind_time),New_Recon+backLev,'m','LineWidth',2) % Reconstruction
if strcmp(ReconName,"Recon_Agonist") || strcmp(ReconName,"Recon_beta") || strcmp(ReconName,"Recon_Cz") % for SRMs w/ only 3 predictors
    plot(atime(ind_time) + New_Gains(4),...
        predictors(1,:)*New_Gains(1)+backLev,...
        'g-','LineWidth',1) % CoM Acc Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(2,:)*New_Gains(2)+backLev,...
        'g.','LineWidth',1) % CoM Vel Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(3,:)*New_Gains(3)+backLev,...
        'g--','LineWidth',1) % CoM Disp component
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',New_Gains(1)), sprintf('k_{v1}=%1.2g',New_Gains(2)), sprintf('k_{d1}=%1.2g',New_Gains(3)),'Interpreter','none');
    ylabel([tag_ag ' EMG']); xlabel('Time (s)');
elseif strcmp(ReconName,"Recon_Agonist_TotalDual_CoM") % for SRMs w/ 6 predictors
    plot(atime(ind_time) + New_Gains(4),...
        predictors(1,:)*New_Gains(1)+backLev,...
        'g-','LineWidth',1) % CoM Acc Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(2,:)*New_Gains(2)+backLev,...
        'g.','LineWidth',1) % CoM Vel Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(3,:)*New_Gains(3)+backLev,...
        'g--','LineWidth',1) % CoM Disp component
    plot(atime(ind_time)+New_Gains(end),...
        predictors(4,:)*New_Gains(5)+backLev,...
        'g-','LineWidth',1) % CoM Acc - ctx
    plot(atime(ind_time)+New_Gains(end),...
        predictors(5,:)*New_Gains(6)+backLev,...
        'g.','LineWidth',1) % CoM Vel - ctx
    plot(atime(ind_time)+New_Gains(end),...
        predictors(6,:)*New_Gains(7)+backLev,...
        'g--','LineWidth',1)% CoM Disp - ctx
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',New_Gains(1)), sprintf('k_{v1}=%1.2g',New_Gains(2)), sprintf('k_{d1}=%1.2g',New_Gains(3)),...
        sprintf('k_{a2}=%1.2g',New_Gains(5)), sprintf('k_{v2}=%1.2g',New_Gains(6)), sprintf('k_{d2}=%1.2g',New_Gains(7)),'Interpreter','none');
    ylabel([tag_ag ' EMG']); xlabel('Time (s)');
elseif strcmp(ReconName,"Recon_Agonist_TotalDual_Cz") || strcmp(ReconName,"Recon_Agonist_TotalDual_beta")
    plot(atime(ind_time) + New_Gains(4),...
        predictors(1,:)*New_Gains(1)+backLev,...
        'g-','LineWidth',1) % CoM Acc Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(2,:)*New_Gains(2)+backLev,...
        'g.','LineWidth',1) % CoM Vel Component
    plot(atime(ind_time)+New_Gains(4),...
        predictors(3,:)*New_Gains(3)+backLev,...
        'g--','LineWidth',1) % CoM Disp component
    plot(atime(ind_time)+New_Gains(end),...
        predictors(4,:)*New_Gains(5)+backLev,...
        'r-','LineWidth',1) % Cz component
    legend('Data',ReconName,...
        sprintf('k_{a1}=%1.2g',New_Gains(1)), sprintf('k_{v1}=%1.2g',New_Gains(2)), sprintf('k_{d1}=%1.2g',New_Gains(3)),...
        sprintf('k_{Ctx}=%1.2g',New_Gains(5)))
    ylabel(ReconName); xlabel('Time (s)');
end
title("New Reconstruction" + " R2 = " + num2str(round(New_fit(1),2)) + " VAF = " + num2str(round(New_fit(2),2)))
sgtitle(title_string,'Interpreter','none')

