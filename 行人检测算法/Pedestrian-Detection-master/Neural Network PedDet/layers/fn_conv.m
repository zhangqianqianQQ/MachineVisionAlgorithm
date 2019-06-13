% ----------------------------------------------------------------------
% input: in_height x in_width x num_channels x batch_size
% output: out_height x out_width x num_filters x batch_size
% hyper parameters: (stride, padding for further work)
% params.W: filter_height x filter_width x filter_depth x num_filters
% params.b: num_filters x 1
% dv_output: same as output
% dv_input: same as input
% grad.W: same as params.W
% grad.b: same as params.b
% ----------------------------------------------------------------------

function [output, dv_input, grad] = fn_conv(input, params, hyper_params, backprop, dv_output)

[~,~,num_channels,batch_size] = size(input);
[~,~,filter_depth,num_filters] = size(params.W);
assert(filter_depth == num_channels, 'Filter depth does not match number of input channels');

out_height = size(input,1) - size(params.W,1) + 1;
out_width = size(input,2) - size(params.W,2) + 1;
output = zeros(out_height,out_width,num_filters,batch_size);
% TODO: FORWARD CODE
for i=1:batch_size
    for j=1:num_filters
        output_j_i=zeros(out_height,out_width);
        for k=1:filter_depth
            input_i_k=input(:,:,k,i);
            filter_j_k=params.W(:,:,k,j);
            output_j_i=output_j_i+conv2(input_i_k,filter_j_k,'valid');
        end
        output(:,:,j,i)=output_j_i+params.b(j);
    end    
end
dv_input = [];
grad = struct('W',[],'b',[]);

if backprop
	% TODO: BACKPROP CODE
    %dv_input
    dv_input = zeros(size(input));
    W_flip=flip(flip(params.W,1),2);
    for i=1:batch_size
        for k=1:filter_depth
            for j=1:num_filters
                dv_output_i_k=dv_output(:,:,j,i);
                flip_filter_j_k=W_flip(:,:,k,j);
                dv_input(:,:,k,i)=dv_input(:,:,k,i)+conv2(dv_output_i_k,flip_filter_j_k,'full');
            end
        end    
    end
    %grad
    grad.b = zeros(size(params.b));
    for i = 1:batch_size
        for j = 1:num_filters
            grad.b(j)=grad.b(j)+sum(sum(dv_output(:,:,j,i)));
        end
    end   
    grad.W = zeros(size(params.W));
    input_flip=flip(flip(input,1),2);
    for j=1:num_filters
        for k=1:filter_depth
            for i=1:batch_size
                dv_output_j_i=dv_output(:,:,j,i);
                input_flip_k_i=input_flip(:,:,k,i);
                grad.W(:,:,k,j)=grad.W(:,:,k,j)+conv2(input_flip_k_i,dv_output_j_i,'valid');
            end
        end
    end
end
