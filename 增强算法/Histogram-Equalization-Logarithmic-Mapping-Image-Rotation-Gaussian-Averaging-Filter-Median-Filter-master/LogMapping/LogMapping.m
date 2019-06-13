% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('building.pnm');


% Display the original image.
figure,imshow(ImageData);
title(' Original Image: ');


% Define constant.
Constant=0.3;


% Create the matrix.
[X,Y]=size(ImageData);

        for a = 1:X
            
            for b = 1:Y
                m=double(ImageData(a,b));
                
                OutputImage(a,b)=Constant.*log10(1+m);
            end
            
        end

        
% Display the output image.
figure, imshow(OutputImage);
title(' Final Image: ');