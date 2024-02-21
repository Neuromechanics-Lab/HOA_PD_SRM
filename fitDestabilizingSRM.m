function [xDestabilizing, eDestabilizing, fitsDestabilizing] = fitDestabilizingSRM(e,atime,predictors,subjID,magnitude,direction)
% fit "Destabilizing response" at end of perturbation.

% load optimization options. these include overall cost function options as
% well as direct options for the Matlab optimizer.
optimizationParameters = loadOptimizationParameters();

options = optimoptions('fmincon',...
    'display',optimizationParameters.display,...
    'TolX',optimizationParameters.TolX,...
    'TolFun',optimizationParameters.TolFun,...
    'MaxFunEvals',optimizationParameters.MaxFunEvals...
    );

% note slightly different gain limits for destabilizing SRM TA gain
if strcmp(subjID,'') & magnitude == 3
    X0 = [10.0 0.01 0.01 0.110];
    UB = [15.0 0.04 0.04 0.120];
    LB = [ 0.0 0.00 0.00 0.090];
else
    X0 = [10.0 0.01 0.01 0.140];
    UB = [15.0 0.04 0.04 0.210];
    LB = [ 0.0 0.00 0.00 0.090];
end
% X0 = [10.0 0.01 0.01 0.150];
% UB = [15.0 0.04 0.04 0.250];
% UB = [15.0 0.04 0.04 0.200];
% UB = [15.0 0.04 0.04 0.175];
% UB = [15.0 0.02 0.02 0.175];
% LB = [ 0.0 0.00 0.00 0.060];
% LB = [ 0.0 0.00 0.00 0.050];
% LB = [ 0.0 0.00 0.00 0.080];
% LB = [ 0.0 0.00 0.00 0.100];
gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.275))/max(predictors(1,:));
    % burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xDestabilizing = X;

eDestabilizing = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eDestabilizing,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsDestabilizing(1) = fitParameters.r2;
fitsDestabilizing(2) = fitParameters.r2u;
fitsDestabilizing(isnan(fitsDestabilizing)) = 0;

end
