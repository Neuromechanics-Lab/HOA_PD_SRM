function out = makeDelayFigure(predictorsBraking,atime)

aOrig = predictorsBraking(1,:);
aDelayed = channelDelay(aOrig,0.1,atime);

figure
plot(atime, aOrig)
hold on
plot(atime, aDelayed)
legend("original","delayed")

end
