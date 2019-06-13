function [ image ] = DeleteWindowsImage(image,binaryImage)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
discHeight = size(binaryImage,1);
discWidth = size(binaryImage,2);
Height = size(image,1);
s = Height/discHeight;

for i=1:discHeight
    for j=1:discWidth
        if (binaryImage(i,j)==1)
            image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:) = 0;
        end
    end
end

end

