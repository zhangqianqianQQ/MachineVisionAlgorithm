function vect_linear = flat_reshape(vect_3d)
    vect_linear = [];
    s = size(vect_3d);
    num_ch = s(3);
    for ch=1:num_ch
        for i=1:s(1)
            temp = squeeze(vect_3d(i,:,ch));
            vect_linear = [vect_linear temp];
        end
    end
            
end