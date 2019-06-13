function region_im1 = dropSmallRegion(region_im,nb_clr,region_thresh)


region_im1 = region_im;
for nc=1:nb_clr
    if(sum(sum(region_im==nc))<region_thresh)
        region_im1=region_im1.*(region_im1~=nc);
    end
end