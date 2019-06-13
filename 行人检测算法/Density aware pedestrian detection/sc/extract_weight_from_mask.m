function mask_weight= extract_weight_from_mask(mask,mask_filter,bi_value)

if(~exist('bi_value','var'))
    bi_value=0;
end
[imgh,imgw] = size(mask);

[fr,fc,fn]  = size(mask_filter);

mask_weight = fft2_filt(mask, mask_filter);
mask_weight = reshape(mask_weight, imgh*imgw, fn);

if(bi_value)
    mask_weight = double(mask_weight>0.5);
else
    mask_sum    = sum(sum(mask_filter));
    mask_sum    = mask_sum(:);
    mask_weight = spmtimesd(sparse(mask_weight),1./mask_sum,[]);
    mask_weight = double(mask_weight);
end
