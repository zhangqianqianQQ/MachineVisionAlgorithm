function [ out ] = GetStartingCluster( image, s, w )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

height = size(image,1);
width = size(image,2);
boxes = ones(height/s,width/s);
imshow(OutlineRegion(image,boxes));
[x,y] = ginput;
i = floor(y/s)+1;
j = floor(x/s)+1;
out = zeros(256/w,3,length(i));
for k=1:length(i)
    out(:,:,k) = SimpleHist1D(image((i(k)-1)*s+1:i(k)*s,(j(k)-1)*s+1:j(k)*s,:),w);
end

end

