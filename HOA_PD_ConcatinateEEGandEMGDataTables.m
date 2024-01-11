% Script to concatinate EEG and EMG data tables for HOA and PD cohorts
close all; clear
% Load data
load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_04-Oct-2023.mat') % EMG
load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTable_EEG_18-Oct-2023.mat') % EEG

%% remove magnitudes that are not shared between participants
dataAv = dataAv(dataAv.condition ~= 12, :);
% Find common participant identifiers and filter data tables
commonParticipants = intersect(dataAv.patient, T.ID);
dataAv = dataAv(ismember(dataAv.patient, commonParticipants), :);
dataSD = dataSD(ismember(dataSD.patient, commonParticipants), :);
data = data(ismember(data.patient, commonParticipants), :);
T = T(ismember(T.ID, commonParticipants), :);

%% reorganize T to have perturbation direcition in the same order.
% Mapping for direction and magnitude identifiers
directionMapping = containers.Map({90, 270}, {90, 270});
magnitudeMapping = containers.Map({5, 7.5, 10}, {1, 2, 3});

% Map direction and magnitude identifiers in dataAv
dataAvDirectionMapped = cellfun(@(x) directionMapping(x), num2cell(dataAv.pertdir_calc_round_deg));
dataAvMagnitudeMapped = cellfun(@(x) magnitudeMapping(x), num2cell(dataAv.condition));

% Create an index for the order of dataAv
dataAvIndex = zeros(height(dataAv), 1);
for i = 1:height(dataAv)
    currentParticipant = dataAv.patient{i};
    currentMagnitude = dataAv.condition(i);
    if currentMagnitude == 5
        currentMagnitude = 1;
    elseif currentMagnitude == 7.5
        currentMagnitude = 2;
    elseif currentMagnitude == 10
        currentMagnitude = 3;
    end
    currentDirection = dataAv.pertdir_calc_round_deg(i);
    
    % Find the index in T for the current row in dataAv
    dataAvIndex(i) = find(strcmp(currentParticipant, T.ID) & ...
                          currentMagnitude == T.mag & ...
                          currentDirection == T.direc, 1, 'first');
end

% Reorganize T based on the index
T = T(dataAvIndex, :);
%% Append data tables together
dataAv = [dataAv, T];
%% save
save(['D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_Concatinated_' date '.mat'],...
    'dataAv', 'dataSD','data','participants','-v7.3')