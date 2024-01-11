function [] = HOA_PD_SRM_HandFit(dataAv,participant, direction, ReconName,NewGains)
%HOA_PD_SRM_HANDFIT() to provide hand corrections to SRM reconstruction
%   Load in SRM output data table and plot the old reconstruction as well
%   as reconstruction with gains provided in NewGains.
% Variables: dataAv - SRM output table - Example: load('\\cosmic.bme.emory.edu\labs\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs__06-Dec-2023.mat')
% participant - Participant ID (dataAv.patient)
% SRMType - SRM that will be hand corrected
% NewGains - gains selected for hand correction


%% Add Utilities folders - May give warnings depending on which PC you are using
addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\SRM-Practice\SRMUtilities')
addpath('C:\Users\seboe\OneDrive - Emory University\Documents\Grad School\Neuromechanics Lab\SRM\matlabUtilities-master')
%% index which row of dataAv
ind = find(strcmp(dataAv.patient,participant) & dataAv.pertdir_calc_round_deg == direction & strcmp(ReconName,dataAv.Properties.VariableNames));
%% specify CoM kinematics & Recon time window 
atime = dataAv.atime(ind,:); % Modify CoM acc with stiction model from Welch and Ting 2009
a = dataAv.COMAccel_Y(ind,:);
a = stictionTemplate('a',a,'t',atime);
v = dataAv.COMVelo_Y(ind,:);
d = dataAv.COMPosminusLVDT_Y(ind,:);
% remove basline from CoM kinematics - not needed for "a" due to stiction model
d = d-mean(d(dataAv.atime(1,:)<-0.1));
v = v-mean(v(dataAv.atime(1,:)<-0.1));

% flip the CoM kinematic signal depending on pert direction
if direction == 90 %forward pert
    a_ag = -a; v_ag = -v; d_ag = -d;
    a_antag = a; v_antag = v; d_antag = d;
elseif direction == 270 %backward pert
    a_ag = a; v_ag = v; d_ag = d;
    a_antag = -a; v_antag = -v; d_antag = -d;
end
max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM
%% Specify appropriate neurophysiological data, SRM recon, and gains
if strcmp(ReconName,'Recon_Agonist')
    predictorsmSRM = [a_ag(ind_time); v_ag(ind_time); d_ag(ind_time)];
    old_Recon = dataAv.Recon_Agonist;
    old_Gains = dataAv.Gains_Ag;
    old_fit = dataAv.fit_agonist;

elseif strcmp(ReconName,"Recon_Agonist_TotalDual_CoM")

elseif strcmp(ReconName,"Recon_Agonist_TotalDual_Cz")

elseif strcmp(ReconName,"Recon_Agonist_TotalDual_beta")

elseif strcmp(ReconName,"Recon_Cz")

elseif strcmp(ReconName,"Recon_beta")

elseif strcmp(ReconName,"Recon_Antagonist")

else
    error('Specified SRMType is not in dataAv')
end

