classdef ImdbE2S2 < ImdbCalvin
    % ImdbE2S2
    %
    % Standard Imdb for all fully and weakly supervised E2S2 experiments.
    %
    % Copyright by Holger Caesar, 2016
    
    properties
        % Set in constructor
        dataset
        segmentFolder
        
        batchOpts = struct();
        imageSample = struct();
    end
    
    properties (Transient)
        % Automatically set
        segmentFolderRP
        segmentFolderSP
        segmentFolderGT
    end
    
    methods
        function obj = ImdbE2S2(dataset, segmentFolder)
            % Call default constructor
            obj = obj@ImdbCalvin();
            
            % Set default options
            obj.batchOpts.maxImageSize = 600;
            obj.batchOpts.posRange = [0.1, 1.0];
            obj.batchOpts.subsample = true;
            obj.batchOpts.removeGT = false;
            obj.batchOpts.overlapThreshGTSP = 0.5;
            obj.batchOpts.blobMaxSize = []; % relative to image size
            obj.batchOpts.imageFlipping = true;
            obj.batchOpts.segments.minSize = 100;
            obj.batchOpts.segments.colorTypeIdx = 1; % should always be 1 on start
            obj.batchOpts.segments.switchColorTypesEpoch = false;
            obj.batchOpts.segments.switchColorTypesBatch = false;
            obj.batchOpts.segments.colorTypes = {'Rgb'};
            obj.batchOpts.segments.segmentStrRP = 'Uijlings2013-ks%d-sigma0.8-colorTypes%s';
            obj.batchOpts.segments.segmentStrSP = 'Felzenszwalb2004-k%d-sigma0.8-colorTypes%s';
            obj.batchOpts.segments.segmentStrGT = 'GroundTruth';
            obj.imageSample.use = false;
            
            % Set segment names
            obj.dataset = dataset;
            obj.segmentFolder = segmentFolder;
            obj.updateSegmentNames();
            
            obj.numClasses = dataset.labelCount;
            
            % Reset global variables
            global labelPixelFreqsOriginal;
            labelPixelFreqsOriginal = [];
        end
        
        function[inputs, numElements] = getBatch(obj, batchIdx, net, nnOpts)
            % [inputs, numElements] = getBatch(obj, batchIdx, net, nnOpts)
            %
            % Returns a single image, its labels and boxes to be used as a sub-batch in training, validation or testing.
            %
            % Copyright by Holger Caesar, 2015
            
            % Check inputs
            assert(~isempty(obj.datasetMode));
            assert(numel(batchIdx) == 1);
            
            % Dummy init
            inputs = {};
            numElements = 0;
            
            % During test/validation we don't use ground-truth regions etc.
            % (Changed this to included validation as we are not using a
            % val set and only looking to see the final result)
            testMode = ~strcmp(obj.datasetMode, 'train');
            computeLoss = ~strcmp(obj.datasetMode, 'test');
            
            % Switch color type if specified
            % (this has to happen on batchOpts, not batchOptsCopy!)
            if obj.batchOpts.segments.switchColorTypesBatch && ~testMode,
                obj.switchColorType();
            end
            
            % Create a copy of batchOpts to avoid changes to the entire imdb
            batchOptsCopy = obj.batchOpts;
            
            % Special settings for test mode (not val)
            if testMode,
                batchOptsCopy.subsample = false;
                batchOptsCopy.removeGT = true;
                batchOptsCopy.blobMaxSize = [];
                batchOptsCopy.imageFlipping = false;
                batchOptsCopy.segments.switchColorTypesEpoch = false;
                batchOptsCopy.segments.switchColorTypesBatch = false;
                
                if isfield(nnOpts.misc, 'testOpts') && isfield(nnOpts.misc.testOpts, 'testColorSpace')
                    testColorSpace = nnOpts.misc.testOpts.testColorSpace;
                else
                    testColorSpace = 1;
                end
                if batchOptsCopy.segments.colorTypeIdx ~= testColorSpace,
                    batchOptsCopy.segments.colorTypeIdx = testColorSpace;
                    obj.updateSegmentNames(batchOptsCopy);
                end
                
                % Illegal option that is only used as an upper bound for
                % performance with better regions
                if isfield(nnOpts.misc, 'testOpts'),
                    if isfield(nnOpts.misc.testOpts, 'subsamplePosRange'),
                        batchOptsCopy.subsample = true;
                        batchOptsCopy.posRange = nnOpts.misc.testOpts.subsamplePosRange;
                    end
                end
            end
            
            % Get params from layers and nnOpts
            roiPool = nnOpts.misc.roiPool;
            roiPool.size = net.layers(net.getLayerIndex('roipool5')).block.poolSize;
            regionToPixel = nnOpts.misc.regionToPixel;
            if isfield(nnOpts.misc, 'weaklySupervised'),
                weaklySupervised = nnOpts.misc.weaklySupervised;
                
                if weaklySupervised.use,
                    assert(weaklySupervised.labelPresence.use);
                    batchOptsCopy.subsample = false;
                    batchOptsCopy.removeGT = true;
                end
            else
                weaklySupervised.use = false;
            end
            
            % Load image
            imageIdx = batchIdx;
            imageName = obj.data.(obj.datasetMode){imageIdx};
            image = single(obj.dataset.getImage(imageName));
            
            % Move image to GPU
            if strcmp(net.device, 'gpu')
                image = gpuArray(image);
            end
            
            % Resize image and subtract mean image
            [image, oriImSize] = e2s2_prepareImage(net, image, batchOptsCopy.maxImageSize);
            
            % Get segmentation structure
            segmentPathRP = [obj.segmentFolderRP, filesep, imageName, '.mat'];
            if ~exist(segmentPathRP, 'file')
                error('Error: Missing region proposal file %s. Please run rpExtract()!', segmentPathRP)
            end
            segmentStructRP = load(segmentPathRP, 'propBlobs', 'overlapList');
            if ~isfield(segmentStructRP, 'overlapList')
                error('Error: Missing overlapList in file %s. Please run reconstructSelSearchHierarchyFromFz()!', segmentPathRP);
            end
            overlapListRP = segmentStructRP.overlapList;
            blobsRP = segmentStructRP.propBlobs(:);
            clearvars segmentStructRP;
            
            % Get SPs
            segmentPathSP = [obj.segmentFolderSP, filesep, imageName, '.mat'];
            segmentStructSP = load(segmentPathSP, 'propBlobs');
            blobsSP = segmentStructSP.propBlobs;
            
            % Get blobMasks from file
            if roiPool.freeform.use
                blobMasksName = sprintf('blobMasks%dx%d', roiPool.size(1), roiPool.size(2));
                segmentStructRP = load(segmentPathRP, blobMasksName);
                if ~isfield(segmentStructRP, blobMasksName),
                    error('Error: Missing blob masks, please run e2s2_storeBlobMasks()!');
                end
                blobMasksRP = segmentStructRP.(blobMasksName);
                clearvars segmentStructRP;
            end
            
            if ~weaklySupervised.use
                % Get GT structure
                segmentPathGT = [obj.segmentFolderGT, filesep, imageName, '.mat'];
                segmentStructGT = load(segmentPathGT, 'propBlobs', 'labelListGT');
                blobsGT = segmentStructGT.propBlobs(:);
                labelListGT = segmentStructGT.labelListGT;
                if isempty(blobsGT)
                    % Skip images without GT regions
                    return;
                end
                
                % Get blobMasks from file
                if roiPool.freeform.use
                    segmentStructGT = load(segmentPathGT, blobMasksName);
                    blobMasksGT = segmentStructGT.(blobMasksName);
                end
            end
            
            % Filter blobs according to IOU with GT
            if batchOptsCopy.subsample && ~weaklySupervised.use
                % Compute IOUs between RP and GT
                overlapRPGT = scoreBlobIoUs(blobsRP, blobsGT);
                
                % Compute IOUs between RP and each label
                blobCountRP = numel(blobsRP);
                overlapRPLabels = zeros(blobCountRP, obj.numClasses);
                for labelIdx = 1 : obj.numClasses
                    sel = labelListGT == labelIdx;
                    
                    if any(sel)
                        overlapRPLabels(:, labelIdx) = max(overlapRPGT(:, sel), [], 2);
                    end
                end
                
                % Compute maximum overlap and labels
                [maxOverlap, ~] = max(overlapRPLabels, [], 2);
                
                % Find positives (negatives are rejected)
                blobIndsRP = find(batchOptsCopy.posRange(1) <= maxOverlap & ...
                                  maxOverlap <= batchOptsCopy.posRange(2));
            else
                blobIndsRP = (1:numel(blobsRP))';
            end
            
            % Remove very big blobs
            if isfield(batchOptsCopy, 'blobMaxSize') && ~isempty(batchOptsCopy.blobMaxSize) && batchOptsCopy.blobMaxSize ~= 1
                imagePixelSize = oriImSize(1) * oriImSize(2);
                pixelSizesRP = [blobsRP.size]';
                blobIndsRP = intersect(blobIndsRP, find(pixelSizesRP <= imagePixelSize * batchOptsCopy.blobMaxSize));
            end
            
            % Additional testing options (limit regions etc.)
            if testMode && isfield(nnOpts.misc, 'testOpts')
                % Default arguments
                testOpts = nnOpts.misc.testOpts;
                if ~isfield(testOpts, 'maxSizeRel') || isempty(testOpts.maxSizeRel),
                    maxSizeRel = 1;
                else
                    maxSizeRel = testOpts.maxSizeRel;
                end
                if ~isfield(testOpts, 'minSize') || isempty(testOpts.minSize),
                    minSize = 0;
                else
                    minSize = testOpts.minSize;
                end
                
                % Select regions
                imagePixelSize = oriImSize(1) * oriImSize(2);
                pixelSizesRP = [blobsRP.size]';
                regionSel = pixelSizesRP >= minSize & pixelSizesRP / imagePixelSize <= maxSizeRel;
                blobIndsRP = intersect(blobIndsRP, find(regionSel));
            end
            
            % At test time, make sure the whole image is included
            % (otherwise superpixels might be unlabeled!)
            % (this obviously limits the effect of maxSizeRel)
            if testMode
                wholeImageRegion = find([blobsRP.size] == oriImSize(1) * oriImSize(2), 1);
                blobIndsRP = union(blobIndsRP, wholeImageRegion);
            end
            
            % Apply selection to relevant fields
            blobsRP = blobsRP(blobIndsRP);
            overlapListRP = overlapListRP(blobIndsRP, :);
            if roiPool.freeform.use
                blobMasksRP = blobMasksRP(blobIndsRP);
            end
            
            % Merge RP and GT
            blobsAll = blobsRP;
            overlapListAll = overlapListRP;
            if roiPool.freeform.use
                blobMasksAll = blobMasksRP;
            end
            
            if ~batchOptsCopy.removeGT
                % Figure out which superpixels are part of a GT region and
                % remove GT regions that don't overlap enough with a superpixel
                % Note: the overlaps are precomputed for speedup
                pixelSizesSP = [blobsSP.size]';
                segmentPathSP = [obj.segmentFolderSP, filesep, imageName, '.mat'];
                if exist(segmentPathSP, 'file')
                    segmentStructSP = load(segmentPathSP, 'overlapRatiosSPGT');
                    overlapRatiosSPGT = segmentStructSP.overlapRatiosSPGT;
                else
                    imagePixelSize = oriImSize(1) * oriImSize(2);
                    overlapRatiosSPGT = computeBlobOverlapSum(blobsSP, blobsGT, imagePixelSize);
                end
                overlapRatiosSPGT = bsxfun(@rdivide, overlapRatiosSPGT, pixelSizesSP);
                overlapListGT = sparse(overlapRatiosSPGT' >= batchOptsCopy.overlapThreshGTSP);
                overlappingGT = full(sum(overlapListGT, 2) > 0);
                
                % Apply selection to GT
                blobsGT = blobsGT(overlappingGT);
                overlapListGT = overlapListGT(overlappingGT, :);
                if roiPool.freeform.use
                    blobMasksGT = blobMasksGT(overlappingGT);
                end
                
                % Merge RP and GT
                blobsAll = [blobsAll; blobsGT];
                overlapListAll = [overlapListAll; overlapListGT];
                if roiPool.freeform.use
                    blobMasksAll = [blobMasksAll; blobMasksGT];
                    assert(numel(blobMasksAll) == size(blobsAll, 1));
                end
            end
            assert(size(blobsAll, 1) == size(overlapListAll, 1));
            
            % Skip images without blobs (no RP and no GT after filtering)
            if isempty(blobsAll)
                return;
            end
            
            % Create boxes at the very end to avoid inconsistency
            boxesAll = single(cell2mat({blobsAll.rect}'));
            assert(size(blobsAll, 1) == size(boxesAll, 1));
            
            % Flip image, boxes and masks
            if batchOptsCopy.imageFlipping && rand() >= 0.5
                if roiPool.freeform.use
                    [image, boxesAll, blobMasksAll] = e2s2_flipImageBoxes(image, boxesAll, oriImSize, blobMasksAll);
                else
                    [image, boxesAll] = e2s2_flipImageBoxes(image, boxesAll, oriImSize);
                end
            end
            
            if nnOpts.misc.invFreqWeights && computeLoss
                if weaklySupervised.use
                    classWeights = obj.dataset.getLabelImFreqs();
                else
                    classWeights = obj.dataset.getLabelPixelFreqs();
                end
                classWeights = classWeights ./ sum(classWeights);
                nonEmpty = classWeights ~= 0;
                classWeights(nonEmpty) = 1 ./ classWeights(nonEmpty);
                classWeights = classWeights ./ sum(classWeights);
                assert(~any(isnan(classWeights)));
                
                % Reshape to loss layer format
                classWeights = reshape(classWeights, 1, 1, 1, []);
            else
                classWeights = [];
            end
            
            if weaklySupervised.use && ~testMode
                % Get the image-level labels and weights
                % Note: these should be as similar as possible to the ones
                % in the regiontopixel layer.
                labelNames = obj.dataset.getLabelNames();
                imLabelNames = obj.dataset.getImLabelList(imageName);
                if isempty(imLabelNames)
                    % Skip images that have no labels
                    return;
                end
                labelsImage = find(ismember(labelNames, imLabelNames));
            end
            
            % Convert boxes to transposed Girshick format
            boxesAll = boxesAll(:, [2, 1, 4, 3])';
            
            % Store in output struct
            inputs = {'input', image, 'oriImSize', oriImSize, 'boxes', boxesAll, 'blobsSP', blobsSP};
            if regionToPixel.use
                inputs = [inputs, {'overlapListAll', overlapListAll}];
            end
            if roiPool.freeform.use
                inputs = [inputs, {'blobMasks', blobMasksAll}];
            end
            if weaklySupervised.use  ...
                    && weaklySupervised.labelPresence.use ...
                    && computeLoss
                % For the SegmentationLossImage layer
                inputs = [inputs, {'labelsImage', {labelsImage}}];
                inputs = [inputs, {'masksThingsCell', {}}];
            end
            if computeLoss
                % For the SuperPixelToPixelMap, SegmentationLoss* and SegmentationAccuracyFlexible layers
                labels = double(obj.dataset.getImLabelMap(imageName)); % has to be double to avoid problems in loss
                inputs = [inputs, {'labels', labels}];
                inputs = [inputs, {'classWeights', classWeights}];
            end
            numElements = 1; % One image
        end
        
        function[allBatchInds] = getAllBatchInds(obj)
            % Obtain the indices and ordering of all batches (for this epoch)
            
            batchCount = size(obj.data.(obj.datasetMode), 1);
            if strcmp(obj.datasetMode, 'train')
                if obj.imageSample.use
                    allBatchInds = obj.imageSample.func.(obj.datasetMode)(batchCount);
                else
                    allBatchInds = randperm(batchCount);
                end
            elseif strcmp(obj.datasetMode, 'val')
                if obj.imageSample.use
                    allBatchInds = obj.imageSample.func.(obj.datasetMode)(batchCount);
                else
                    allBatchInds = 1:batchCount;
                end
            elseif strcmp(obj.datasetMode, 'test')
                allBatchInds = 1:batchCount;
            else
                error('Error: Unknown datasetMode!');
            end
        end
        
        function switchColorType(obj)
            % switchColorType(obj)
            %
            % Switch to the next color type (if more than 1).
            
            obj.batchOpts.segments.colorTypeIdx = 1 + mod(obj.batchOpts.segments.colorTypeIdx, numel(obj.batchOpts.segments.colorTypes));
            obj.updateSegmentNames();
        end
        
        function updateSegmentNames(obj, batchOpts)
            % updateSegmentNames(obj, [batchOpts])
            %
            % Update the names of the current proposals/superpixels,
            % matching the current colorType and minSize.
            
            if ~exist('batchOpts', 'var')
                batchOpts = obj.batchOpts;
            end
            
            colorType = batchOpts.segments.colorTypes{batchOpts.segments.colorTypeIdx};
            minSize = batchOpts.segments.minSize;
            obj.segmentFolderRP = fullfile(obj.segmentFolder, sprintf(obj.batchOpts.segments.segmentStrRP, minSize, colorType));
            obj.segmentFolderSP = fullfile(obj.segmentFolder, sprintf(obj.batchOpts.segments.segmentStrSP, minSize, colorType));
            obj.segmentFolderGT = fullfile(obj.segmentFolder, obj.batchOpts.segments.segmentStrGT);
        end
        
        function initEpoch(obj, epoch)
            % Call default method
            initEpoch@ImdbCalvin(obj, epoch);
            
            % Change color type if option is selected
            % This is not related to LR flipping, but the only way to
            % currently implement this.
            if obj.batchOpts.segments.switchColorTypesEpoch
                obj.switchColorType();
            end
        end
    end
end