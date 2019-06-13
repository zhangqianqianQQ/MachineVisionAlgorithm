function [output, dv_input, grad] = fn_relu(input, params, hyper_params, backprop, dv_output)
% Rectified linear unit activation function

output = max(input,0);

dv_input = [];
grad = struct('W',[],'b',[]);

if backprop
		dv_input = dv_output;
		dv_input(output == 0) = 0;
end
