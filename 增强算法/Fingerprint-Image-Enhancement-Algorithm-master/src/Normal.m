function n = normal(or_im,option)
 
if(option == 1)
   
    or_im = im2double(or_im);
    
    or_im = or_im - mean(or_im(:));
    or_im = or_im / std(or_im(:));
   % imshow(or_im);
    %zero mean, unit std dev
    n = 0 + or_im*sqrt(1);
    
    
   
elseif (option == 2)
    
    or_im = (or_im - mean2(or_im))./std2(or_im);
        n = 0 + or_im*sqrt(1);
end

