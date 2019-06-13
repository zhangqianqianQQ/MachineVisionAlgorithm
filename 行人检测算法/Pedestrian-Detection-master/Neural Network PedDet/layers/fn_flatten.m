% ----------------------------------------------------------------------
% input: [any dimensions] x batch_size
% output: [product of first input dims] x batch_size
% dv_output: same as output
% dv_input: reshaped dv_output to match input dimensions
% ----------------------------------------------------------------------

function [output, dv_input, grad] = fn_flatten(input, params, hyper_params, backprop, dv_output)
% Flatten all but the last dimension of the input, the number of dimensions
% of the input must be specified when the flatten layer is initialized to deal
% with ambiguities of size() when the batch size is 1.

in_dim = size(input);
batch_size = size(input,hyper_params.num_dims); 
output = reshape(input,[],batch_size);

dv_input = [];
grad = struct('W',[],'b',[]);

if backprop
	dv_input = reshape(dv_output,in_dim);
end
