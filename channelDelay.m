function out = channelDelay(in,delay,atime)
out = interp1(atime,in,atime-delay,'linear',0);
end
