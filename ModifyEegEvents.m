%% Script to modify EEG.event structure to reflect trial conditions rather than trial number for easy epoching
close all; clear 
% create file list to be loaded
fdir = 'X:\\ting\\shared_ting\\Scott\\HOA_PD EEG Data'; % folder path that contains preprocessed EEG data
figdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\savedfigs\ERSP Plots\'; % folder path where figrues will be saved
saveopt = false;
files = dir(fullfile(fdir, '*.set'));
% initialize eeglab
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

