function combined_Datacube = Concatenation(Datacube)
% input
%   Datacube(Cell Arrays): Each Cell contains a datacube after CP
%   Decomposition and pooling 
% output
%   combined_Datacube: Concatenating each channel of Datacube on the third
%   dimension
num_channels = size(Datacube,1);
index = 1;
for i=1:num_channels
    num_dims = size(Datacube{i},3);
    combined_Datacube(:,:,index:(index+num_dims-1)) = Datacube{i};
    index = index + num_dims;
end