function contrib_prev = reverse_max_vl(l_prev, contrib_curr)
    contrib_prev = vl_nnpool(l_prev, [2,2], contrib_curr, 'Stride', 2);
end