function [out, out1, out2] = assembleTwoChannels(signals1,gains1,delay1,signals2,gains2,delay2,atime)

out1 = channelDelay(threshold(signals1'*gains1'),delay1,atime); % subctx or braking component
out2 = channelDelay(threshold(signals2'*gains2'),delay2,atime); % ctx or destabilizing component

out = threshold(out1+out2);


end

