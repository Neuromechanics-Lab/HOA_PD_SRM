function [xBraking, eBraking, fitsBraking] = fitResidualSRM_CoM(e,atime,predictors,subjID,magnitude,LB,UB)
% fit residuals using beta power.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

%Initial guess is midpoint of lower and upper bounds (LB and UB, respectively)
X0 = (UB-LB)/2; 
gainFlag = [true true true false];

if (strcmp(subjID,'HOA19') & magnitude == 7.5)
    X0(end) = 0.200; %manually set ctx CoM delay
    UB(end) = 0.250;
end

fixBurstGain = true;

if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.600))/max(predictors(1,:));
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

end % fit residusls w/ coM
