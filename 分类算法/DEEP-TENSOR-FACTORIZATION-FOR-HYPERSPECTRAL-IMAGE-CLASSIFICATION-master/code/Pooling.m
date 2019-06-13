function Datacube = Pooling(ktensor)
% input
%   ktensor(Cell Array): Each cell contains a ktensor caculated by a given
%   channel of convolutionized Datacube
% output
%   Datacube(Cell Array): For each cell of ktensor, discarding the third
%   dimension, outproduct the first and the second dimension with
%   corresponding lambda to form a Datacube with equal size of space
%   Maxpooling ?
num_channels = size(ktensor,1);
Datacube = cell(num_channels,1);
for i=1:num_channels
    num_of_U = size(ktensor{i}.U{1},2);
    combined_basis = [];
    for j=1:num_of_U
        temp = ktensor{i}.lambda(j) * ktensor{i}.U{1}(:,j) * ktensor{i}.U{2}(:,j)';
        combined_basis(:,:,j) = temp;
    end
    Datacube{i} = combined_basis;
end