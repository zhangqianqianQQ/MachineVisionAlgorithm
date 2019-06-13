function Datacube_conved = Convolution(Datacube,W,ConvFilter)
% Given W, performing convolution on Datacube with zero padding

[Width,Height,Channel] = size(Datacube);
num_filters = size(W,2);
Datacube_conved = cell(num_filters,1);
magSize = (ConvFilter.PatchSize-1)/2;
magChannel = (ConvFilter.Channel-1)/2;
Tempcube_conved = zeros(Width+ConvFilter.PatchSize-1, Height+ConvFilter.PatchSize-1, Channel+ConvFilter.Channel-1);
Tempcube_conved((magSize+1):end-magSize,(magSize+1):end-magSize,(magChannel+1):end-magChannel) = Datacube;
X = im2colstep(Tempcube_conved,[ConvFilter.PatchSize,ConvFilter.PatchSize,ConvFilter.Channel]);
mu = mean(X,2); 
% mu = mean(X,1);
X = bsxfun(@minus, X, mu);
for i=1:num_filters
    Datacube_conved{i} = reshape(W(:,i)'*X,[Width,Height,Channel]);
end

