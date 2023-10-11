%% Script to add in EEG output measures to the createfitsdata.m output table
clear; close all
%% Load EEG Data, do time-frequency analysis, put in data table
% user inputs for time frequency analysis
electrode = 13;
winsize = 256;
baseline = [-500 -100]; % NaN for no baseline removal (i.e. can calculate prestim beta); % baseline = [-500 -100];
waveletparams = [3 0.8];
erspmax = 7;
% initialize output variables
Cz = []; beta_ersp = []; gamma_ersp = []; theta_ersp = []; alpha_ersp = [];
time_erp = []; time_ersp = [];
% create file list to be loaded
fdir = 'X:\\ting\\shared_ting\\Scott\\HOA_PD EEG Data'; % folder path that contains preprocessed EEG data
figdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\savedfigs\ERSP Plots\'; % folder path where figrues will be saved
saveopt = false;
files = dir(fullfile(fdir, '*.set'));
% initialize eeglab
addpath('D:\Users\SBOEBIN\Documents\MATLAB\eeglab2021.0\')
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% iterate across all files
for i = 1:size(files,1)
    %% load data
    filename = files(i).name;
    folder = files(i).folder;
    EEG = pop_loadset('filename',filename,'filepath',folder);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, i );
    EEG = eeg_checkset( EEG );
    %% epoch data around conditions
    try
        load(['X:\ting\ting-archive\unpublished\2019_Payne_PD\' filename(1:3) '\' filename(1:5) '\' filename(1:5) 'pertInfo.mat']); clear platonsets trial_starts %for HOA
    catch
        load(['X:\ting\ting-archive\unpublished\2019_Payne_PD\' filename(1:2) '\' filename(1:4) '\' filename(1:4) 'pertInfo.mat']); clear platonsets trial_starts % for PD
    end
    % create condition indexes
    mags = unique(flags(:,2));
    ind_1_90  = find(flags(:,1) == 90  & flags(:,2) == mags(1));
    ind_1_270 = find(flags(:,1) == 270 & flags(:,2) == mags(1));
    ind_2_90  = find(flags(:,1) == 90  & flags(:,2) == mags(2));
    ind_2_270 = find(flags(:,1) == 270 & flags(:,2) == mags(2));
    ind_3_90  = find(flags(:,1) == 90  & flags(:,2) == mags(3));
    ind_3_270 = find(flags(:,1) == 270 & flags(:,2) == mags(3));
    trigs = [{'low'} {'medium'} {'high'}];
    for xx = 1:length(trigs) % for each trial type
        %Epoch data
        tempEEG = pop_epoch(allEEG(i),char(trigs(xx)), [-2  2], 'epochinfo', 'yes'); %pop_epoch(EEG, events, timelimits);
        
        % make time-frequency plots
        figure;
        title_txt = [subj ' ERSP ' trigs{xx} ' magnitude ' Trial_type];
        title({[title_txt]; ['wavelet params [' num2str(waveletparams(1)) ' ' num2str(waveletparams(2)) '] ' num2str(Trial_count) ' trials averaged']})
        % Caclulate event related spectral perturbatoin (ERSP) and
        % inter-trial coherence (ITC)
        % pop_newtimef(Input data, type of processing[raw data or ICA], channel/component #, time range(ms), )
        [ersp, itc, powbase, times, frequencies] = pop_newtimef(tempEEG, 1,...
            electrode, [-1000  1999], waveletparams, 'plotphase', 'off', 'padratio',1,...
            'winsize', winsize, 'baseline',baseline,'erspmax', erspmax); %IF BASELINE NOT SPECIFIED ALL NEGATIVE TIME VALUES ARE USED AS BASELINE
        % 'baseline',NaN,
        % 'winsize', 256
        temp_ersp = [temp_ersp; {ersp}];
        
    end
    
    
    %% perform time-frequency analysis
    figure;
    [ersp, itc, powbase, times, frequencies] = pop_newtimef(EEG, 1, electrode, [-1000  1998], waveletparams,...
        'topovec', electrode, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', [filename ' Cz'],...
        'baseline', baseline,'winsize', winsize, 'plotphase', 'off', 'padratio', 1);
    if saveopt
        saveas(gcf,[figdir filename(1:end-4) '_ERSP.fig'])
        saveas(gcf,[figdir filename(1:end-4) '_ERSP.jpg'])
    end
    
    % calculate output measures
    
    Cz
    close all
end

%% load createfitsData.m output
load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_05-Oct-2023.mat')


