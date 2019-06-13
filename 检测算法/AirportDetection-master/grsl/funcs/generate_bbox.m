function bbox = generate_bbox(img,obj_contour)
    bbox = img;
    [ii,jj] = find(obj_contour~=0);
    i_min = min(ii);
    i_max = max(ii);
    j_min = min(jj);
    j_max = max(jj);
    color = [255,0,0];
    for channel = 1 : 3
        bbox([i_min,i_min-1,i_max,i_max+1],j_min:j_max,channel) = color(channel);
        bbox(i_min:i_max,[j_min,j_min-1,j_max,j_max+1],channel) = color(channel);
    end
end

