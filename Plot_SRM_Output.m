%% Script to plot SRM Outputs
close all; clear
fdir = 'D:\Users\SBOEBIN\Documents\MATLAB\HOA_PD_SRM_Output\';
load([fdir 'HOA_PD_SRM_Outputs_18-Oct-2023.mat'])
addpath('D:\Users\SBOEBIN\Documents\MATLAB\SRMUtilities')
addpath('D:\Users\SBOEBIN\Documents\MATLAB\matlabUtilities-master')

savefigopt = true;
figdir = 'X:\ting\shared_ting\Scott\HOA_PD SRM\savedfigs\';
%% plot data
% plot list - mSRM/hSRM comparisons (1 per direction & mag), Recon vs Data
% comparison (1 per direction), SRM components, (1 per direction
participants = unique(dataAv.patient);
direcs = unique(dataAv.pertdir_calc_round_deg);
mags = unique(dataAv.pert_mag); mags(end) = [];

max_time = 1.2;
min_time = -0.2;
ind_time = find(dataAv.atime(1,:) > min_time & dataAv.atime(1,:) <= max_time); % adjust window that will be fit by the SRM

for i = 1:length(participants) %participant loop
    participant = participants(i);
    for ii = 1:length(direcs)
        direc = direcs(ii);
        for iii = 1:length(mags)
            mag = mags(iii);
            ind_cond = find(strcmp(dataAv.patient,participant) & dataAv.pertdir_calc_round_deg == direc & dataAv.pert_mag == mag);
            
            %specify which muscle is acting as an agonist/antagonist
            if direc == 90 %forward pert
                agonist = dataAv.EMG_TA_L_norm(ind_cond,:); tag_ag='TA'; ag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                antagonist = dataAv.EMG_MGAS_L_norm(ind_cond,:); tag_antag='MG'; antag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
            elseif direc == 270 %backward pert
                antagonist = dataAv.EMG_TA_L_norm(ind_cond,:); tag_antag='TA'; antag_norm = dataAv.EMG_TA_L_norm(ind_cond,:);
                agonist = dataAv.EMG_MGAS_L_norm(ind_cond,:); tag_ag='MG'; ag_norm = dataAv.EMG_MGAS_L_norm(ind_cond,:);
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
            yl = [0 1];
            figure(i + iii + direc + 1000); set(gcf,'WindowState','maximized');
            %mSRM
            ax1 = plotij(4,2,1,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist(ind_cond,:),'r','LineWidth',2)
            title_string = {['mSRM']...
                [sprintf('k_{a}=%1.2g', dataAv.Gains_Ag(1)) ' ' sprintf('k_{v}=%1.2g',dataAv.Gains_Ag(2)) ' ' sprintf('k_{d}=%1.2g',dataAv.Gains_Ag(3))]...
                [sprintf('R^{2} = %1.2g',dataAv.fit_agonist(1)) '      ' sprintf('VAF = %1.2g',dataAv.fit_agonist(2))]};
            title(title_string)
            legend('Data','mSRM'); ylabel([tag_ag ' EMG']);
            
            %hSRM - CoM
            ax2 = plotij(4,2,2,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_CoM(ind_cond,:),'m','LineWidth',2)
            title_string = {['hSRM - CoM']...
                [sprintf('k_{a1}=%1.2g', dataAv.Gains_Ag_TotalDual_CoM(1)) ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_CoM(2))...
                ' ' sprintf('k_{d1}=%1.2g',dataAv.Gains_Ag_TotalDual_CoM(3)) '      ' sprintf('k_{a2}=%1.2g',dataAv.Gains_Ag_TotalDual_CoM(5))...
                ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_CoM(6)) ' ' sprintf('k_{d2}=%1.2g',dataAv.Gains_Ag_TotalDual_CoM(7))]...
                [sprintf('R^{2} = %1.2g',dataAv.fit_agonist_TotalDual_CoM(1)) '      ' sprintf('VAF = %1.2g',dataAv.fit_agonist_TotalDual_CoM(2))]};
            title(title_string)
            legend('Data','hSRM (CoM)'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            
            % hSRM - Cz
            ax3 = plotij(4,2,3,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_Cz(ind_cond,:),'b','LineWidth',2)
            title_string = {['hSRM - Cz']...
                [sprintf('k_{a1}=%1.2g', dataAv.Gains_Ag_TotalDual_Cz(1)) ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_Cz(2))...
                ' ' sprintf('k_{d1}=%1.2g',dataAv.Gains_Ag_TotalDual_Cz(3)) '      ' sprintf('k_{a2}=%1.2g',dataAv.Gains_Ag_TotalDual_Cz(5))...
                ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_Cz(6)) ' ' sprintf('k_{d2}=%1.2g',dataAv.Gains_Ag_TotalDual_Cz(7))]...
                [sprintf('R^{2} = %1.2g',dataAv.fit_agonist_TotalDual_Cz(1)) '      ' sprintf('VAF = %1.2g',dataAv.fit_agonist_TotalDual_Cz(2))]};
            title(title_string)
            legend('Data','hSRM (Cz)'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            
            % hSRM - beta
            ax4 = plotij(4,2,4,1); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_beta(ind_cond,:),'g','LineWidth',2)
            title_string = {['hSRM - Cz']...
                [sprintf('k_{a1}=%1.2g', dataAv.Gains_Ag_TotalDual_beta(1)) ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_beta(2))...
                ' ' sprintf('k_{d1}=%1.2g',dataAv.Gains_Ag_TotalDual_beta(3)) '      ' sprintf('k_{a2}=%1.2g',dataAv.Gains_Ag_TotalDual_beta(5))...
                ' ' sprintf('k_{v1}=%1.2g',dataAv.Gains_Ag_TotalDual_beta(6)) ' ' sprintf('k_{d2}=%1.2g',dataAv.Gains_Ag_TotalDual_beta(7))]...
                [sprintf('R^{2} = %1.2g',dataAv.fit_agonist_TotalDual_beta(1)) '      ' sprintf('VAF = %1.2g',dataAv.fit_agonist_TotalDual_beta(2))]};
            title(title_string)
            legend('Data','hSRM (beta)'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            
            % all on same plot
            ax_all = plotij(1,2,1,2); hold on
            plot(atime,agonist,'k','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist(ind_cond,:),'r','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_CoM(ind_cond,:),'m','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_Cz(ind_cond,:),'b','LineWidth',2)
            plot(atime(ind_time),dataAv.Recon_Agonist_TotalDual_beta(ind_cond,:),'g','LineWidth',2)
            title('All SRMs'); ylabel([tag_ag ' EMG']); xlabel('Time (s)');
            %             legend('Data','mSRM','dSRM (beta)','dSRM (Cz)','dSRM (CoM')
            legend('Data','mSRM','hSRM (CoM')
            sgtitle([participant + ' Mag' + num2str(mag) + " direc" + num2str(direc)])
            set(ax1,'YLim',yl)
            set(ax2,'YLim',yl)
            set(ax_all,'YLim',yl)
            
            if savefigopt
                saveas(gcf,[figdir + participant + '_DualSRMCompare_mag' + num2str(mag) + '_direc' + num2str(direc) + '.fig'],'fig')
                saveas(gcf,[figdir + participant + '_DualSRMCompare_mag' + num2str(mag) + '_direc' + num2str(direc) + '.jpg'],'jpg')
                print(gcf,'-depsc2',[figdir + participant + '_DualSRMCompare_mag' + num2str(mag) + '_direc' + num2str(direc) + '.eps'])
            end
            
            
            %% plot Output variables
            figure(i + iii + direc + 10000); set(gcf,'WindowState','maximized');
            plotij(5,1,1,1)
            plot(atime,dataAv.COMAccel_Y(ind_cond,:)); ylabel('CoM - Acc (g)')
            plotij(5,1,2,1)
            plot(atime,dataAv.beta_ersp(ind_cond,:)); ylabel('beta (nu)')
            plotij(5,1,3,1)
            plot(atime,agonist); ylim(yl); ylabel('agonist (nu)')
            plotij(5,1,4,1)
            plot(atime,antagonist); ylim(yl); ylabel('antagonist (nu)')
            plotij(5,1,5,1)
            plot(atime,dataAv.COMPosminusLVDT_Y(ind_cond,:)); ylabel('CoM - Pos (cm)')
            xlabel('time (s)')
            sgtitle([participant + ' Mag' + num2str(mag) + " direc" + num2str(direc)])
            if savefigopt
                saveas(gcf,[figdir + participant + '_OutputMeasures_mag' + num2str(mag) + '_direc' + num2str(direc) + '.fig'],'fig')
                saveas(gcf,[figdir + participant + '_OutputMeasures_mag' + num2str(mag) + '_direc' + num2str(direc) + '.jpg'],'jpg')
                print(gcf,'-depsc2',[figdir + participant + '_OutputMeasures_mag' + num2str(mag) + '_direc' + num2str(direc) + '.eps'])
            end
            
            
            
        end %mag loop
    end % direction loop
    close all
end % participant loop
