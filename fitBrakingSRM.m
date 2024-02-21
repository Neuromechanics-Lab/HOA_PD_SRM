function [xBraking, eBraking, fitsBraking] = fitBrakingSRM(e,atime,predictors,subjID,magnitude,direction)
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

% 60-250 ms search range was welch 2008
X0 = [10.0 0.01 0.01 0.150];
UB = [15.0 0.04 0.04 0.250];
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
LB = [ 0.0 0.00 0.00 0.060];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.650&atime<0.800))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.8 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;

fitsBraking(isnan(fitsBraking)) = 0;

end
