function vect_3d = reverse_flat_reshape(vect_linear,shape)
    %input arg: shape = [num_row, num_col, num_ch]
    num_row = shape(1);
    num_col = shape(2);
    num_ch = shape(3);
    vect_3d = [];
    curr_ind = 1;
    
    for ch=1:num_ch
        curr_layer = [];
        for row=1:num_row
            curr_layer = [curr_layer;vect_linear(curr_ind:curr_ind+num_col-1)];
            curr_ind = curr_ind + num_col;
        end
        vect_3d(:,:,ch) = curr_layer;
    end
end