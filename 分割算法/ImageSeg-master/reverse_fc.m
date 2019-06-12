function contrib_prev = reverse_fc(l_prev, contrib_curr, weights)
    % l_prev * weights => l_curr
    %weights_prev2curr(weights_prev2curr<0) = 0; %see reverse_conv() for explanation why "relu" the weights
    %forward_pass = l_prev * weights_prev2curr;
    %forward_pass(forward_pass<=0) = -1; %see explanation in reverse_conv()
    %contrib_curr = contrib_curr ./ forward_pass; % do this so that we get percentage contribution
    
    %contrib_curr = contrib_curr .* sqrt(contrib_curr);
    %contrib_curr = contrib_curr / sum(contrib_curr(:));
    %{
    contrib_prev = contrib_curr * weights_prev2curr';
    contrib_prev = contrib_prev .* l_prev;
    contrib_prev(contrib_prev<0) = 0;
    %}


NON_NEG = true;
UNIT_LAYER = true;

l_prev = gpuArray(l_prev);
contrib_curr = gpuArray(contrib_curr);
weights = gpuArray(weights);

    if NON_NEG && UNIT_LAYER
        weights(weights<0)=0;
        l_prev(l_prev>0) = 1;
        contrib_prev = (contrib_curr * weights') .* l_prev;
        contrib_prev = contrib_prev / max(abs(contrib_prev(:)));
        contrib_prev = gather(contrib_prev);
    end
    
    if ~NON_NEG
    
        %------------------------------------------------------pos+neg
        % For all positive elements in contrib_curr
        % positive weights means positive contribution
        % negative weights means negative contribution
        % so just do a normal conv pass with both positve and negative weights

        contrib_curr_pos = contrib_curr;
        contrib_curr_pos(contrib_curr_pos < 0) = 0;
        A = gpuArray(contrib_curr_pos);
        B = gpuArray(weights');
        C = gpuArray(l_prev);
        D = (A * B) .* C;
        contrib_prev_pos = gather(D);


        % For all non positive elements in contrib_curr
        % positive weights means negative contribution
        % negative weights means nothing (something that doesn't contribute to a negative pattern, can be positive or negative)
        % so we get the positive weights only to do the conv pass
        contrib_curr_neg = contrib_curr;
        contrib_curr_neg(contrib_curr_neg > 0) = 0;
        weights_pos = weights;
        weights_pos(weights_pos < 0) = 0;

        A = gpuArray(contrib_curr_neg);
        B = gpuArray(weights_pos');
        C = gpuArray(l_prev);
        D = (A * B) .* C;
        contrib_prev_neg = gather(D);

        % Sum up the pos and neg results
        contrib_prev = contrib_prev_pos-sqrt((-1)*contrib_prev_neg);
        contrib_prev = contrib_prev / max(contrib_prev(:));
    end
    
end