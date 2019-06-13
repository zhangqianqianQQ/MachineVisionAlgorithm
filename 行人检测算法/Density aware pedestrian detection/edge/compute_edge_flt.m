function [ edge_map,theta_map ] = compute_edge_flt( img, para )


if(~exist('para','var'))
    para.edge_filter_size=21;
    para.edge_filter_ori=8;
    para.edge_filter_scale=[4];% [1,2,4];
    para.edge_range     = [eps,1.1];
    para.edge_bivalue   = 1;
end

[FBo,FBe]=getFBoFBe(para.edge_filter_size, para.edge_filter_ori,para.edge_filter_scale);

img = im2double(img);

if(size(img,3)>1)
	img = rgb2gray(img);
end

img = rescaleImage(img);

im_odd      = fft2_filt(img,FBo);
im_even     = fft2_filt(img,FBe);
[edge_map,theta_map]=getOriAndEdge(im_odd,im_even,para.edge_range);
edge_map    = rescaleImage(edge_map);

