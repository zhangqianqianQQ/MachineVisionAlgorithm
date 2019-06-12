function contrib_prev = reverse_conv_original_img(l_prev, contrib_curr, weights)
    %we can be sure that all l_prev is positive, and we don't need negative
    %tensor flows to normalize the positive ones
    %weights(weights<0) = 0; 

    %normalize contrib_curr with its original input to get percentage
    %contribution
    %forward_pass = forward_conv(l_prev,weights);
    %to handle 0/0 case, we set all non-positive forward_pass element as -1
    %rationale being that we had removed all negative tensor flows by doing
    %weights(weights<0)=0, if the result is 0, then it must be originally
    %also 0 (because originally we didn't remove the negative flows so the 
    %result will be negative, which is 0 after relu), so 0/0 will happen in
    %the element-wise division step below. To prevent this, set
    %non-positive elements in forward_pass to -1 so that it becomes 0/-1.
    %The answer is 0 which is the desired behavior (because 0% contribution
    %is what it deserves)
    % that way
    %forward_pass(forward_pass<=0) = -1;
    %contrib_curr = contrib_curr ./ forward_pass;

    l_prev(l_prev>0) = 1;
    l_prev(l_prev<0) = 1;
    new_weights = deconv_weights(weights);
    %new_weights(new_weights<0) = 0;
    contrib_prev = my_vl_conv(contrib_curr, new_weights, []);
    contrib_prev = contrib_prev .* l_prev;
    %contrib_prev(contrib_prev<0) = 0;
end