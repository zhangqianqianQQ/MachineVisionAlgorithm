function[blobs] = rpFelzenszwalb2004(image, varargin)
% [blobs] = rpFelzenszwalb2004(image, varargin)
%
% Create a list of region proposals (blobs) of an image using the method of Felzenszwalb and Huttenlocher 2004.
% 
% For information on the returned blobs see blob().
%
% Copyright by Holger Caesar, 2014

% Parse input
p = inputParser;
addParameter(p, 'sigma', 0.8);  % From IJCV paper Tighe
addParameter(p, 'k', 200);      % From IJCV paper Tighe
addParameter(p, 'minSize', []); % By default this is set to be equal to k. (as done in Selective Search)
addParameter(p, 'colorTypes', {'Rgb'});
parse(p, varargin{:});

sigma = p.Results.sigma;
k = p.Results.k;
minSize = p.Results.minSize;
colorTypes = p.Results.colorTypes;

% Set minsize to k if nothing is set
if isempty(minSize),
    minSize = k;
end;

% Convert to 8 bit (necessary for mex code)
image = im2uint8(image);

% Convert to correct colorType
assert(iscell(colorTypes));
assert(numel(colorTypes) == 1);
if ~strcmp(colorTypes, 'Rgb')
    [~, image] = Image2ColourSpace(image, colorTypes{1});
end

% Create segmentation (same version as in Selective Search code)
regionMap = mexFelzenSegmentIndex(image, sigma, k, minSize);

% Initialize
blobCount = max(regionMap(:));
blobs = cell(blobCount, 1);

for blobIdx = 1 : blobCount,
    % Create blob
    iMask = regionMap == blobIdx;
    
    % Convert pixel mask to blob
    blob = maskToBlob(iMask);
    
    % Store result
    blobs{blobIdx} = blob;
end;

% Convert to col struct
blobs = [blobs{:}];
blobs = blobs(:);