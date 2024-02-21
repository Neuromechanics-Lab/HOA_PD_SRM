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
if (strcmp(subjID,"PD15") & magnitude == 10 & direction == 270)
    % ka Destabilizing
    UB(5) = 0; LB(5) = 0; X0(5) = 0;
    % kv destabilizing
    UB(6) = 0; LB(6) = 0; X0(6) = 0;
    % kd destabilizing
    UB(7) = 0; LB(7) = 0; X0(7) = 0;
    % ka Braking
    UB(1) = 1.9;
elseif (strcmp(subjID,"HOA09") & magnitude == 10 & direction == 270)
    % ka Destabilizing
    UB(5) = 1.5; LB(5) = 0; X0(5) = 0.5;
    % kv destabilizing
    UB(6) = 1; LB(6) = 0.017; X0(6) = 0.02;
    % kd destabilizing
    UB(7) = 1; LB(7) = 0.03; %X0(7) = 0.036;
end

[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

if (strcmp(subjID,"HOA09") & magnitude == 10 & direction == 270)
    % ka Braking
    X(1) = 0;
    %kv Braking
    X(2) = 0;
    % lambda destabilizing
    X(end) = 0.180;
elseif (strcmp(subjID,"PD02") & magnitude == 10 & direction == 270)
    % kd Destabilizing
    X(7) = 0.005;
    % lambda braking
%     X(4) = 0.12;
end
xTotal = X;
eTotal = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);

fitsTotal(1) = rsqr(e',eTotal');
fitsTotal(2) = rsqr_uncentered(e',eTotal');

end
