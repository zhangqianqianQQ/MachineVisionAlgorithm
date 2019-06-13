% ----------------------------------------------------------------------
% input: [any dimensions] x batch_size
% labels: same size as input
% ----------------------------------------------------------------------

function [loss, dv_input] = loss_euclidean(input, labels, hyper_params, backprop)

assert(isequal(size(labels),size(input)));

if isfield(hyper_params, 'num_dims') num_dims = hyper_params.num_dims;
else num_dims = 2; end
batch_size = size(input, num_dims);

diff = input - labels;
loss = sum(diff(:)'*diff(:))/(2*batch_size);

dv_input = [];
if backprop
	dv_input = diff ./ batch_size;
end

