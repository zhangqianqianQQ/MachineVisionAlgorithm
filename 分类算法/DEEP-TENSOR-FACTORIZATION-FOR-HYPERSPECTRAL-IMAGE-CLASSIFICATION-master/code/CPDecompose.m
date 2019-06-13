function ktensor = CPDecompose(Datacube,rank)
% input
%   Datacube: Cell Arrays, each contains a convolutionized Datacube by a
%   specific column of W(ConvFilter) which is a channel of Filter Bank
%   rank: the rank of CP Decomposition
% output
%   ktensor: The results of CP Decomposition for each convolutionized
%   Datacube(Cell Arrays)
num_channels = size(Datacube,1);
ktensor = cell(num_channels,1);
for i=1:num_channels
    ktensor{i} = parafac_als(tensor(Datacube{i}),rank);
end