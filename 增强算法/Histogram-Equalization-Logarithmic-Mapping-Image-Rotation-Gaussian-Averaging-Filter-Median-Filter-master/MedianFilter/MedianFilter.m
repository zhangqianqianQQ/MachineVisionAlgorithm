% Flush out the MATLAB.
close all;
clc;
clear all;


% Read the desired image file.
ImageData=imread('auto.pnm');


% Display the original image.
figure,imshow(ImageData);
title(' Original Image: ');


% Insert Padding.
NewImage=zeros(size(ImageData)+2);

OutputImage=zeros(size(ImageData));

% Combine the images.
for c=1:size(ImageData,1)
    
    for d=1:size(ImageData,2)
        NewImage(c+1,d+1)=ImageData(c,d);
    end
    
end

      
% Filtering.
for a= 1:size(NewImage,1)-2
    
    for b=1:size(NewImage,2)-2        
        NewWindow=zeros(9,1);
        
        Increment=1;
        
        for c=1:3
            
            for d=1:3
                NewWindow(Increment)=NewImage(a+c-1,b+d-1);
                
                Increment=Increment+1;
            end
            
        end
       
        med=sort(NewWindow);
        
        OutputImage(a,b)=med(5);       
    end
end


% Display the output image.
OutputImage = uint8(OutputImage);

figure,imshow(OutputImage);
title(' Final Image: ');