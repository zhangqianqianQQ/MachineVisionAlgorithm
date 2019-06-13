function  [updated_model,vel_W,vel_b] = update_weights(model,grad,hyper_params,vel_W,vel_b)

num_layers = length(grad);
a = hyper_params.learning_rate;
lmda = hyper_params.weight_decay;
updated_model = model;
MT=hyper_params.momentum;
% TODO: Update the weights of each layer in your model based on the calculated gradients

for i = 1:num_layers
    vel_W{i} =  MT*vel_W{i}- a * (grad{i}.W - lmda * model.layers(i).params.W) ;
    vel_b{i} =  MT*vel_b{i}- a * (grad{i}.b - lmda * model.layers(i).params.b) ; 
    updated_model.layers(i).params.W=model.layers(i).params.W+vel_W{i};
    updated_model.layers(i).params.b=model.layers(i).params.b+vel_b{i};
end
