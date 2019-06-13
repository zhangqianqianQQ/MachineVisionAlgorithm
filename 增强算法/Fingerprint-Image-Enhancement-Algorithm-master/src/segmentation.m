function [norm_im, mask] = segmentation(or_im, blksze, thr)
    
 
    fun = inline('std(x(:))*ones(size(x))');
    
    std_devim = blkproc(or_im, [blksze blksze], fun);
    
    
    mask = std_devim > thr;
    mask_i = find(mask);
    
    
    or_im = or_im - mean(or_im(mask_i));
    norm_im = or_im / std(or_im(mask_i));    
    
    %imshow(normim);
