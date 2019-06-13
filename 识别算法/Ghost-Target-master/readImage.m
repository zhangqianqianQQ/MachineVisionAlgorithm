function data = readImage(img)
    data.intensity = mean2(img);
    data.red = mean2(img(:,:,1));
    data.green = mean2(img(:,:,2));
    data.blue = mean2(img(:,:,3));
    
    gimg = rgb2gray(img);
    range = rangefilt(gimg);
    std = stdfilt(gimg);
    entropy = entropyfilt(gimg);
    
    data.mean_range = mean2(range);
    data.std_range = std2(range);
    data.mean_std = mean2(std);
    data.std_std = std2(std);
    data.mean_entropy = mean2(entropy);
    data.std_entropy = std2(entropy);

end