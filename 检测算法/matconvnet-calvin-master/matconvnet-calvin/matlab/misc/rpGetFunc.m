function[rpFunc] = rpGetFunc(proposalName)
% [rpFunc] = rpGetFunc(proposalName)
%
% Define region proposal function.
%
% Copyright by Holger Caesar, 2015

if strcmp(proposalName, 'Felzenszwalb2004'),
    rpFunc = @(dataset, imageName, image, varargin) rpFelzenszwalb2004(image, varargin{:});
elseif strcmp(proposalName, 'GroundTruth'),
    rpFunc = @(dataset, imageName, image, varargin) rpGroundTruth(dataset, imageName, varargin{:});
elseif strcmp(proposalName, 'Uijlings2013'),
    rpFunc = @(dataset, imageName, image, varargin) rpUijlings2013(image, varargin{:});
else
    error('Error: Unknown segmentation specified!');
end;