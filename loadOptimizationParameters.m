function out = loadOptimizationParameters()
J_SE = 1;
J_ME = 1;
J_GM = 1;
display = "iter";
TolX = 1e-9;
MaxFunEvals = 1e+5;
TolFun = 1e-7;
out = table(J_SE,J_ME,J_GM,display,TolX,MaxFunEvals,TolFun);
end
