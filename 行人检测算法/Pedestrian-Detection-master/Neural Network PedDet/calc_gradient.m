function [grad] = calc_gradient(model, input, activations, dv_output)
% Calculate the gradient at each layer, to do this you need dv_output
% determined by your loss function and the activations of each layer.
% The loop of this function will look very similar to the code from
% inference, just looping in reverse.

num_layers = numel(model.layers);
grad = cell(num_layers,1);
% TODO: Determine the gradient at each layer with weights to be updated
for i=1:num_layers-1
    j=num_layers+1-i;
    layer=model.layers(j);
    [~,dv_output,grad{j}]=layer.fwd_fn(activations{j-1},layer.params, layer.hyper_params, 1, dv_output);
end
layer_first=model.layers(1);
[~,~,grad{1}]=layer_first.fwd_fn(input,layer_first.params,layer_first.hyper_params,1,dv_output);