function [outdata,mind,maxd] = normalise(data, p2, p3)
% normalise the data into 0 to 1 with p3 percent of highest values removed
indata = double(data);
clear data;
percent = p3;
ndata = numel(indata);
[val,pos] = sort(indata(:));
upos = round(ndata*percent);
maxd = val(upos);
mind = min(indata(:));
outdata = (indata-double(mind)*ones(size(indata))) / (maxd-mind);
outdata(find(outdata(:)>1)) = 1;