% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData = imread('ct_scan.pnm');


% Add noise to oriiginal image.
ImageData = imnoise(ImageData,'Salt & Pepper', 0.04);


% Display the original image.
figure,imshow(ImageData);
title(' Original Image with noise: ');


% Take the input of the angle from user.
Angle = input('Enter the Angle = ');


% Convert the degree to radian.
AngleR = Angle*pi/180;


% Create the conversion matrix.
CMatrix = [+cos(AngleR) +sin(AngleR); -sin(AngleR) +cos(AngleR)];


% Calculate the size of the image.
[X,Y,Z] = size(ImageData);

Temp = round( [1 1; 1 Y; X 1; X Y]*CMatrix );

Temp = bsxfun(@minus, Temp, min(Temp)) + 1;

OutputImage = zeros([max(Temp) Z],class(ImageData));


% Implementation of rotaton function.
for a = 1:size(OutputImage,1)
    
    for b = 1:size(OutputImage,2)
        Rotation = ([a b]-Temp(1,:))*CMatrix.';
        
        if all(Rotation >= 1) && all(Rotation <= [X Y])
            CL = ceil(Rotation);
            
            FL = floor(Rotation);
            
            A = [...
                ((CL(2)-Rotation(2))*(CL(1)-Rotation(1))),...
                ((Rotation(2)-FL(2))*(Rotation(1)-FL(1)));
                
                ((CL(2)-Rotation(2))*(Rotation(1)-FL(1))),...
                ((Rotation(2)-FL(2))*(CL(1)-Rotation(1)))];

            Color = bsxfun(@times, A, double(ImageData(FL(1):CL(1),FL(2):CL(2),:)));
            
            OutputImage(a,b,:) = sum(sum(Color),2);
        end
        
    end
    
end        


% Display the output image.
figure, imshow(OutputImage);
title(' Final Image: ');