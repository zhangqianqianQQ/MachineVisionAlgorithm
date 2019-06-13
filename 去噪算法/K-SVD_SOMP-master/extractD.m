function Dstep = extractD(Dout)
Dstep = zeros(145,145,3,size(Dout,3));
for i = 1:size(Dout,3)
    I = displayDictionaryElementsAsImage(Dout(:,:,i), floor(sqrt(256)), floor(size(Dout(:,:,i),2)/floor(sqrt(256))),8,8,0);
    I = I-min(min(min(I)));
    I = I./max(max(max(I)));
    Dstep(:,:,:,i) = I;
end
figure;
for i = 1:size(Dout,3)
    subplot(3,5,i);
    imshow(Dstep(:,:,:,i),[]);
end
end