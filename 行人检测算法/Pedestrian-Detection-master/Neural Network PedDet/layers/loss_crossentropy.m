% ----------------------------------------------------------------------
% input: num_nodes x batch_size
% labels: batch_size x 1
% ----------------------------------------------------------------------

function [loss, dv_input] = loss_crossentropy(input, labels, hyper_params, backprop)
assert(max(labels) <= size(input,1));
% TODO: CALCULATE LOSS
loss = 0;
n=size(input,2);
for i=1:n
    x_i=log(input(:,i)); %size:num_nodes x 1
    right_label_i=labels(i);
    label_i=zeros(size(input,1),1);
    label_i(right_label_i,1)=1;
    loss=loss-(x_i'*label_i);
end
loss=loss/n;
dv_input = zeros(size(input));
if backprop
    % TODO: BACKPROP CODE
    for i=1:n
        dv_input(labels(i),i)=-1/input(labels(i),i);
    end
    dv_input=dv_input/n;
end
