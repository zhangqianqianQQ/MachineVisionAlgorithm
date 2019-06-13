function saveWindows( rects, frameDir, imgFile )
%SAVEWINDOWS Summary of this function goes here
%   Detailed explanation goes here

% Extract the name of the file (without .png extension)
name = imgFile(1:(length(imgFile) - 4));    

% Construct the path to the windows dir and create it.
if (saveWindows)
    windowDir = strcat(frameDir, name, '_windows\\');
    mkdir(windowDir);
end



for i = 1 : size(rects, 1)
    
    % TODO - This rectangle is relative to the original image rather
    % then the scaled version...
    origWindow = rects(i, :);
    
    %{
    % This is the conversion code used to go from the scaled image 
    % rectangle to the original image rectangle.
    origX = round(xstart / scale);
    origY = round(ystart / scale);

    origWidth = round(windowWidth / scale);
    origHeight = round(windowHeight / scale);
	%}				
    
    % Construct the filename for the window.
    scaleStr = num2str(round(scale * 100));					
    windowName = strcat(name, '_scale', scaleStr, '_x', num2str(xstart), '_y', num2str(ystart));

    windowNames{size(resultRects, 1)} = windowName;
                    
    % Compute the range of rows and columns to select.
    yrange = ystart : (ystart + windowHeight - 1);
    xrange = xstart : (xstart + windowWidth - 1);

    % Select the image.
    imgWindow = img(yrange, xrange);

    % Save out the image.
    windowFile = strcat(windowDir, windowName, '.png');
    imwrite(imgWindow / 255, windowFile);

    % Save out the descriptor.
    %descFile = strcat(windowDir, windowName, '.mat');
    %save(descFile, 'H');

end    


end

