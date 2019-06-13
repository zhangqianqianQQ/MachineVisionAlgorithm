function img=myhisteq(img)

    img = rgb2hsv(img);
    img(:,:,3) = histeq(img(:,:,3));
    img=hsv2rgb(img);
    img=uint8(img*255);

end