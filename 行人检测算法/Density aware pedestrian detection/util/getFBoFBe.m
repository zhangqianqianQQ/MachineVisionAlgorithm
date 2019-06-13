function [FBo,FBe] = getFBoFBe(filter_size, filter_ori,filter_scale)
%
%
%
if(~exist('filter_size'))
    filter_size = 21;
end
if(~exist('filter_ori'))
    filter_ori = 8;
end
if(~exist('filter_scale'))
    filter_scale = [1,2,4];
end

FBo = make_FB_odd2(filter_ori,filter_scale,filter_size);
FBe = make_FB_even2(filter_ori,filter_scale,filter_size);

