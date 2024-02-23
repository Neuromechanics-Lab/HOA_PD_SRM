function out = assembleTwoChannels(signals1,gains1,delay1,signals2,gains2,delay2,atime)

out1 = channelDelay(threshold(signals1'*gains1'),delay1,atime);
out2 = channelDelay(threshold(signals2'*gains2'),delay2,atime);

out = threshold(out1+out2);

	function out = channelDelay(in,delay,atime)
		out = interp1(atime,in,atime-delay,'linear',0);
	end

	function out = threshold(in)
		out = max(in,0);
	end

end

