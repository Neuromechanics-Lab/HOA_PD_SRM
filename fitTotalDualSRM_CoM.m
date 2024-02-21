function [xTotal, eTotal,fitsTotal] = fitTotalDualSRM_CoM(e,atime,predictors,X0,subjID,magnitude)

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% allow the gains to vary within +/-XX%, allow the delays to vary within +/- 20 msec. note that lower bound for gains must be positive.
gainFlag = [true true true false true true true false];
% UB(gainFlag) = 1.5*X0(gainFlag);
UB(gainFlag) = [1.1, 1.5, 1.5,   1.1, 1.5, 1.5].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - Keep 1.1 the same for kas
% LB(gainFlag) = max(0.9*X0(gainFlag),0);
% LB(gainFlag) = max(0.3*X0(gainFlag),0);
LB(gainFlag) = [0.9, 0, 0,    0.9, 0.0, 0.0].*X0(gainFlag); % first vector are the weights to allow for wiggle room on bounds for gains. - keep 0.9 the same for ka to force fit with burst
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));

% allow the final delays to vary within +/- 10sec
[UB(~gainFlag),LB(~gainFlag)] = deal(X0(~gainFlag));
UB(~gainFlag) = min(X0(~gainFlag)+0.010,0.250);
LB(~gainFlag) = max(X0(~gainFlag)-0.010,0.060);

% try to hand fit participants
if (strcmp(subjID,'HOA19') & magnitude == 7.5)
    %lambda2
    UB(end) = 0.250; X0(end) = 0.200;
    %ka1
    UB(1) = 4.9; LB(1) = 4.7; X0(1) = 4.8;
    %ka2
    UB(5) = 3.5; LB(5) = 2.4; X0(5) = 2.7;
end

% add a very small offset to improve convergence when LB and UB are very
% close.
UB((UB-LB)<1e-6) = UB((UB-LB)<1e-6)+1e-6;

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xTotal = X;
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end %dSRM for CoM Predictors
