u%Upload image into matlab 
OGimg = imread('noise_example.jpg');
%Convert the img into greyscale 
bwImg = rgb2gray(OGimg); 



%Have the size of the kernal abstracted 
kernalSize = input('please input kernal size'); 


%expand the img on the edge dependant on the kernalSize 
[mImg, nImg] = size(bwImg);
canvas = zeros(mImg+(ceil(kernalSize/2))); 
[mCanvas, nCanvas] = size(canvas);
offSet = floor(kernalSize/2);
imgStartingPoint = ceil(kernalSize / 2);
imgEndingPoint = nCanvas - floor(kernalSize / 2);
for row = 1 : mCanvas
    for col = imgStartingPoint : imgEndingPoint
        if row < (imgStartingPoint) %if the row number is less than the expanded margin
            canvas(row, col) = bwImg(1, col - offSet);
        elseif row > (imgEndingPoint) %if the row number is more than the expanded margin
                canvas(row, col) = bwImg(mImg, col - offSet);
        else 
            %just copy the same image into the rest of the canvas
            canvas(row, col) = bwImg(row - offSet, col - offSet);
        end 
    end
end

%Now expand the pixels on the size of the canvas 
for row = 1 : mCanvas
    for col = 1 : offSet
        canvas(row, col) = canvas(row, imgStartingPoint);
    end
end

%at this point the image has been successfully expanded 
%Convolute the entire canvas image not from (1,1) but at (3,3) because
%that is the real edge of our original image 


 figure; 
 subplot(1,3,1); 
 imshow(bwImg); 
 subplot(1,3,2); 
 imshow(uint8(canvas));
   
 %create the result canvas 
 resultCanvas = zeros(mImg);
 
 %Loop through the img in canvas and output the result onto resultCanvas
 for row = imgStartingPoint : imgEndingPoint
     for col = imgStartingPoint : imgEndingPoint
         resultCanvas(row - offSet, col - offSet) = neighbourhoodAvg(col, row, kernalSize, canvas);
     end
 end

 subplot(1,3,3);
 imshow(uint8(resultCanvas));
 
 
       
 function avg = neighbourhoodAvg(x, y, kernalSize, canvas)
  kernalMask = horzcat(zeros(kernalSize), zeros(kernalSize));
  maskCentre = ceil(kernalSize/2);
  for tempY = 1 : kernalSize
      for tempX = 1 : kernalSize
        xShift = tempX - maskCentre;
        yShift = tempY - maskCentre;
        %store the xshift in hte kernalMask
        kernalMask(tempY, (tempX*2)-1) = xShift;
        %store the yshift in the kernalMask 
        kernalMask(tempY, tempX*2) = yShift;
      end  
  end
  
  %mask has all the coordinate shifting completed 
  %now get all the values of the window
  accumulator = 0; 
 % subCanvas = zeros(kernalSize);
  for Masky = 1 : kernalSize
      for Maskx = 1 : kernalSize 
          %Apply the shifting from the map onto the coordinates of the
          %pixel passed to this function 
          newX = x + kernalMask(Masky, (Maskx*2)-1);
          newY = y + kernalMask(Masky, (Maskx*2));
          accumulator = canvas(newY, newX) + accumulator;
%          subCanvas(Masky, Maskx) = canvas(newY, newX);
      end
  end
%   subCanvas
%   kernalMask
%   accumulator
  %caluculate the average and return the value 
  avg = round(accumulator / (kernalSize^2));
 end
 
 function massedKernal = weightedKernal(kernalSize)
    weights = zeros(1, kernalSize);
    for i = 1 : kernalSize 
        weights(1, i) = input('please enter the ' + i + 'th weight');
    end
 end
 
 