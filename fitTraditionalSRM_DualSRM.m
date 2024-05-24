function [xBraking, eBraking, fitsBraking] = fitTraditionalSRM_DualSRM(e,atime,predictors,subjID,magnitude)
%Fit EMG w/ CoM Kinematics and Beta simultaneously

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% 60-250 ms search range from welch 2008

%Hand fit certain conditions (Identical to fitTraditionalSRM that only fits
%w/ CoM kinematics
%Hand fit certain conditions
if (strcmp(subjID,'step01') & magnitude == 1) | (strcmp(subjID,'step01') & magnitude == 3)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step04') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step05') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step06') & magnitude == 1
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step07') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step08') & magnitude == 1) | (strcmp(subjID,'step08') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif (strcmp(subjID,'step10') & magnitude == 2)
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step11')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step12') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step15') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step17') & magnitude == 2
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step18') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step19')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step20') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
elseif strcmp(subjID,'step21')
    X0 = [10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
else
    X0 = [10.0 0.01 0.01 0.150]; %[10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
    UB = [15.0 0.04 0.04 0.250]; %[15.0 0.04 0.04 0.150];
    LB = [ 0.0 0.00 0.00 0.060];
end
%         error('Bounds were changed')
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false true false];
% add in k_beta and lambda_beta to UB, LB, and X0
X0(5:6) = [1 UB(4)+0.050];
LB(5:6) = [0 UB(4)+0.010];
UB(5:6) = [15 0.400];

fixBurstGain = true;
if fixBurstGain & strcmp(subjID,'step08') & magnitude == 1 %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step11') & magnitude == 2 %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step17') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step19') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step21') %Narrow search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.120&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
else
    burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end
% set constraints to force lambda_beta > lambda_EMG + 10ms
% A*x <= b; A is an M-by-N matrix, where M is the number of inequalities, and N is the number of variables (number of elements in x0).
A = [0 0 0 1 0 -1];
b = [-0.010];

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),...
    X0,A,b,[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4,:),X(5),X(6),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end %dSRM - Not used (fits EMG w/ CoM and EEG simultaneously (no jiggling)
