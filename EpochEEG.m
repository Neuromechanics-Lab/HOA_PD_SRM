%% script to epoch EEG data
clear; close all
% set file list
fdir = 'X:\\ting\\shared_ting\\Scott\\HOA_PD EEG Data'; % folder path that contains preprocessed EEG data
files = dir(fullfile([fdir '\\Updated Events'], '*_UpdatedEvents.set'));
% initialize eeglab
addpath('D:\Users\SBOEBIN\Documents\MATLAB\eeglab2021.0\')
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
for i = 1:size(files,1)
    % specify file name for Updated data
    filename = files(i).name;
    folder = files(i).folder;
    % iterate across conditions for epoching
    trigs = string([{'90_1'} {'270_1'} {'90_2'} {'270_2'} {'90_3'} {'270_3'}]);
    for iii = 1:size(trigs,2)
        % load updated data
        EEG = pop_loadset('filename',filename,'filepath',folder);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG);
        EEG = eeg_checkset( EEG );
        % epoch data for each condition
        EEG = eeg_checkset( EEG );
        EEG = pop_epoch( EEG, {  char(trigs(iii))  }, [-1  2], 'newname', [filename(1:end-4) '_' char(trigs(iii))], 'epochinfo', 'yes');
        % save epoched data
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',[fdir '\\Condition Epoched\\' filename(1:end-4) '_' char(trigs(iii)) '.set'],'gui','off');
        EEG = eeg_checkset( EEG );
        1;
    end
end