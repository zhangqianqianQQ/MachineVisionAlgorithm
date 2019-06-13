function feat = extract_feature(image)
%% Description
% This function takes one image as input and returns HOG feature.
%
% Input: image
% Following VLFeat instruction, the input image should be SINGLE precision. 
% If not, the image is automatically converted to SINGLE precision.
%
% Output: feat
% The output is a vectorized HOG descriptor.
% The feature demension depends on the parameter, cellSize.
%
% VLFeat must be added to MATLAB search path. Please check the link below.
% http://www.vlfeat.org/install-matlab.html


%% check input data type
if ~isa(image, 'single'), image = single(image); end;


%% extract HOG 
cellSize = 8;
hog = vl_hog(image, cellSize, 'verbose');
imhog = vl_hog('render', hog, 'verbose');
clf; imagesc(imhog); colormap gray;


%% feature - vectorized HOG descriptor
feat = hog(:);

end