% edgeProcessing processes edges from given image following steps below.
%
%   * Step 1. Edge detection
% Extracts Edge Map from given image and preprocess it to reduce complexity.
%   * Step 2. Edge Contours extraction 
% Extracts Edge Contours from given Edge Map.
%   * Step 3. Line segment fitting
% Extracts Line Segments fitting on the Edge Contour. 
%   * Step 4. Detecting edge portions with Smooth Curvatures.
% Classify edges using Curvatures so that every edge doesn't have a sudden
% change which is called sharp turn and a inflexion point.
%
% Input     - im : 'jpg' image which taken by normal smart phone.
% Output    - ResizedIm : (possibly) resized image.
%             SmoothCurvatures = The list of edges with Smooth Curvature.
%             Each of them doesn't have any sharp turn and inflexion point.

function [ResizedIm, SmoothCurvatures] = edgeProcessing(im, showFigures)

%% Initialize

% Set default parameters
if nargin < 2
    showFigures = true;
end

% For edge detection.
T_low = 0.2;
T_high = 0.4;
sigma = 1;

% For Line segment fitting.
DeviationThreshold = 2;

% For Smooth Curvatures.
SharpTurnThreshold = 90;

%% Preprocess image

% Resize if input image is too high resolution.
larger_side = max(size(im,1), size(im,2));
max_side = 800;
if larger_side > max_side
    im = imresize(im, max_side/larger_side);
end
ResizedIm = im;

% Convert RGB to gray.
im = rgb2gray(im);
im = histeq(im);

%% Step 1. Edge detection

% Implement Canny edge detection.
EdgeMap = edge(im, 'canny', [T_low, T_high], sigma);

% Apply 'thin' operation to ignore unnecessary parts.
EdgeMap = bwmorph(EdgeMap,'thin',Inf);

% Remove junctions.
[ROW, COL] = size(EdgeMap);
for i = 2:ROW-1
    for j = 2:COL-1
        if EdgeMap(i,j) == 1 && sum(sum(EdgeMap(i-1:i+1,j-1:j+1))) >= 4
            EdgeMap(i-1:i+1,j-1:j+1) = 0;
        end
    end
end

% Remove isolated pixels.
EdgeMap = bwmorph(EdgeMap,'clean');

%% Step 2. Edge Contours extraction

% Extract Edge Contours using preprocessed EdgeMap.
EdgeContours = extractEdgeContours(EdgeMap);

% Draw Edge Contours
if showFigures
    drawLineSegments(size(EdgeMap), EdgeContours);
end

%% Step 3. Line segment fitting 

% Extract Line Segments fitting on the Edge Contour. 
SegmentList = lineSegmentFitting(EdgeContours, DeviationThreshold);

% Draw Segment Lines
if showFigures
    drawLineSegments(size(EdgeMap), SegmentList);
end

%% Step 4. Detecting edge portions with Smooth Curvatures.

% Classify Smooth Curvatures.
SmoothCurvatures = classifySmoothCurvatures(SegmentList, SharpTurnThreshold);

% Draw Smooth Curvatures.
if showFigures
    drawLineSegments(size(EdgeMap), SmoothCurvatures);
end

end
