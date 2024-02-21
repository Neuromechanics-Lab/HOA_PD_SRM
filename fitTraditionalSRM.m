function [xBraking, eBraking, fitsBraking] = fitTraditionalSRM(e,atime,predictors,subjID,magnitude,direction) %mSRM
% fit "braking response" at end of perturbation.

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
%Hand fit certain conditions
if (strcmp(subjID,'HOA08') && magnitude == 10) | (strcmp(subjID,'HOA08') && magnitude == 7.5)
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
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain & strcmp(subjID,'step08') & magnitude == 1 %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.110&atime<0.140))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step11') & magnitude == 2 %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step17') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.150&atime<0.220))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step19') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.100&atime<0.250))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
elseif fixBurstGain & strcmp(subjID,'step21') %alter search window for burst gain for certain participants
    burstGain = max(e(1,atime>0.120&atime<0.180))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
else
    burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end
