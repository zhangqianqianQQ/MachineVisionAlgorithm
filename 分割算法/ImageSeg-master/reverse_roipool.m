function contrib_prev = reverse_roipool(ft_map, pooled, contrib_pooled)

    %im_size = [rows, cols]
    
    %roi = [0, im_col_start, im_row_start, im_col_end, im_row_end]
    %ft_map has size  ?* ?*512ch
    %pooled has size  7* 7*512ch
    ft_map_size = size(ft_map);
    
    
    %algo: 
    %for each non-zero element in pooled
    %  find ft_map element(s) that has the same value (in the same layer)
    %  if multiple elements have the same value (in the same layer), get the
    %              locationally closest element, raise warning
    %  get the location of the element
    %  set that location to 1 in activation map(size 37*37*512)
    contrib_prev = zeros(ft_map_size);
    
    non_zero_ind_linear = find(pooled~=0);
    %sum(contrib_pooled(non_zero_ind_linear))
    for i = 1:length(non_zero_ind_linear)
        [I,J,K] = ind2sub([7,7,512], non_zero_ind_linear(i));
        ft_ind_linear_inlayer_K = find(squeeze(ft_map(:,:,K)) == pooled(I,J,K));
        if 1 ~= length(ft_ind_linear_inlayer_K)
            disp('warning: roipool_activation_mask: duplicate activation')
        end
        [P,Q] = ind2sub([ft_map_size(1),ft_map_size(2)], ft_ind_linear_inlayer_K);
        contrib_prev(P,Q,K) = contrib_prev(P,Q,K) + contrib_pooled(I,J,K);
        
    end
    contrib_prev = contrib_prev / max(contrib_prev(:));

end