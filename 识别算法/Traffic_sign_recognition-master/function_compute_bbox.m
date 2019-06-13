function mod_bb= function_compute_bbox(img)

 	%=================================
 	% input   --> read an image
	% output --> compute bounding box
	%=================================



	mod_bb=[];
	



	mod_bb_new=[];
	r_channel=img(:,:,1);
	g_channel=img(:,:,2);
	b_channel=img(:,:,3);


	r_channel=medfilt2(r_channel);
	r_enhanced=imadjust(r_channel,stretchlim(r_channel),[]);

	g_channel=medfilt2(g_channel);
	g_enhanced=imadjust(g_channel,stretchlim(g_channel),[]);

	b_channel=medfilt2(b_channel);
	b_enhanced=imadjust(b_channel,stretchlim(b_channel),[]);

	% this is where the difference from the research paper!!!
	blue_sign_1=max(0, max((b_enhanced-g_enhanced-r_enhanced),(r_enhanced-b_enhanced-g_enhanced)));

	% Detect MSER regions.
	[mserRegions, mserConnComp] = detectMSERFeatures(blue_sign_1,...
	                                                      'RegionAreaRange',[30 14000],...
	                                                      'ThresholdDelta',5.5);
	 
	

	% Use regionprops to measure MSER properties
	mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
	                                        'Solidity', 'Extent', 'Euler', 'Image');
	   

	% Get bounding boxes for all the regions
	bboxes = vertcat(mserStats.BoundingBox);

	if ~ isempty(bboxes)
	%display(bboxes);
	w = bboxes(:,3);
	h = bboxes(:,4);
	% aspectRatio = w./h;
	filterIdx=(w./h)'>1.2;

	% Threshold the data to determine which regions to remove. These thresholds
	% may need to be tuned for other images.
	% filterIdx = aspectRatio' > 1.5;
	filterIdx = filterIdx | [mserStats.Eccentricity] > .85 ;
	filterIdx = filterIdx | [mserStats.Solidity] < .3;
	filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
	filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

	% Remove regions
	mserStats(filterIdx) = [];
	mserRegions(filterIdx) = [];

	
	    
	%  Convert from the [x y width height] bounding box format to the [xmin 
	% ymin   xmax ymax] format for convenience.

	%from left to right limit

	xmin = bboxes(:,1);
	ymin = bboxes(:,2);
	xmax = xmin + bboxes(:,3) - 1;
	ymax = ymin + bboxes(:,4) - 1;
	% Expand the bounding boxes by a small amount.
	expansionAmount = 0.02;
	xmin = (1-expansionAmount) * xmin;
	ymin = (1-expansionAmount) * ymin;
	xmax = (1+expansionAmount) * xmax;
	ymax = (1+expansionAmount) * ymax;

	% Clip the bounding boxes to be within the image bounds
	xmin = max(xmin, 1);
	ymin = max(ymin, 2);
	xmax = min(xmax, size(blue_sign_1,2));
	ymax = min(ymax, size(blue_sign_1,1));

	% Show the expanded bounding boxes
	expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];




	%IExpandedBBoxes = insertShape(img,'Rectangle',expandedBBoxes,'LineWidth',3);
	%figure
	%imshow(IExpandedBBoxes);
	%title('Show Detected Sign')

	% Compute the overlap ratio
	overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

	% Set the overlap ratio between a bounding box and itself to zero to
	% simplify the graph representation.
	n = size(overlapRatio,1);
	overlapRatio(1:n+1:n^2) = 0;

	% Create the graph
	g = graph(overlapRatio);

	% Find the connected text regions within the graph
	componentIndices = conncomp(g);

	% Merge the boxes based on the minimum and maximum dimensions.
	xmin = accumarray(componentIndices', xmin, [], @min);
	ymin = accumarray(componentIndices', ymin, [], @min);
	xmax = accumarray(componentIndices', xmax, [], @max);
	ymax = accumarray(componentIndices', ymax, [], @max);

	% Compose the merged bounding boxes using the [x y width height] format.
	textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

	% Remove bounding boxes that only contain one text region
	numRegionsInGroup = histcounts(componentIndices);
	textBBoxes(numRegionsInGroup == 1, :) = [];
	% aspect ratio
	mod_bb=[];
	scale=1.5;
	for image_index = 1:size(textBBoxes,1)
	    
	    in_box=textBBoxes(image_index,:);
	    height=in_box(1,4)%-in_box(1,2);
	    width=in_box(1,3)%-in_box(1,1);
	    
	    if  ~ (height/width >scale  | width/height > scale)% | (height<=20 &&  width <= 20) )  
	            mod_bb=[mod_bb;in_box];
	            
	    end
	    
	end


	% Show the final text detection result.
	%ITextRegion = insertShape(img, 'Rectangle',  mod_bb,'LineWidth',3);

	%figure
	%imshow(ITextRegion)
	%title('Detected Text')

	end
 end

    
