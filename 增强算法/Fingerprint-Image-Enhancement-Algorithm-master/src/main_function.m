function [fin_im] =  main_function(or_im)
    
 
    % PREPROCESSING
        or_im = pre_pro(or_im);
     
    
    % NORMALIZE
        or_im = normal(or_im,1);
    
       
    % SEGMENTATION
        blksze = 15; thresh = 0.08;
        [norm_im, mask] = segmentation(or_im, blksze, thresh);
 
    
    % DIFFUSION
        norm_im = diffusion(norm_im);
    
  
    % ORIENTATION
        [orientim, G_xx, G_yy, G_xy, cos2theta, sin2theta, denom] = orient(norm_im, 1, 5, 6);
    %    showorient(orientim, 20);
    
    
    % RELIABILTY
        reliability = reliability_f(G_xx, G_yy, G_xy, cos2theta, sin2theta, denom);
    
    
    % FREQUENCY
        [freq] = frequency(norm_im, mask, orientim, 33, 5, 4, 14);
    
    
    % GABOR FILTERS
        gabor_im = gabor(freq);
    
    % MORE FILTERS FOR RIDGE PATTERNS
        new_im = more_filter(norm_im, orientim, gabor_im, 0.5, 0.5);
    
 
    % BINARISE
        thres = 0;
        binim = binarise(new_im, thres);
    
    
    % Applying reliabilty factor to the final enhanced image
        rel = 0.5;  % reliability factor (above 0.5 is considered to be reliable)
        %binim = binim.*mask.*(reliability>rel);
        
    fin_im = imcomplement(binim);
