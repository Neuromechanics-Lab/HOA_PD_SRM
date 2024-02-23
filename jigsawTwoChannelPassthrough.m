function PI = jigsawTwoChannelPassthrough(X,predictors,gainFlag,atime,e,optimizationParameters)

	% calculate reconstruction
    if size(predictors,1) == 4
        eRecon = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4,:),X(5),X(6),atime);
    else
        eRecon = assembleTwoChannels(predictors(1:3,:),X(1:3),X(4),predictors(4:6,:),X(5:7),X(8),atime);
    end
   

	% calculate performance index
	fitParameters = modelIPI('X',X,'eRecon',eRecon,'e',e,'optimizationParameters',optimizationParameters,'gainWeight',double(gainFlag));
	
	PI = fitParameters.PI;
end