function [xTotal, eTotal,fitsTotal] = fitTotalSRM(e,atime,predictors,X0,subjID,magnitude,direction)

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% allow the gains to vary within +/-20%, allow the delays to vary within +/- 20 msec. note that lower bound for gains must be positive.
gainFlag = [true true true false true true true false];
UB(gainFlag) = 1.1*X0(gainFlag);
LB(gainFlag) = max(0.9*X0(gainFlag),0);
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));

% allow the final delays to vary within +/- 10sec
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));
UB(~gainFlag) = min(X0(~gainFlag)+0.010,0.250);
LB(~gainFlag) = max(X0(~gainFlag)-0.010,0.060);

% add a very small offset to improve convergence when LB and UB are very
% close.
UB((UB-LB)<1e-6) = UB((UB-LB)<1e-6)+1e-6;

% Load in participant hand fits
src = dir("X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_HandFit_Outputs");
ind_rmv = [];
txt_string = subjID + "_" + num2str(direction) + "_" + num2str(magnitude) +  "_Recon_Antagonist";
for i = 1:size(src,1)
    if ~contains(src(i).name, txt_string)% remove rows not containing participant, direction, and magnitude
        ind_rmv = [ind_rmv; i];
    end
end
src(ind_rmv,:) = [];
if ~isempty(src) 
    load(src.folder + "\" + src.name)
    X0 = output.New_Gains; 
    % set bounds to be +/- 10% of hand fit value for feedback gains
    UB(gainFlag) = 1.1*X0(gainFlag);
    LB(gainFlag) = 0.9*X0(gainFlag);
    % set bounds to be +/- 10ms of hand fit value for onset latency
    LB(~gainFlag) = X0(~gainFlag) - 0.010;
    UB(~gainFlag) = X0(~gainFlag) + 0.010;
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xTotal = X;
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end
