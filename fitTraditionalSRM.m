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
src = dir("X:\ting\shared_ting\Scott\HOA_PD SRM\HOA_PD_SRM_HandFit_Outputs");
ind_rmv = [];
txt_string = subjID + "_" + num2str(direction) + "_" + num2str(magnitude) +  "_Recon_Agonist_TotalDual_CoM";
% txt_string = "asdF";
for i = 1:size(src,1)
    if ~contains(src(i).name, txt_string)% remove rows not containing participant, direction, and magnitude
        ind_rmv = [ind_rmv; i];
    end
end
src(ind_rmv,:) = [];

X0 = [10.0 0.01 0.01 0.150]; %[10.0 0.01 0.01 0.100]; %[ka, kv, kd, lambda]
UB = [15.0 0.04 0.04 0.250]; %[15.0 0.04 0.04 0.150];
LB = [ 0.0 0.00 0.00 0.060];

gainFlag = [true true true false];

fixBurstGain = true;
if fixBurstGain
    burstGain = max(e(1,atime>0.150&atime<0.300))/max(predictors(1,:));
    [X0(1),UB(1)] = deal(max(min(burstGain,15),0));
    LB(1) = 0.9 * X0(1);
end

if ~isempty(src) % if the participant has been handfit, then change the gains to be the HandFit values
    load(src.folder + "\" + src.name)
    X0 = output.New_Gains(1:4); % only use the first four gains since TraditionalSRM only has one feedback loop
    % set bounds to be +/- 10% of hand fit value 
    UB = 1.1*X0;
    LB = 0.9*X0;
    
end


    
[X,FVAL,EXITFLAG] = fmincon(@(X) jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters),X0,[],[],[],[],LB,UB,[],options);

xBraking = X;

eBraking = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);
fitParameters = modelIPI('X',X,'eRecon',eBraking,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

fitsBraking(1) = fitParameters.r2;
fitsBraking(2) = fitParameters.r2u;
fitsBraking(isnan(fitsBraking)) = 0;

end
