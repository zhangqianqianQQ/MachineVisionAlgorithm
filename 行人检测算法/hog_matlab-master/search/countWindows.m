function windowCounts = countWindows(hog, img, scaleRange)
%COUNTWINDOWS Counts the number of possible detection windows in the image.	
%  For each image scale in 'scaleRange', count the number of unique 
%  detection windows that fit within the image. This is used simply to
%  predict the number of windows that will need to be processed in the
%  image.
%
%  NOTE: This function does not currently support variable detection window
%        strides. The window is stepped by 1 cell in each direction.
%
%  Parameters:
%    hog            - Structure defining a HOG detector.
%      hog.cellSize - Pixel dimension of a cell (e.g., 8px).
%      hog.numHorizCells - Number of cells across in the descriptor.
%      hog.numVertCells  - Number of cells up and down in the descriptor.
%    img            - The image to be searched.
%    scaleRange     - Vector containing all scales to be searched.
%                     e.g., [1.0, 0.95, 0.90, ... ]
%
%  Returns:
%    windowCounts - Vector containing the number of detector windows in
%                   the image at each of the scales in 'scaleRange'.
%

	% Get the image dimensions.
    % Make sure to read all three dimensions, or 'origImgWidth' will be 
    % wrong.
    [origImgHeight, origImgWidth, depth] = size(img);
	
	% Initialize the windowCounts array.
	windowCounts = zeros(1, length(scaleRange));
	
    % Try progressively smaller scales until a window doesn't fit.
    for i = 1 : length(scaleRange)
        
		% Get the next scale.
		scale = scaleRange(i);
		
        % Compute the scaled img size.
        imgWidth = origImgWidth * scale;
        imgHeight = origImgHeight * scale;
    
        % Compute the number of cells horizontally and vertically for the image.
        numHorizCells = floor((imgWidth - 2) / hog.cellSize);
        numVertCells = floor((imgHeight - 2) / hog.cellSize);
        
        % Break the loop when the image is too small to fit a window.
        if ((numHorizCells < hog.numHorizCells) || ...
            (numVertCells < hog.numVertCells))
            break;
        end
        
        % The number of windows is not quite equal to the number of cells, since
        % you have to stop when the edge of the detector window hits the edge of
        % the image.
        numHorizWindows = numHorizCells - hog.numHorizCells + 1;
        numVertWindows = numVertCells - hog.numVertCells + 1;
        
        % Compute the number of windows at this image scale.
        windowCounts(1, i) = numHorizWindows * numVertWindows;        
    end

end