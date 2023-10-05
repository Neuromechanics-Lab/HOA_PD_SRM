%% Script to plot SRM Outputs
close all; clear
fdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\';
load([fdir 'HOA_PD_SRM_Outputs_05-Oct-2023.mat'])
addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')


savefigopt = true;
figdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\savedfigs\';
%% plot data
% plot list - mSRM/hSRM comparisons (1 per direction & mag), Recon vs Data
% comparison (1 per direction), SRM components, (1 per direction
participants = unique(dataAv.patient);
direcs = unique(dataAv.pertdir_calc_round_deg);
mags = unique(dataAv.condition); mags(end) = [];

max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM

for i = 1:length(participants) %participant loop
    participant = participants(i);
    for ii = 1:length(direcs)
        direc = direcs(ii);
        for iii = 1:length(mags)
            mag = mags(iii);
            
            ind_cond = find(strcmp(dataAv.patient,participant) & dataAv.pertdir_calc_round_deg == direc & dataAv.condition == mag);
            
            %specify which muscle is acting as an agonist/antagonist
            if direc == 90 %forward pert
                agonist = dataAv.EMG_TA_L(ind_cond,:); tag_ag='TA'; ag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                antagonist = dataAv.EMG_MGAS_L(ind_cond,:); tag_antag='MG'; antag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
            elseif direc == 270 %backward pert
                antagonist = dataAv.EMG_TA_L(ind_cond,:); tag_antag='TA'; antag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                agonist = dataAv.EMG_MGAS_L(ind_cond,:); tag_ag='MG'; ag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
            else
                error('Unspecified Direction')
            end
            
            % specify CoM kinematics
            atime = dataAv.atime(ind_cond,:); % Modify CoM acc with stiction model from Welch and Ting 2009
            a = dataAv.COMAccel_Y(ind_cond,:);
            a = stictionTemplate('a',a,'t',atime);
            v = dataAv.COMVelo_Y(ind_cond,:);
            d = dataAv.COMPosminusLVDT_Y(ind_cond,:);
            
            % remove basline from CoM kinematics - not needed for a due to stiction model
            d = d-mean(d(dataAv.atime(1,:)<-0.1));
            v = v-mean(v(dataAv.atime(1,:)<-0.1));
            
            % flip the CoM kinematic signal depending on pert direction
            if direc == 90 %forward pert
                a_ag = -a; v_ag = -v; d_ag = -d;
                a_antag = a; v_antag = v; d_antag = d;
            elseif direc == 270 %backward pert
                a_ag = a; v_ag = v; d_ag = d;
                a_antag = -a; v_antag = -v; d_antag = -d;
            end
            %% plot mSRM hSRM comparisons
            
            yl = [0 0.5];
            figure(iii+direc+1000); set(gcf,'WindowState','maximized');
            %mSRM
            ax1 = plotij(2,2,1,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.AgonistRecon(ind_cond,:),'g','LineWidth',2)
            title({['mSRM']...
                [sprintf('ka=%1.2g', dataAv.Ag_Gains(1)) ' ' sprintf('kv=%1.2g',dataAv.Ag_Gains(2)) ' ' sprintf('kd=%1.2g',dataAv.Ag_Gains(3))]})
            legend('Data','mSRM'); ylabel([tag_ag ' EMG']);
            text(-0.4,0.5,sprintf('R^{2} = %1.2g',dataAv.fit_agonist(1)))
            text(-0.4,0.3,sprintf('VAF = %1.2g',dataAv.fit_agonist(2)))
            %hSRM
            ax2 = plotij(2,2,2,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.AgonistRecon_TotalDual_CoM(ind_cond,:),'m','LineWidth',2)
            title({['hSRM - CoM']...
                [sprintf('ka1=%1.2g', dataAv.Ag_Gains_TotalDual_CoM(1)) ' ' sprintf('kv1=%1.2g',dataAv.Ag_Gains_TotalDual_CoM(2))...
                ' ' sprintf('kd1=%1.2g',dataAv.Ag_Gains_TotalDual_CoM(3)) ' ' sprintf('ka2=%1.2g',dataAv.Ag_Gains_TotalDual_CoM(5))...
                ' ' sprintf('kv1=%1.2g',dataAv.Ag_Gains_TotalDual_CoM(6)) ' ' sprintf('kd2=%1.2g',dataAv.Ag_Gains_TotalDual_CoM(7))]})
            legend('Data','hSRM (CoM)'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            text(-0.4,0.5,sprintf('R^{2} = %1.2g',dataAv.fit_agonist_TotalDual_CoM(1)))
            text(-0.4,0.3,sprintf('VAF = %1.2g',dataAv.fit_agonist_TotalDual_CoM(2)))
            % all on same plot
            ax_all = plotij(1,2,1,2); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.AgonistRecon(ind_cond,:),'g','LineWidth',2)
            plot(atime(ind_time),dataAv.AgonistRecon_TotalDual_CoM(ind_cond,:),'m','LineWidth',2)
            title('All SRMs'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            %             legend('Data','mSRM','dSRM (beta)','dSRM (Cz)','dSRM (CoM')
            legend('Data','mSRM','hSRM (CoM')
            sgtitle([participant + ' Mag' + num2str(mag) + " direc" + num2str(direc)])
            
            %Set ylim to be the same between plots
            %             ylims = [ax1.YLim ax2.YLim ax3.YLim ax4.YLim];
            ylims = [ax1.YLim ax2.YLim];
            yl = max(ylims); yl = [0 yl];
            set(ax1,'YLim',yl)
            set(ax2,'YLim',yl)
            set(ax_all,'YLim',yl)
            
            if savefigopt
                saveas(gcf,[figdir + participant + '_DualSRMCompare_mag' + num2str(mag) + '_direc' + num2str(direc) + '.fig'],'fig')
                saveas(gcf,[figdir + participant + '_DualSRMCompare_mag' + num2str(mag) + '_direc' + num2str(direc) + '.jpg'],'jpg')
            end
            
        end
        
        
    end
    
end
