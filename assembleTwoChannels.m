function out = assembleTwoChannels(signals1,gains1,delay1,signals2,gains2,delay2,atime)

out1 = channelDelay(threshold(signals1'*gains1'),delay1,atime);
out2 = channelDelay(threshold(signals2'*gains2'),delay2,atime);

out = threshold(out1+out2);


end

