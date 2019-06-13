classdef ImdbFCN < ImdbCalvin
    % ImdbFCN
    %
    % Standard Imdb for FCN experiments.
    %
    % Copyright by Holger Caesar, 2016
    
    properties
        % Set in constructor
        dataset
        
        batchOpts = struct();
    end
    methods
        function obj = ImdbFCN(dataset, dataDir, nnOpts)
            % Call default constructor
            obj = obj@ImdbCalvin();
            obj.dataset = dataset;
            
            % FCN-specific
            obj.batchOpts.imageSize = [512, 512] - 128;
            obj.batchOpts.labelStride = 1;
            
            obj.batchOpts.imageFlipping = true;
            obj.batchOpts.rgbMean = single([128; 128; 128]);
            obj.batchOpts.classWeights = [];
            obj.batchOpts.imageNameToLabelMap = @(imageName) obj.dataset.getImLabelMap(imageName);
            obj.batchOpts.translateLabels = false;
            obj.batchOpts.maskThings = false;
            
            obj.batchOpts.useInvFreqWeights = false;
            
            % Dataset-specific
            obj.batchOpts.vocAdditionalSegmentations = true;
            obj.batchOpts.vocEdition = '11';
            obj.batchOpts.dataDir = dataDir;
            
            % Load VOC-style IMDB
            obj.loadImdb(nnOpts);
        end
        
        function loadImdb(obj, nnOpts)
            % loadImdb(obj, nnOpts)
            %
            % Creates or load the current VOC-style IMDB.
            
            %%% VOC specific
            if strStartsWith(obj.dataset.name, 'VOC')
                % Get PASCAL VOC segmentation dataset plus Berkeley's additional segmentations
                imdbPath = fullfile(nnOpts.expDir, 'imdbVoc.mat');
                if exist(imdbPath, 'file')
                    % Load imdbVoc
                    load(imdbPath, 'imdbVoc', 'rgbStats');
                else
                    imdbVoc = vocSetup('dataDir', obj.batchOpts.dataDir, ...
                        'edition', obj.batchOpts.vocEdition, ...
                        'includeTest', false, ...
                        'includeSegmentation', true, ...
                        'includeDetection', false);
                    if obj.batchOpts.vocAdditionalSegmentations
                        imdbVoc = vocSetupAdditionalSegmentations(imdbVoc, 'dataDir', obj.batchOpts.dataDir);
                    end
                    rgbStats = getDatasetStatistics(imdbVoc);
                    
                    save(imdbPath, 'imdbVoc', 'rgbStats');
                end
                obj.batchOpts = structOverwriteFields(obj.batchOpts, imdbVoc);
                
                obj.batchOpts.rgbMean = rgbStats.rgbMean;
                obj.batchOpts.rgbMean = reshape(obj.batchOpts.rgbMean, [1 1 3]);
                obj.batchOpts.translateLabels = true;
                obj.batchOpts.imageNameToLabelMap = @(imageName) imread(sprintf(obj.batchOpts.paths.classSegmentation, imageName));
            else
                %%% Other datasets
                % Get labels and image path
                obj.batchOpts.classes.name = obj.dataset.getLabelNames();
                obj.batchOpts.paths.image = fullfile(obj.dataset.getImagePath(), sprintf('%%s%s', obj.dataset.imageExt));
                
                % Get trn + tst/val images
                imageListTrn = obj.dataset.getImageListTrn();
                imageListTst = obj.dataset.getImageListTst();
                
                % Remove images without labels
                missingImageIndicesTrn = obj.dataset.getMissingImageIndices('train');
                imageListTrn(missingImageIndicesTrn) = [];
                % TODO: is it a good idea to remove test images?
                % (only doing it on non-competitive EdiStuff
                if isa(obj.dataset, 'EdiStuffDataset') || isa(obj.dataset, 'EdiStuffSubsetDataset')
                    missingImageIndicesTst = obj.dataset.getMissingImageIndices('test');
                    imageListTst(missingImageIndicesTst) = [];
                end
                imageCountTrn = numel(imageListTrn);
                imageCountTst = numel(imageListTst);
                
                obj.batchOpts.images.name = [imageListTrn; imageListTst];
                obj.batchOpts.images.segmentation = true(imageCountTrn+imageCountTst, 1);
                obj.batchOpts.images.set = nan(imageCountTrn+imageCountTst, 1);
                obj.batchOpts.images.set(1:imageCountTrn) = 1;
                obj.batchOpts.images.set(imageCountTrn+1:end) = 2;
                
                obj.batchOpts.rgbMean = obj.dataset.getMeanColor();
                obj.batchOpts.rgbMean = reshape(obj.batchOpts.rgbMean, [1 1 3]);
                obj.batchOpts.translateLabels = false;
                obj.batchOpts.imageNameToLabelMap = @(imageName) obj.dataset.getImLabelMap(imageName);
            end
            
            % Specify level of supervision for each train image
            if ~nnOpts.misc.weaklySupervised
                % Full supervision
                obj.batchOpts.images.isFullySupervised = true(numel(obj.batchOpts.images.name), 1);
            elseif ~semiSupervised
                % Weak supervision
                obj.batchOpts.images.isFullySupervised = false(numel(obj.batchOpts.images.name), 1);
            else
                % Semi supervision: Set x% of train and all val to true
                obj.batchOpts.images.isFullySupervised = true(numel(obj.batchOpts.images.name), 1);
                if isa(obj.dataset, 'EdiStuffDataset')
                    selWS = find(~ismember(obj.batchOpts.images.name, obj.dataset.datasetFS.getImageListTrn()));
                    assert(numel(selWS) == 18431);
                else
                    selTrain = find(obj.batchOpts.images.set == 1);
                    selTrain = selTrain(randperm(numel(selTrain)));
                    selWS = selTrain((selTrain / numel(selTrain)) >= semiSupervisedRate);
                end
                obj.batchOpts.images.isFullySupervised(selWS) = false;
                
                if nnOpts.misc.semiSupervisedOnlyFS
                    % Keep x% of train and all val
                    selFS = obj.batchOpts.images.isFullySupervised(:) | obj.batchOpts.images.set(:) == 2;
                    obj.batchOpts.images.name = obj.batchOpts.images.name(selFS);
                    obj.batchOpts.images.set = obj.batchOpts.images.set(selFS);
                    obj.batchOpts.images.segmentation = obj.batchOpts.images.segmentation(selFS);
                    obj.batchOpts.images.isFullySupervised = obj.batchOpts.images.isFullySupervised(selFS);
                    
                    if strStartsWith(obj.dataset.name, 'VOC')
                        obj.batchOpts.images.id = obj.batchOpts.images.id(selFS);
                        obj.batchOpts.images.classification = obj.batchOpts.images.classification(selFS);
                        obj.batchOpts.images.size = obj.batchOpts.images.size(:, selFS);
                    end
                end
            end
            
            % Make sure val images are always fully supervised
            obj.batchOpts.images.isFullySupervised(obj.batchOpts.images.set == 2) = true;
            
%             % Print overview of the fully and weakly supervised number of training
%             % images
%             fsCount = sum( obj.batchOpts.images.isFullySupervised(:) & obj.batchOpts.images.set(:) == 1);
%             wsCount = sum(~obj.batchOpts.images.isFullySupervised(:) & obj.batchOpts.images.set(:) == 1);
%             fsRatio = fsCount / (fsCount+wsCount);
%             wsRatio = 1 - fsRatio;
%             fprintf('Images in train: %d FS (%.1f%%), %d WS (%.1f%%)...\n', fsCount, fsRatio * 100, wsCount, wsRatio * 100);
            
            % Get training and test/validation subsets
            % We always validate and test on val
            trainInds = find(obj.batchOpts.images.set == 1 & obj.batchOpts.images.segmentation);
            valInds   = find(obj.batchOpts.images.set == 2 & obj.batchOpts.images.segmentation);
            obj.data.train = obj.batchOpts.images.name(trainInds); %#ok<FNDSB>
            obj.data.val   = obj.batchOpts.images.name(valInds); %#ok<FNDSB>
            obj.data.train = obj.data.train(:);
            obj.data.val   = obj.data.val(:);
            
            % Dataset-independent imdb fields
            obj.numClasses = obj.dataset.labelCount;
        end
        
        function[inputs, numElements] = getBatch(obj, batchIdx, net, nnOpts)
            % [inputs, numElements] = getBatch(obj, batchIdx, net, nnOpts)
            %
            % Returns a single image, its labels and boxes to be used as a sub-batch in training, validation or testing.
            % Note: Currently train and val batches are treated the same.
            %
            % Copyright by Holger Caesar, 2015
            
            % Check inputs
            assert(~isempty(obj.datasetMode));
            assert(numel(batchIdx) == 1);
            imageCount = numel(batchIdx);
            imageIdx = batchIdx;
            
            % Check settings
            assert(~isempty(obj.batchOpts.rgbMean));
            
            % Determine whether testing
            testMode = strcmp(obj.datasetMode, 'test');
            
            % Init labels
            if ~testMode
                lx = 1 : obj.batchOpts.labelStride : obj.batchOpts.imageSize(2);
                ly = 1 : obj.batchOpts.labelStride : obj.batchOpts.imageSize(1);
                labels = zeros(numel(ly), numel(lx), 1, imageCount, 'double'); % must be double for to avoid numerical precision errors in vl_nnloss, when using many classes
                if nnOpts.misc.weaklySupervised
                    labelsImageCell = cell(imageCount, 1);
                end
                if nnOpts.misc.maskThings
                    assert(isa(obj.dataset, 'EdiStuffDataset'));
                    datasetIN = ImageNetDataset();
                end
                masksThingsCell = cell(imageCount, 1); % by default this is empty
            end
            
            % Get image
            if true
                % Get image
                imageName = obj.data.(obj.datasetMode){imageIdx};
                imageOri = single(obj.dataset.getImage(imageName)) * 255;
                
                if ~testMode
                    image = zeros(obj.batchOpts.imageSize(1), obj.batchOpts.imageSize(2), 3, imageCount, 'single');
                    
                    % Crop and rescale image
                    h = size(imageOri, 1);
                    w = size(imageOri, 2);
                    sz = obj.batchOpts.imageSize(1 : 2);
                    scale = max(h / sz(1), w / sz(2));
                    scale = scale .* (1 + (rand(1) - .5) / 5);
                    sy = round(scale * ((1:sz(1)) - sz(1)/2) + h/2);
                    sx = round(scale * ((1:sz(2)) - sz(2)/2) + w/2);
                    
                    % Flip image
                    if obj.batchOpts.imageFlipping && rand > 0.5
                        sx = fliplr(sx);
                    end
                    
                    % Get image indices in valid area
                    okx = find(1 <= sx & sx <= w);
                    oky = find(1 <= sy & sy <= h);
                    image(oky, okx, :, 1) = imageOri(sy(oky), sx(okx), :);
                else
                    image = imageOri;
                    
                    % Workaround: Limit image size to avoid running out of RAM
                    maxImSize = 700;
                    if ~isempty(maxImSize),
                        maxSize = max(size(image, 1), size(image, 2));
                        if maxSize > maxImSize,
                            factor = maxImSize / maxSize;
                            image = imresize(image, factor);
                        end;
                    end;
                    
                    % Some networks requires the image to be a multiple of 32 pixels
                    imageNeedsToBeMultiple = true;
                    if imageNeedsToBeMultiple
                        sz = [size(image, 1), size(image, 2)];
                        sz = round(sz / 32) * 32;
                        image = imresize(image, sz);
                    end
                end
                
                % Subtract mean image
                image = bsxfun(@minus, image, obj.batchOpts.rgbMean);
            end
            
            % Get labels
            if true
                % Fully supervised: Get pixel level labels
                if ~testMode
                    % Get pixel-level GT
                    if obj.dataset.annotation.hasPixelLabels || obj.batchOpts.images.isFullySupervised(imageIdx)
                        anno = uint16(obj.batchOpts.imageNameToLabelMap(imageName));
                        
                        % Translate labels s.t. 255 is mapped to 0
                        if obj.batchOpts.translateLabels,
                            % Before: 255 = ignore, 0 = bkg, 1:n = classes
                            % After : 0 = ignore, 1 = bkg, 2:n+1 = classes
                            anno = mod(anno + 1, 256);
                        end
                        % 0 = ignore, 1:n = classes
                    else
                        anno = [];
                    end
                    
                    if ~isempty(anno)
                        tlabels = zeros(sz(1), sz(2), 'double');
                        tlabels(oky,okx) = anno(sy(oky), sx(okx));
                        tlabels = single(tlabels(ly, lx));
                        labels(:, :, 1, 1) = tlabels; % 0: ignore
                    end
                end
                
                if ~testMode
                    % Weakly supervised: extract image-level labels
                    if nnOpts.misc.weaklySupervised
                        if ~isempty(anno) && ~all(anno(:) == 0)
                            % Get image labels from pixel labels
                            % These are already translated (if necessary)
                            curLabelsImage = unique(anno);
                        else
                            curLabelsImage = obj.dataset.getImLabelInds(imageName);
                            
                            % Translate labels s.t. 255 is mapped to 0
                            if obj.batchOpts.translateLabels
                                curLabelsImage = mod(curLabelsImage + 1, 256);
                            end
                            
                            if obj.dataset.annotation.labelOneIsBg
                                % Add background label
                                curLabelsImage = unique([0; curLabelsImage(:)]);
                            end
                        end
                        
                        % Remove invalid pixels
                        curLabelsImage(curLabelsImage == 0) = [];
                        
                        % Store image-level labels
                        labelsImageCell{1} = single(curLabelsImage(:));
                    end
                end
                
                % Optional: Mask out thing pixels
                if ~testMode
                    if nnOpts.misc.maskThings
                        % Get mask
                        longName = datasetIN.shortNameToLongName(imageName);
                        mask = datasetIN.getImLabelBoxesMask(longName);
                        
                        % Resize it if necessary
                        if size(mask, 1) ~= size(image, 1) || ...
                                size(mask, 2) ~= size(image, 2)
                            mask = imresize(mask, [size(image, 1), size(image, 2)]);
                        end
                        masksThingsCell{1} = mask;
                    end
                end
            end
            
            % Extract inverse class frequencies from dataset
            if ~testMode
                if obj.batchOpts.useInvFreqWeights,
                    if nnOpts.misc.weaklySupervised,
                        classWeights = obj.dataset.getLabelImFreqs('train');
                    else
                        classWeights = obj.dataset.getLabelPixelFreqs('train');
                    end
                    
                    % Inv freq and normalize classWeights
                    classWeights = classWeights ./ sum(classWeights);
                    nonEmpty = classWeights ~= 0;
                    classWeights(nonEmpty) = 1 ./ classWeights(nonEmpty);
                    classWeights = classWeights ./ sum(classWeights);
                    assert(~any(isnan(classWeights)));
                else
                    classWeights = [];
                end
                obj.batchOpts.classWeights = classWeights;
            end
            
            % Move image to GPU
            if strcmp(net.device, 'gpu')
                image = gpuArray(image);
            end
            
            % Store in output struct
            inputs = {'input', image};
            if ~testMode
                %TODO: fix imageIdx relative to subset
                if obj.dataset.annotation.hasPixelLabels || obj.batchOpts.images.isFullySupervised(imageIdx)
                    inputs = [inputs, {'label', double(labels)}];  % has to be double to avoid problems in loss
                end
                if nnOpts.misc.weaklySupervised
                    assert(~any(cellfun(@(x) isempty(x), labelsImageCell)));
                    inputs = [inputs, {'labelsImage', labelsImageCell}];
                end
                
                % Instance/pixel weights, can be left empty
                inputs = [inputs, {'classWeights', obj.batchOpts.classWeights}];
                
                % Decide which level of supervision to pick
                if nnOpts.misc.semiSupervised
                    % SS
                    isWeaklySupervised = ~obj.batchOpts.images.isFullySupervised(imageIdx);
                else
                    % FS or WS
                    isWeaklySupervised = nnOpts.misc.weaklySupervised;
                end
                inputs = [inputs, {'isWeaklySupervised', isWeaklySupervised}];
                inputs = [inputs, {'masksThingsCell', masksThingsCell}];
            end
            numElements = 1; % One image
        end
        
        function[allBatchInds] = getAllBatchInds(obj)
            % Obtain the indices and ordering of all batches (for this epoch)
            
            batchCount = numel(obj.data.(obj.datasetMode));
            if strcmp(obj.datasetMode, 'train')
                allBatchInds = randperm(batchCount)';
            elseif strcmp(obj.datasetMode, 'val'),
                allBatchInds = (1:batchCount)';
            elseif strcmp(obj.datasetMode, 'test'),
                allBatchInds = (1:batchCount)';
            else
                error('Error: Unknown datasetMode!');
            end
        end
        
        function initEpoch(obj, epoch)
            % Call default method
            initEpoch@ImdbCalvin(obj, epoch);
        end
    end
end