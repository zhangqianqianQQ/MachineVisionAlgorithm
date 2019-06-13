function or_im = pre_pro(or_im)
 
    
    % binarize to highlighted the ridges in the fingerprint
    or_im=imbinarize(or_im);
    %imshow(or_im);
 
    
    % thining to eliminate the redundant pixels of ridges
    or_im=bwmorph(~or_im,'thin','inf');
    %imshow(or_im);
    
    %converting  RGB images to grayscale if it is
    if ndims(or_im) == 3
        or_im = rgb2gray(or_im);
    end
    %imshow(or_im);
