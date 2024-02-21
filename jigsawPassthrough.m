function PI = jigsawPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters)

% calculate reconstruction
eRecon = assembleChannel(predictors,X(gainFlag),X(~gainFlag),atime);

% calculate performance index
fitParameters = modelIPI('X',X,'eRecon',eRecon,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));

PI = fitParameters.PI;

end
