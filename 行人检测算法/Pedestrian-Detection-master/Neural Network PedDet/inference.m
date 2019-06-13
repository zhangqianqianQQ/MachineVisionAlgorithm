function [output,activations] = inference(model,input)
% Do forward propagation through the network to get the activation
% at each layer, and the final output

num_layers = numel(model.layers);
activations = cell(num_layers,1);

% TODO: FORWARD PROPAGATION CODE
layers_1=model.layers(1);
[activations{1},~,~]=layers_1.fwd_fn(input, layers_1.params, layers_1.hyper_params, 0, []);
for i=2:num_layers
    layer=model.layers(i);
    [activations{i},~,~]=layer.fwd_fn(activations{i-1}, layer.params, layer.hyper_params, 0, []);
end
output = activations{end};
