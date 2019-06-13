function [ image ] = OutlineRegion( image, componentImage )
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

height = length(image(:,1));
width = length(image(1,:));
H = length(componentImage(:,1));
W = length(componentImage(1,:));
s = height/(H);

for i=1:H
    for j=1:W
        if (componentImage(i,j)==1)
            %image=OutlinePixel2(image,s,i,j,height,width,componentImage(i-1,j),componentImage(i,j+1),componentImage(i+1,j),componentImage(i,j-1));  %OUTLINE
            image = OutlinePixel(image,s,i,j,height,width);  %GRID
        end
    end
end


end

