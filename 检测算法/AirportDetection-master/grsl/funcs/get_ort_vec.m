function ort_vec = get_ort_vec(lew_rgb,mask_local)
% compute the mean color w.r.t pixels covered by the binary saliency mask 
    [ii,jj] = find(mask_local~=0);
    ort_vec = zeros(1,3); % RGB color vector
    for k = 1 : length(ii)
        ort_vec(1,1) = ort_vec(1,1) + lew_rgb(ii(k),jj(k),1);
        ort_vec(1,2) = ort_vec(1,2) + lew_rgb(ii(k),jj(k),2);
        ort_vec(1,3) = ort_vec(1,3) + lew_rgb(ii(k),jj(k),3);
    end
    ort_vec = ort_vec / length(ii);
end

