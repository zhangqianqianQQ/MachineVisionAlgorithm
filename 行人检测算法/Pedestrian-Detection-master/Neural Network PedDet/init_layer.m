function layer = init_layer(type, info)
% Given a layer name, initializes the layer structure properly with the
% weights randomly initialized.
% 
% Input:
%	type - Layer name (options: linear, conv, pool, softmax, flatten, relu)
%	info - Structure holding hyper parameters that define the layer
%
% Examples: init_layer('linear',struct('num_in',18,'num_out',10)
% 			init_layer('softmax',[])


% Parameters for weight initialization
weight_init = @randn;
if isfield(info,'weight_scale') ws = info.weight_scale;
else ws = 0.1; end
if isfield(info,'bias_scale') bs = info.bias_scale;
else bs = 0.1; end

params = struct('W',[],'b',[]);
params = struct('W',[],'b',[],'vel_W',[],'vel_b',[]);
switch type
	case 'linear'
		% Requires num_in, num_out
		fn = @fn_linear;		
		W = weight_init(info.num_out, info.num_in)*ws;
		b = weight_init(info.num_out, 1)*bs;
		params.W = W;
		params.b = b;
	case 'conv'
		% Requires filter_size, filter_depth, num_filters
		fn = @fn_conv;		
		W = weight_init(info.filter_size, info.filter_size, info.filter_depth, info.num_filters)*ws;
		b = weight_init(info.num_filters, 1)*bs;
		params.W = W;
		params.b = b;
	case 'pool'
		% Requires filter_size and optionally stride (default stride = 1)
		fn = @fn_pool;		
	case 'softmax'
		fn = @fn_softmax;
	case 'flatten'
		% Requires the number of dimensions of the output of the previous layer.
		% The parameter should be defined by info.num_dims
		fn = @fn_flatten;
	case 'relu'
		fn = @fn_relu;
end

layer = struct('fwd_fn', fn, 'type', type, 'params', params, 'hyper_params', info);
