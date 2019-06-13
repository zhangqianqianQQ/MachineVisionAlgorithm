function [data,label] = reshape_data(datacube,label0)
% reshape the datacube into a matrix where rows corresponding to samples,
% column corresponding to features
data = reshape(datacube,[size(datacube,1)*size(datacube,2),size(datacube,3)]);
data = double(data);
label = reshape(label0,[size(datacube,1)*size(datacube,2),1]);
label = double(label);