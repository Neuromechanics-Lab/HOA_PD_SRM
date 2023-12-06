%% script to interpolate and normalize EEG data
clear; close all
load('D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_Concatinated_06-Dec-2023.mat') %output measures Table (EEG, EMG, etc.)
%% interpolate EEG output measures to correspond to dataAv.atime
% Cz
% Initialize a matrix to store the interpolated values
interpolatedCz = nan(size(dataAv.atime));
% Loop through each row and interpolate
for i = 1:size(dataAv.Cz, 1)
    interpolatedCz(i, :) = interp1(dataAv.time_erp(i,:)/1000, dataAv.Cz(i, :), dataAv.atime(i,:), 'linear');
end
% Replace the Cz variable in dataAv with the interpolated values
dataAv.Cz = interpolatedCz;

% Beta
% Initialize a matrix to store the interpolated values
interpolatedBeta = nan(size(dataAv.atime));
interpolatedGamma = nan(size(dataAv.atime));
interpolatedTheta = nan(size(dataAv.atime));
interpolatedAlpha = nan(size(dataAv.atime));
% Loop through each row and interpolate
for i = 1:size(dataAv.beta_ersp, 1)
    interpolatedBeta(i, :) = interp1(dataAv.time_ersp(i,:)/1000, dataAv.beta_ersp(i, :), dataAv.atime(i,:), 'linear');
    interpolatedGamma(i, :) = interp1(dataAv.time_ersp(i,:)/1000, dataAv.gamma_ersp(i, :), dataAv.atime(i,:), 'linear');
    interpolatedTheta(i, :) = interp1(dataAv.time_ersp(i,:)/1000, dataAv.theta_ersp(i, :), dataAv.atime(i,:), 'linear');
    interpolatedAlpha(i, :) = interp1(dataAv.time_ersp(i,:)/1000, dataAv.alpha_ersp(i, :), dataAv.atime(i,:), 'linear');
end
% Replace the Cz variable in dataAv with the interpolated values
dataAv.beta_ersp = interpolatedBeta;
dataAv.gamma_ersp = interpolatedGamma;
dataAv.theta_ersp = interpolatedTheta;
dataAv.alpha_ersp = interpolatedAlpha;

%% normalize EEG output measures for each participant and add coefficients in to dataAv
% Find unique patient values
uniquePatients = unique(dataAv.patient);
% Initialize an array to store the normalization coefficients
Cz_norm_coeff = zeros(size(dataAv.mag));
beta_norm_coeff = zeros(size(dataAv.mag));
alpha_norm_coeff = zeros(size(dataAv.mag));
gamma_norm_coeff = zeros(size(dataAv.mag));
theta_norm_coeff = zeros(size(dataAv.mag));

dataAv.Cz_norm = nan(size(dataAv.Cz));
dataAv.beta_ersp_norm = nan(size(dataAv.beta_ersp));
dataAv.theta_ersp_norm = nan(size(dataAv.theta_ersp));
dataAv.gamma_ersp_norm = nan(size(dataAv.gamma_ersp));
dataAv.alpha_ersp_norm = nan(size(dataAv.alpha_ersp));
% Loop through each unique patient
for i = 1:length(uniquePatients)
    patient = uniquePatients(i);
    
    % Find rows corresponding to the current patient
    ind = find((dataAv.patient == patient));
    tmp_Cz_norm = []; tmp_beta_norm = []; tmp_alpha_norm = []; tmp_theta_norm = []; 
    tmp_gamma_norm = []; 
    for ii = ind'
        tmp_Cz_norm = [tmp_Cz_norm; min(dataAv.Cz(ii,:))];
        tmp_beta_norm = [tmp_beta_norm; max(dataAv.beta_ersp(ii,:))];
        tmp_alpha_norm = [tmp_alpha_norm; max(dataAv.alpha_ersp(ii,:))];
        tmp_gamma_norm = [tmp_gamma_norm; max(dataAv.gamma_ersp(ii,:))];
        tmp_theta_norm = [tmp_theta_norm; max(dataAv.theta_ersp(ii,:))];
    end
        
    % Set the normalization coefficient for the current patient's rows
    Cz_norm_coeff(ind) = min(tmp_Cz_norm);
    beta_norm_coeff(ind) =  max(tmp_beta_norm);
    alpha_norm_coeff(ind) = max(tmp_alpha_norm);
    gamma_norm_coeff(ind) = max(tmp_gamma_norm);
    theta_norm_coeff(ind) = max(tmp_theta_norm);
    
    %normalize each row 
    for iii = ind'
        dataAv.Cz_norm(iii,:) = dataAv.Cz(iii,:)./abs(Cz_norm_coeff(iii));
        dataAv.beta_ersp_norm(iii,:) = dataAv.beta_ersp(iii,:)./beta_norm_coeff(iii);
        dataAv.alpha_ersp_norm(iii,:) = dataAv.alpha_ersp(iii,:)./alpha_norm_coeff(iii);
        dataAv.gamma_ersp_norm(iii,:) = dataAv.gamma_ersp(iii,:)./gamma_norm_coeff(iii);
        dataAv.theta_ersp_norm(iii,:) = dataAv.theta_ersp(iii,:)./theta_norm_coeff(iii);
        
    end
    figure;
    subplot(2,1,1);plot(dataAv.atime(1,:),dataAv.Cz(ind,:))
    subplot(2,1,2);plot(dataAv.atime(1,:),dataAv.Cz_norm(ind,:))
    sgtitle(dataAv.ID(iii))
    1+1;
end
close all
% Create a new variable Cz_norm_coeff containing the normalization coefficients
dataAv.Cz_norm_coeff = Cz_norm_coeff;
dataAv.beta_norm_coeff = beta_norm_coeff;
dataAv.alpha_norm_coeff = alpha_norm_coeff;
dataAv.theta_norm_coeff = theta_norm_coeff;
dataAv.gamma_norm_coeff = gamma_norm_coeff;

%% save output
save(['D:\Users\SBOEBIN\Documents\MATLAB\Post creatfitsData Output\HOA_PD_DataTables_interp_norm_' date '.mat'],'dataAv','data','dataSD','participants','-v7.3')