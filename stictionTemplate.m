function a_out = stictionTemplate(varargin)

p = inputParser;
p.addOptional('a',[]);

% p.addOptional('t',[0:(1/1080):(0.8-(1/1080))]);
p.addOptional('t',[-0.5:(9.2593e-04):0.9991]);
p.addOptional('ts1',0.000);
p.addOptional('ts2',0.075); % initial burst; search range 50-100 ms
p.addOptional('ts3',0.450);
p.addOptional('ts4',0.450);
% p.addOptional('ts5',0.525); % deceleration burst; search range 500-550 ms
p.addOptional('ts5',0.650); % deceleration burst; search range 500-550 ms
p.addOptional('tau',0.005);
p.parse(varargin{:});

a = p.Results.a;
t = p.Results.t;

ts1 = p.Results.ts1;
ts2 = p.Results.ts2;
ts3 = p.Results.ts3;
ts4 = p.Results.ts4;
ts5 = p.Results.ts5;
tau = p.Results.tau;

a_out = nan(size(a));

% identify indices here
bkgdInds = t<ts1;
burst1Inds = findInds(ts1,ts2);
silence1Inds = findInds(ts2,ts3);
burst2Inds = findInds(ts4,ts5);
silence2Inds = find(t>ts5);

a_out(:,bkgdInds) = 0;

for i = 1:size(a_out,1)
    a_orig = a(i,:);
    a_new = nan(size(a_orig));
    a_new(bkgdInds) = 0;

    a_new(burst1Inds) = a_orig(burst1Inds) - a_orig(burst1Inds(1));
    silence1Time = t(silence1Inds) - t(silence1Inds(1));
    a_new(silence1Inds) = a_new(burst1Inds(end))*exp(-(1/tau)*silence1Time);

    a_new(burst2Inds) = a_orig(burst2Inds) - a_orig(burst2Inds(1));
    silence2Time = t(silence2Inds) - t(silence2Inds(1));
    a_new(silence2Inds) = a_new(burst2Inds(end))*exp(-(1/tau)*silence2Time);

    a_out(i,:) = a_new;
end

    function out = findInds(tstart,tstop)
        out = [time2ind(t,tstart):time2ind(t,tstop)];
    end

end
