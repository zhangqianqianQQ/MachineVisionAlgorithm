function [resultRects] = searchImage(hog, origImg)
%SEARCHIMAGE Applys a HOG person detector to find persons in the image.
%  This function searches the supplied image for persons at multiple 
%  scales. 
%
%  The HOG descriptor window is never resized--instead, the image is 
%  resized. We rescale the image many times--each image scale is 5% smaller
%  than the previous one. We repeat this until the resulting image is too 
%  small to fit even a single descriptor. At image scale 1.00 (the 
%  largest), we are looking for persons who are small within in the image 
%  (farther from the camera). At the smaller image scales (e.g., 0.20), we 
%  are looking for persons who appear larger in the image (closer to the 
%  camera).
%
%  For each scale, the image is resized (downsampled), then HOG descriptors
%  are calculated for every possible detection window in the resized image.
%  The HOG descriptors are fed to the linear classifier to determine
%  whether their detection window contains a person. The detection window
%  is a match if the classifier confidence is above hog.threshold.   
%
%  NOTE: This function does not currently support variable detection window
%        strides. The window is stepped by 1 cell in each direction. 
%        Stepping by one cell (as opposed to a smaller number of pixels) 
%        significantly reduces the number of histograms we must calculate.
%        The functions 'getHistogramsForImage' and
%        'getDescriptorFromHistograms' are also built on this assumption.
%
%  Parameters:
%    hog             - Structure defining the HOG detector. 
%      hog.theta     - Trained linear classifier.
%      hog.threshold - Detect person if confidence > hog.threshold.
%    origImg         - The image to be searched.
%
%  Returns:
%    resultRects - A matrix of all the rectangular detection windows which
%                  were identified as persons. Each result is a row vector:
%                    [top-left-x, top-left-y, width, height, p]
%                  The coordinates and dimensions of the detection windows 
%                  are supplied relative to the original image dimensions.
%                  The value 'p' is the output of the linear classifier 
%                  (the classifier confidence).

	% Save all of the results
	resultRects = [];
    
	% Compute the scale range to match OpenCV.
	scaleRange = zeros(64);
	scale = 1.0;
	for i = 1 : 64
		scaleRange(i) = scale;
		scale = scale / 1.05;
	end
		  
	% Count the total number of windows to be searched.
    windowCounts = countWindows(hog, origImg, scaleRange);
	totalWindows = sum(windowCounts);

	fprintf('Searching %d detection windows...\n', totalWindows);

	% Track the number of windows we've processed in this image.
	windowCountImg = 0;

	% For each of the image scales...
	for i = 1 : length(scaleRange)
        
		% Get the next scale value.
		scale = scaleRange(i);    

        % Stop the search if this scale is too small to fit even a single 
        % window.
        if (windowCounts(i) == 0)
           fprintf('  Image scale %.2f is not large enough for descriptor, stopping search.\n', scale);
           break;
        end
        
		fprintf('  Image Scale %.2f, %d windows - ', scale, windowCounts(i));
		
		% Scale the image.
		if (scale == 1)
			img = origImg;
		else
			img = imresize(origImg, scale);
        end
		        
		% Convert to grayscale by averaging the three color channels.
		img = mean(img, 3);
		
        windowsAtScale = 0;
        
		% ================================================
		%          Compute Histograms Over Image
		% ================================================
		
		% Compute all of the un-normalized histograms for the image.
		% The image is cropped to be an even multiple of the cell size, plus a 1-pixel
		% border all the way around. xoffset and yoffset are the pixel coordinates in 
		% the original image of the cropped region, including the 1-pixel border. 
		% They specify the top left corner of the 1-pixel border around the cropped
		% image.
		[allHistograms, xoffset, yoffset] = getHistogramsForImage(hog, img);

		cellRow = 1;
		
		% For each row of the image...
		while((cellRow + hog.numVertCells - 1) <= size(allHistograms, 1))

			% Compute the range of rows to select.
			cellRowRange = cellRow : (cellRow + hog.numVertCells - 1);
			
			% Reset the cellCol position.
			cellCol = 1;
					
			% For each column of the image...
			while ((cellCol + hog.numHorizCells - 1) <= size(allHistograms, 2))
			
				% ====================================
				%             Get Descriptor
				% ====================================
				
				% Compute the range of columns to select.
				cellColRange = cellCol : (cellCol + hog.numHorizCells - 1);
			
				% Select the histograms for the next detection window.
				histograms = allHistograms(cellRowRange, cellColRange, :);
			
				% Compute the HOG descriptor.
				H = getDescriptorFromHistograms(hog, histograms);
								
				% Take the transpose to make it a row vector.
				H = H';
				
				% ====================================
				%           Detect Person
				% ====================================
				
				% Apply the linear SVM.
    			p = H * hog.theta;
				
				% If we recognize the histogram as a person...
				if (p > hog.threshold)
			
					% ================================
					%        Add Result
					% ================================
					
					% Compute the coordinate of the top left corner of this detection 
					% window. Because the 'offset' values point to the 1-cell border, the 
					% 'start' values also point to the location of the 1-cell border for 
					% this detection window. These coordinates assume the cell dimensions
					% specified as the arguments to this function (not necessarily 8x16). 
					% These coordinates apply to the original, uncropped image.
					xstart = xoffset + ((cellCol - 1) * hog.cellSize);
					ystart = yoffset + ((cellRow - 1) * hog.cellSize);

					%fprintf('    Found match at: %d, %d    conf: %f\n', xstart, ystart, p);
					
					% Compute the detection window coorindate and size 
                    % relative to the original image scale.
					origX = round(xstart / scale);
					origY = round(ystart / scale);
					origWidth = round(hog.winSize(2) / scale);
					origHeight = round(hog.winSize(1) / scale);
					
					% Add the rectangle to the results.
					resultRects = [resultRects; 
                                   origX, origY, origWidth, origHeight, p];
				end               

				% Increment the count of windows processed.
				windowCountImg = windowCountImg + 1;

                windowsAtScale = windowsAtScale + 1;
                
				% Move to the next column of the image.
				cellCol = cellCol + 1;
			end
			
			cellRow = cellRow + 1;
        end
        
        fprintf('%d matches total, %.1f%% done\n', size(resultRects, 1), windowCountImg / totalWindows * 100.0);
        assert(windowsAtScale == windowCounts(i));
	end

% End function
end