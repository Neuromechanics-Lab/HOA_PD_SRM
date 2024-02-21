function out = assembleChannelComponents(signals,gains,delay,atime,THRESH)

% note that we cannot just matrix multiply because we have to delay each signal
out = [];
if THRESH
    for i = 1:length(gains)
        out(i,:) = channelDelay(threshold(signals(i,:)*gains(i)),delay,atime);
    end
else
    for i = 1:length(gains)
        out(i,:) = channelDelay(signals(i,:)*gains(i),delay,atime);
    end
end
end
