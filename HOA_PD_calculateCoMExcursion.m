%Script to calculate CoM excursion
clear; close all;
load('X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs__24-Apr-2024_wAnalysis.mat')
CoM_Excursion = nan(size(dataAv,1),1);
CoM_Excursion_time = CoM_Excursion;
for i = 1:size(dataAv,1)
    [CoM_Excursion_tmp, CoM_Excursion_time_tmp] = calculateCoMExcursion(dataAv.COMPosminusLVDT_Y(i,:),dataAv.atime(i,:),dataAv.pertdir_calc_round_deg(i));
    CoM_Excursion(i) = CoM_Excursion_tmp;
    CoM_Excursion_time(i) = CoM_Excursion_time_tmp;
end
% concatinate to end of dataAv
try % check to see if CoM_Excursion is already included in dataAv
    test_already_done = dataAv.CoM_Excursion;
    if exists('test_already_done')
        warning('this dataAv already contains CoM_Excursion values')
    end
catch
    tmp_table = table(CoM_Excursion, CoM_Excursion_time);
    dataAv = [dataAv tmp_table];
    save('X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_Outputs__24-Apr-2024_wAnalysis.mat')
end
%% supporting functions
function [excursion, excursion_time] = calculateCoMExcursion(CoM, time, dir)
% baseline subtract CoM
CoM_baseline = mean(CoM(time<-0.1));
CoM = CoM - CoM_baseline;

% calculate CoM excursion and latency
if dir == 90 % forward pert -- backward deflection of CoM
    [excursion, excursion_time_tmp] = min(CoM);
    excursion_time = time(excursion_time_tmp);
elseif dir == 270 % backward pert -- forward deflection of CoM
    [excursion, excursion_time_tmp] = max(CoM);
    excursion_time = time(excursion_time_tmp);
else 
    error ('perturbation direction not 90 or 270')
end

end