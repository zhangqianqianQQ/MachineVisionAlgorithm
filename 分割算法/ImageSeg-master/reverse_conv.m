function contrib_prev = reverse_conv(l_prev, contrib_curr, weights)

NON_NEG = true;
UNIT_LAYER = true;

new_weights = deconv_weights(weights);
   
    if NON_NEG && UNIT_LAYER
        new_weights(new_weights<0) = 0;
        l_prev(l_prev>0)=1;
        contrib_prev = my_vl_conv(contrib_curr, new_weights, []);
        contrib_prev = gather(gpuArray(contrib_prev) .* gpuArray(l_prev));
        contrib_prev = contrib_prev / max(abs(contrib_prev(:)));
    end
    
    if ~NON_NEG
        % For all positive elements in contrib_curr
        % positive weights means positive contribution
        % negative weights means negative contribution
        % so just do a normal conv pass with both positve and negative weights
        contrib_curr_pos = contrib_curr;
        contrib_curr_pos(contrib_curr_pos < 0) = 0;
        contrib_prev_pos = my_vl_conv(contrib_curr_pos, new_weights, []);
        ontrib_prev_pos = contrib_prev_pos .* l_prev;


        % For all non positive elements in contrib_curr
        % positive weights means negative contribution
        % negative weights means nothing (something that doesn't contribute to a negative pattern, can be positive or negative)
        % so we get the positive weights only to do the conv pass
        contrib_curr_neg = contrib_curr;
        contrib_curr_neg(contrib_curr_neg > 0) = 0;
        new_weights_pos = new_weights;
        new_weights_pos(new_weights_pos < 0) = 0;
        contrib_prev_neg = my_vl_conv(contrib_curr_neg, new_weights_pos, []);
        contrib_prev_neg = contrib_prev_neg .* l_prev;

        % Sum up the pos and neg results
        contrib_prev = contrib_prev_pos - sqrt((-1)*contrib_prev_neg);
        contrib_prev = contrib_prev / max(contrib_prev(:));
    end
    
end

    %{
    %{
    we can be sure that all l_prev is positive, and we don't need negative
    tensor flows to normalize the positive ones
    %}
    weights(weights<0) = 0; 

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

    %}
    %contrib_curr = contrib_curr .* sqrt(contrib_curr);
    %contrib_curr = contrib_curr / sum(contrib_curr(:));
    