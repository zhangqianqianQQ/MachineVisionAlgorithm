function setupE2S2Regions(varargin)
% setupE2S2Regions(varargin)
%
% Bundles all pre-processing steps to extract region proposals and labels
% (our method requires Selective Search and Felzenszwalb
% oversegmentations). This can take about an hour for a medium-sized
% dataset (3K images).
%
% Copyright by Holger Caesar, 2016

% Parse input
p = inputParser;
addParameter(p, 'dataset', SiftFlowDatasetMC());
addParameter(p, 'colorSpaces', {'Rgb', 'Hsv', 'Lab'});
parse(p, varargin{:});

dataset = p.Results.dataset;
colorSpaces = p.Results.colorSpaces;

% Settings
global glFeaturesFolder;
segmentationsFolder = fullfile(glFeaturesFolder, 'WeaklySupervisedLearning', dataset.name, 'segmentations');

if ~exist(segmentationsFolder, 'dir')
    % Gound-truth
    rpExtract('dataset', dataset, 'proposalName', 'GroundTruth');
    
    % Store GT labels for quick access
    storeLabelListGT('dataset', dataset);    
    
    % Extract downsized copy of ground truth regions masks
    e2s2_storeBlobMasks('dataset', dataset, 'proposalName', 'GroundTruth');
    
    % Perform the same operations on each color space
    for colorSpaceIdx = 1 : numel(colorSpaces)
        colorSpace = colorSpaces{colorSpaceIdx};
        proposalNameSP = sprintf('Felzenszwalb2004-k100-sigma0.8-colorTypes%s', colorSpace);
        proposalNameRP = sprintf('Uijlings2013-ks100-sigma0.8-colorTypes%s', colorSpace);
        
        % Selective Search
        rpExtract('dataset', dataset, 'proposalName', 'Uijlings2013', 'proposalsVars', {'colorTypes', {colorSpace}});
        
        % Felzenszwalb
        rpExtract('dataset', dataset, 'proposalName', 'Felzenszwalb2004', 'proposalsVars', {'colorTypes', {colorSpace}});
        
        % Reconstruct region proposal hierarchy
        reconstructSelSearchHierarchyFromFz('dataset', dataset, 'segmentationNameSS', proposalNameRP, 'segmentationNameFz', proposalNameSP);
        
        % Extract downsized copy of each regions mask
        e2s2_storeBlobMasks('dataset', dataset, 'proposalName', proposalNameRP);
        
        % Compute the overlaps between ground-truth and superpixels (relevant
        % for evaluation)
        e2s2_storeSPGTOverlap('dataset', dataset, 'spName', proposalNameSP);
    end
end