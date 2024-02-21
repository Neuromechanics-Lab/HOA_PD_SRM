function out = assembleChannel(signals,gains,delay,atime)
out = channelDelay(threshold(signals'*gains'),delay,atime);
end
