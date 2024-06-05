function Plot_SRM_methods_fig(dataAv, varargin)
p = inputParser;
addOptional(p,'savefigopt',true); % option to save figures
addOptional(p,'closeopt',true); %option to close all figures after the participant loop
addOptional(p,'AnalysisType',''); % additional descriptor to be added to file name
addOptional(p,'figdir',"\\eu.emory.edu\bme\labs\ting\shared_ting\Scott\HOA_PD SRM\savedfigs\") % where to save the data
p.KeepUnmatched = true;
parse(p,varargin{:});

% addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')

%% plot data
% plot list - mSRM/hSRM comparisons (1 per direction & mag), Recon vs Data
% comparison (1 per direction), SRM components, (1 per direction
% participants = unique(dataAv.patient);
participants = "HOA05";
direcs = unique(dataAv.pertdir_calc_round_deg);
try
    mags = unique(dataAv.pert_mag);
catch
    mags =  unique(dataAv.condition);
end

for i = 1:length(participants) %participant loop
    participant = participants(i);
    
    % plot figure
    figure; set(gcf,'WindowState','maximized')
    % Cz
    subplot(7,1,1)
    try % data table may not contain Cz
        plot(dataAv.atime(1,:),dataAv.Cz(strcmp(dataAv.patient,"HOA05"),:))
        title('Cz'); ylabel('micro V')
    catch
        text(0.2, 0.2,'no Cz variable in provided table')
        title('Cz'); ylabel('micro V')
    end
    % TA EMG
    subplot(7,1,2)
    plot(dataAv.atime(1,:),dataAv.EMG_TA_L_norm(strcmp(dataAv.patient,"HOA05"),:))
    title('TA EMG'); ylabel('nu')
    % MG EMG
    subplot(7,1,3)
    plot(dataAv.atime(1,:),dataAv.EMG_MGAS_L_norm(strcmp(dataAv.patient,"HOA05"),:))
    title('MG EMG'); ylabel('nu')
    % CoM Acc
    subplot(7,1,4)
    plot(dataAv.atime(1,:),dataAv.COMAccel_Y(strcmp(dataAv.patient,"HOA05"),:))
    title('CoM Acc'); ylabel('g (?)')
    % CoM Vel
    subplot(7,1,5)
    plot(dataAv.atime(1,:),dataAv.COMVelo_Y(strcmp(dataAv.patient,"HOA05"),:))
    title('CoM Vel'); ylabel('cm/s')
    % CoM Disp
    subplot(7,1,6)
    plot(dataAv.atime(1,:),dataAv.COMPosminusLVDT_Y(strcmp(dataAv.patient,"HOA05"),:))
    title('CoM Disp'); ylabel('cm')
    % Pert Acc - NOT CURRENTLY IN dataAv
    
    % Pert Vel - NOT CURRENTLY IN dataAv
    
    % Pert Disp 
    subplot(7,1,7)
    plot(dataAv.atime(1,:),dataAv.LVDT_Y(strcmp(dataAv.patient,"HOA05"),:))
    title('Pert Disp'); ylabel('cm'); xlabel('time (s)')
    legend('90 - 5','90 - 7.5','90 - 10','270 - 5','270 - 7.5', '270 - 10')
    
    set(gcf,'WindowState','maximized','renderer','painters')
    if p.Results.savefigopt
        print(gcf,'-depsc2',[p.Results.figdir + participant + "_Methods_Fig.eps"]) 
    end
end