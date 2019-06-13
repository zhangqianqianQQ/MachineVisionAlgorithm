function[blobs] = rpUijlings2013(image, varargin)
% [blobs] = rpUijlings2013(image, varargin)
%
% Create a list of region proposals (blobs) of an image using the method of Uijlings2013.
%
% For information on the returned blobs see blob().
%
% Copyright by Holger Caesar, 2014

% Parse input
p = inputParser;
% Default settings suggested by Jasper
addParameter(p, 'ks', [50, 100]);
addParameter(p, 'sigma', 0.8);
addParameter(p, 'colorTypes', {'Hsv', 'Lab'});
addParameter(p, 'simFunctionHandles', {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill});
parse(p, varargin{:});

ks = p.Results.ks;
sigma = p.Results.sigma;
colorTypes = p.Results.colorTypes;
simFunctionHandles = p.Results.simFunctionHandles;

% Init SS
hierarchyCount = numel(ks) * numel(colorTypes) * numel(simFunctionHandles);
blobs = cell(hierarchyCount, 1);
priorities = cell(hierarchyCount, 1);
hBlobsInd = 1;

% Perform Selective Search on all parameter combinations
for ksInd = 1 : numel(ks),
    for colorTypeInd = 1 : numel(colorTypes),
        for simHndsI = 1 : numel(simFunctionHandles),
            % Compute hierarchical grouping with current settings
            [~, blobIndIm, blobBoxesInIm, hierarchy, priority] = Image2HierarchicalGrouping(image, sigma, ks(ksInd), ks(ksInd), colorTypes{colorTypeInd}, simFunctionHandles(simHndsI));
            
            % Convert boxes to blobs (when there is only one blob, we can't
            % create a hierarchy, i.e. for k=400)
            if isempty(hierarchy),
                blobs{hBlobsInd} = RecreateBlobHierarchyIndIm(blobIndIm, blobBoxesInIm, []);
            else
                blobs{hBlobsInd} = RecreateBlobHierarchyIndIm(blobIndIm, blobBoxesInIm, hierarchy{1});
            end;
            
            % Store priority
            priorities{hBlobsInd} = priority;
            hBlobsInd = hBlobsInd + 1;
        end;
    end;
end;

% Put all parameter results in a single cell array
blobs = flattenCellArray(blobs);
priorities = flattenCellArray(priorities);

% Do pseudo random sorting as in paper
priorities = priorities .* rand(size(priorities));
[~, sortIds] = sort(priorities, 'ascend');
blobs = blobs(sortIds, :);

% Convert to col struct
blobs = [blobs{:}];
blobs = blobs(:);