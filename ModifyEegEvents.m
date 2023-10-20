%% Script to modify EEG.event structure to reflect trial conditions rather than trial number for easy epoching
close all; clear
% initialize eeglab
addpath('D:\Users\SBOEBIN\Documents\MATLAB\eeglab2021.0\')
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% create file list to be loaded
fdir = 'X:\\ting\\shared_ting\\Scott\\HOA_PD EEG Data'; % folder path that contains preprocessed EEG data
files = dir(fullfile(fdir, '*above70.set'));
files(1:end-3,:) = []; % for single participant debugging
%% update the EEG.event.type to reflect trial conditions for epoching
for i = 1:size(files,1)
    % load EEG data
    filename = files(i).name;
    folder = files(i).folder;
    EEG = pop_loadset('filename',filename,'filepath',folder);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG);
    EEG = eeg_checkset( EEG );
    % load perturbation info
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
    trigs = string([{'90_1'} {'270_1'} {'90_2'} {'270_2'} {'90_3'} {'270_3'}]);
    
    % iterate across every row of EEG.event to modify it to trial condition
    for ii = 1:size(EEG.event,2)
        if strcmp(filename,'PD20_brain_above70.set') || strcmp(filename,'PD21_brain_above70.set')
            try % there is a possibility that EEG.event(ii).type is 'S 15' which cannot be converted to a double
                if any(ind_1_90 == EEG.event(ii).epoch) % see if EEG.event(ii).type is included in condition indexes
                    EEG.event(ii).type = trigs(1);
                elseif any(ind_2_90 == EEG.event(ii).epoch)
                    EEG.event(ii).type = trigs(3);
                elseif any(ind_3_90 == EEG.event(ii).epoch)
                    EEG.event(ii).type = trigs(5);
                elseif any(ind_1_270 == EEG.event(ii).epoch)
                    EEG.event(ii).type = trigs(2);
                elseif any(ind_2_270 == EEG.event(ii).epoch)
                    EEG.event(ii).type = trigs(4);
                elseif any(ind_3_270 == EEG.event(ii).epoch)
                    EEG.event(ii).type = trigs(6);
                end
            catch % if EEG.event(ii).type is 'S 15' then remove that row from EEG.event
                EEG.event(ii) = [];
            end
        else
            try % there is a possibility that EEG.event(ii).type is 'S 15' which cannot be converted to a double
                if any(ind_1_90 == str2double(EEG.event(ii).type)) % see if EEG.event(ii).type is included in condition indexes
                    EEG.event(ii).type = trigs(1);
                elseif any(ind_2_90 == str2double(EEG.event(ii).type))
                    EEG.event(ii).type = trigs(3);
                elseif any(ind_3_90 == str2double(EEG.event(ii).type))
                    EEG.event(ii).type = trigs(5);
                elseif any(ind_1_270 == str2double(EEG.event(ii).type))
                    EEG.event(ii).type = trigs(2);
                elseif any(ind_2_270 == str2double(EEG.event(ii).type))
                    EEG.event(ii).type = trigs(4);
                elseif any(ind_3_270 == str2double(EEG.event(ii).type))
                    EEG.event(ii).type = trigs(6);
                end
            catch % if EEG.event(ii).type is 'S 15' then remove that row from EEG.event
                EEG.event(ii) = [];
            end
        end
    end
    % save updated data
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',[fdir '\\Updated Events\\' filename(1:end-4) '_UpdatedEvents.set'],'gui','off');
    EEG = eeg_checkset( EEG );
end