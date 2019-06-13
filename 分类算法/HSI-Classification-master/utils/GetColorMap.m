function color_map=GetColorMap(num_class)
if (num_class<=0)
    color_map=[];
    return;
end
color_map=zeros(num_class,3);
for ii=1:num_class
    class_idx = ii-1;
    vec_rgb=zeros(1,3);
    for jj=0:7
        vec_rgb(1) = bitor( vec_rgb(1), bitshift(bitget(class_idx,1),7 - jj));
        vec_rgb(2) = bitor( vec_rgb(2), bitshift(bitget(class_idx,2),7 - jj));
        vec_rgb(3) = bitor( vec_rgb(3), bitshift(bitget(class_idx,3),7 - jj));
        class_idx = bitshift(class_idx,-3);
    end
    color_map(ii,:)=vec_rgb;
end

