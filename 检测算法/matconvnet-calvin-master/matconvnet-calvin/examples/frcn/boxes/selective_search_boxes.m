function [boxes, blobIndIm, blobIndBoxes, hierarchy] = selective_search_boxes(im, fast_mode, im_width)
% Girshick Wrapper
%
% Based on the demo.m file included in the Selective Search
% IJCV code.
%
% Requires selective search code.

if ~exist('fast_mode', 'var') || isempty(fast_mode)
  fast_mode = true;
end

originalImSize = size(im);

if ~exist('im_width', 'var') || isempty(im_width)
  im_width = [];
  scale = 1;
else
  scale = size(im, 2) / im_width;
end

if scale ~= 1
  im = imresize(im, [NaN im_width]);
end

% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, ...
                      @SSSimTextureSizeFill, ...
                      @SSSimBoxFillOrig, ...
                      @SSSimSize};

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
% controls size of segments of initial segmentation. 
ks = [50 100 150 300];
sigma = 0.8;

% After segmentation, filter out boxes which have a width/height smaller
% than minBoxWidth (default = 20 pixels).
minBoxWidth = 20;

% Comment the following three lines for the 'quality' version
if fast_mode
  colorTypes = colorTypes(1:2); % 'Fast' uses HSV and Lab
  simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies
  ks = ks(1:2);
end

idx = 1;
for j = 1:length(ks)
  k = ks(j); % Segmentation threshold k
  minSize = k; % We set minSize = k
  for n = 1:length(colorTypes)
    colorType = colorTypes{n};
    [boxesT{idx} blobIndIm{idx} blobIndBoxes{idx} hierarchy{idx} priorityT{idx}] = ...
      Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
    idx = idx + 1;
  end
end
boxes = cat(1, boxesT{:}); % Concatenate boxes from all hierarchies
priority = cat(1, priorityT{:}); % Concatenate priorities

% Do pseudo random sorting as in paper
priority = priority .* rand(size(priority));
[priority sortIds] = sort(priority, 'ascend');
boxes = boxes(sortIds,:);

boxes = BoxRemoveDuplicates(boxes);

if scale ~= 1
  boxes = floor((boxes - 1) * scale + 1);
  for iii = 1:length(blobIndBoxes)
    blobIndBoxes{iii} = floor((blobIndBoxes{iii} - 1) * scale + 1);
    blobIndIm{iii} = imresize(blobIndIm{iii}, [originalImSize(1) originalImSize(2)], 'nearest');
  end
end

% Filter width of boxes
[nr, nc] = BoxSize(boxes);
idsGood = (nr >= minBoxWidth) & (nc >= minBoxWidth);
boxes = boxes(idsGood,:);
