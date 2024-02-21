function SRMFits = calculateSRMFits(fitsData)

% use a common copy of the atime vector
atime = fitsData.atime(1,:);

removeBackLev = true;
fitDestabMG = true;

% loop. note that randperm here does not affect functionality and is just
% used for debugging purposes (in order to prevent having to go through all
% of the TA records prior to doing MG.)
for idx = randperm(size(fitsData,1))
    e = fitsData.e(idx,:);
    
    if removeBackLev
        backLev = nanmean(e(atime<0.05));
        e = e - backLev;
    end
    if fitsData.mus(idx)=="TA"&fitsData.dir(idx)=="B"
        
        % identify braking response in TA in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitBrakingSRM(e,atime,predictorsBraking);
        
        % identify destabilizing response in TA in backward perturbations
        predictorsDestabilizing = [fitsData.aPrime(idx,:); fitsData.vPrime(idx,:); fitsData.dPrime(idx,:)];
        [fitsData.xPrime(idx,[5:8]), fitsData.ePrimeRecon(idx,:) fitsData.fitPrime(idx,:)] = fitDestabilizingSRM(e,atime,predictorsDestabilizing);
        
        % combine them into the initial guess for the final optimization
        X0Total = [fitsData.x(idx,[1:4]) fitsData.xPrime(idx,[5:8])];
        predictorsTotal = [predictorsBraking; predictorsDestabilizing];
        
        [fitsData.xTotal(idx,:), fitsData.eTotalRecon(idx,:) fitsData.fitTotal(idx,:)] = fitTotalSRM(e,atime,predictorsTotal,X0Total);
        if removeBackLev
            fitsData.eTotalRecon(idx,:) = fitsData.eTotalRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="TA"&fitsData.dir(idx)=="F"
        % identify braking response in TA in forward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitTraditionalSRM(e,atime,predictorsBraking);
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="MGAS"&fitsData.dir(idx)=="B"
        % identify braking response in MGAS in backward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitTraditionalSRM(e,atime,predictorsBraking);
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    elseif fitsData.mus(idx)=="MGAS"&fitsData.dir(idx)=="F"
        % identify braking response in MGAS in forward perturbations
        predictorsBraking = [fitsData.a(idx,:); fitsData.v(idx,:); fitsData.d(idx,:)];
        [fitsData.x(idx,[1:4]), fitsData.eRecon(idx,:) fitsData.fit(idx,:)] = fitBrakingSRM(e,atime,predictorsBraking);
        
        if fitDestabMG
            % identify destabilizing response in MG in forward perturbations
            predictorsDestabilizing = [fitsData.aPrime(idx,:); fitsData.vPrime(idx,:); fitsData.dPrime(idx,:)];
            [fitsData.xPrime(idx,[5:8]), fitsData.ePrimeRecon(idx,:) fitsData.fitPrime(idx,:)] = fitDestabilizingSRM(e,atime,predictorsDestabilizing);
            
            % combine them into the initial guess for the final optimization
            X0Total = [fitsData.x(idx,[1:4]) fitsData.xPrime(idx,[5:8])];
            predictorsTotal = [predictorsBraking; predictorsDestabilizing];
            
            [fitsData.xTotal(idx,:), fitsData.eTotalRecon(idx,:) fitsData.fitTotal(idx,:)] = fitTotalSRM(e,atime,predictorsTotal,X0Total);
            if removeBackLev
                fitsData.eTotalRecon(idx,:) = fitsData.eTotalRecon(idx,:) + backLev;
            end
        end
        if removeBackLev
            fitsData.eRecon(idx,:) = fitsData.eRecon(idx,:) + backLev;
        end
    end
end

SRMFits = fitsData;

end
