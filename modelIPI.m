function fitParameters = modelIPI(varargin)

p = inputParser;
p.addOptional('X',[]);
p.addOptional('e',[]);
p.addOptional('eRecon',[]);
p.addOptional('gainWeight',[]);
p.addOptional('optimizationParameters',[]);
p.parse(varargin{:});

X = p.Results.X;
e = p.Results.e;
e_recon = p.Results.eRecon;
optimizationParameters = p.Results.optimizationParameters;
gainWeight = p.Results.gainWeight;

J_SE = optimizationParameters.J_SE;
J_ME = optimizationParameters.J_ME;
J_GM = optimizationParameters.J_GM;

fitParameters.r2 = rsqr(e',e_recon');
fitParameters.r2u = rsqr_uncentered(e',e_recon');

% Compute the errors between recorded and simulated EMG signals. We are
% minimizing a function of these error values:
% error   = recorded  - simulated
e_error = e - e_recon;
e_error(isnan(e_error)) = [];

% ### J = squared error + "min-max error" = terminal cost
% ### J = L1 + L2:
% L1 = squared error. L1 composes the bulk of the terminal cost. It is a
% linear combination of the squares of the error terms.
fitParameters.L1 = J_SE*(e_error*e_error');

% L2 = max of the abs of the error terms. L2 penalizes large deviations.
% Little terminal cost is contributed by L2, but L2 appears to "smooth out"
% the J manifold and make the optimization converge more consistently.
fitParameters.L2 = J_ME*max(abs(e_error));

% L3 = magnitude of the gain values. this term is just designed to zero out
% noncontributing gains, and improve convergence.
fitParameters.L3 = J_GM*(X.*gainWeight)*(X.*gainWeight)';

% PI is the sum of these individual costs. The function fmincon attempts to
% minimize J.
fitParameters.PI = fitParameters.L1 + fitParameters.L2 + fitParameters.L3;

end
