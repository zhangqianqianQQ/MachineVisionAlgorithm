function new_im = more_filter(or_im, orient, freq, kx, ky)
    
    a_inc = 2;
    
    or_im = double(or_im);
    [row, col] = size(or_im);
    new_im = zeros (row,col);
    
    [validrow,validcol] = find(freq > 0);
    ind_im = sub2ind([row,col], validrow, validcol);
 
    freq(ind_im) = round(freq(ind_im) * 100) / 100;
    
    unique_freq = unique(freq(ind_im)); 
    
    freq_i = ones(100,1);
    for l_k = 1:length(unique_freq)
        freq_i(round(unique_freq(l_k)*100)) = l_k;
    end
    
    filter = cell(length(unique_freq),180/a_inc);
    l_z = zeros(length(unique_freq),1);
    
    for l_k = 1:length(unique_freq)
        sigma_x = 1/unique_freq(l_k)*kx;
        sigma_y = 1/unique_freq(l_k)*ky;
        
        l_z(l_k) = round(3*max(sigma_x,sigma_y));
        [x,y] = meshgrid(-l_z(l_k):l_z(l_k));
        ref_filter = exp(-(x.^2/sigma_x^2 + y.^2/sigma_y^2)/2).*cos(2*pi*unique_freq(l_k)*x);
 
        for l_o = 1:180/a_inc
            filter{l_k,l_o} = imrotate( ref_filter,-(l_o*a_inc+90),'bilinear','crop'); 
        end
    end
 
 
 
    max_size = l_z(1);    
    final_ind = find(validrow>max_size & validrow<row-max_size & validcol>max_size & validcol<col-max_size);
    
    
    max_orient_index = round(180/a_inc);
    orient_index = round(orient/pi*180/a_inc);
    i = find(orient_index < 1);   orient_index(i) = orient_index(i)+max_orient_index;
    i = find(orient_index > max_orient_index); 
    orient_index(i) = orient_index(i)-max_orient_index; 
 
    for l_k = 1:length(final_ind)
        l_r = validrow(final_ind(l_k));
        l_c = validcol(final_ind(l_k));
 
        f_index = freq_i(round(freq(l_r,l_c) * 100));
        
        f_s = l_z(f_index);   
        new_im(l_r,l_c) = sum(sum(or_im(l_r-f_s:l_r+f_s, l_c-f_s:l_c+f_s).*filter{f_index,orient_index(l_r,l_c)}));
    end
 
