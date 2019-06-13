function model = init_model(layers, input_size, output_size, display)
% Initialize a network model given an array of layers.
% Expected input and output size must be provided to verify that the network
% is properly defined.

model = struct('layers',layers,'input_size',input_size,'output_size',output_size);

% Check that layer input/output sizes are correct
% Batch sizes of 1 and greater than 1 are used to ensure that both cases are handled properly by the code
num_layers = length(model.layers);
input1 = rand([input_size 1]);
input5 = rand([input_size 5]);

addpath pcode
% Run inference to get intermediate activation sizes, and final output size
[output1,act1] = inference_(model,input1);
[output5,act5] = inference_(model,input5);

network_output_size = size(output5);
network_output_size = network_output_size(1:end-1);

% While designing your model architecture it can be helpful to know the
% intermediate sizes of activation matrices passed between layers. 'display'
% is an option you set when you call 'init_model'.
if display
	disp('Input size:');
	disp(input_size);
	for i = 1:num_layers-1
		fprintf('Layer %d output size:\n',i);
		
		% Comparing sizes when the last dimension of a matrix has size 1
		% can be kind of annoying in MATLAB, and everything has been set
		% up in such a way that this bug probably won't come up for you,
		% but just in case it is important to check.
		act_size = size(act5{i});
		if (length(act_size) == 2 && size(act5{i},1) == size(act1{i},1)) ...
			|| isequal(act_size(1:end-1),size(act1{i}))
			disp(act_size(1:end-1));
		else
			fprintf('Error in layer %d, size mismatch between different batch sizes\n',i);
			disp('With batch size 5:');
			disp(act_size(1:end-1));
			disp('With batch size 1:');
			disp(size(act1{i}));
		end
	end
	disp('Final output size:');
	disp(network_output_size);
	disp('Provided output size (should match above):');
	disp(output_size);
	disp('(Batch dimension not included)');
end

% If you defined all of your layers correctly you should know the final
% size of the output matrix, this is just a sanity check.
assert(isequal(network_output_size,output_size),...
		'Network output does not match up with provided output size');
