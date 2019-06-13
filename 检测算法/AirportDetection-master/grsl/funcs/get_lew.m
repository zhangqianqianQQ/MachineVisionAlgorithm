function [i_min,i_max,j_min,j_max,lew] = get_lew(img,smap_b)
% cut a local window from the original img, and also return 
% lew's coordinates in the original img

    [all_i,all_j] = find(smap_b~=0);
    rescale = 0.2;
    i_min = round(min(all_i)*(1-rescale));   
    i_max = round(max(all_i)*(1+rescale));    
    j_min = round(min(all_j)*(1-rescale));   
    j_max = round(max(all_j)*(1+rescale)); 
    
    img_size = size(img(:,:,1));
    [i_min,i_max,j_min,j_max] = handle_cross_boundary(i_min,i_max,j_min,j_max,img_size);
    lew = img(i_min:i_max,j_min:j_max,:);
end

