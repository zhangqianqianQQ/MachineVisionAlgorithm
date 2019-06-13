classdef E2S2NN < CalvinNN
    % E2S2NN End-to-end region based semantic segmentation training.
    %
    % Copyright by Holger Caesar, 2015
    
    methods
        function obj = E2S2NN(net, imdb, nnOpts)
            obj = obj@CalvinNN(net, imdb, nnOpts);
        end
        
        function convertNetwork(obj)
            % convertNetwork(obj)
            
            % Convert image classification model to Fast R-CNN object
            % detection model
            convertNetwork@CalvinNN(obj);
            
            fprintf('Converting Fast R-CNN network to End-to-end region based network (region-to-pixel layer, etc.)...\n');
            
            % If required, insert freeform pooling layer after roipool
            if isfield(obj.nnOpts.misc, 'roiPool')
                roiPool = obj.nnOpts.misc.roiPool;
                if isfield(roiPool, 'freeform') && roiPool.freeform.use
                    % Compute activations for foreground and entire box separately
                    % (by default off)
                    roiPoolFreeformBlock = dagnn.RoiPoolingFreeform('combineFgBox', roiPool.freeform.combineFgBox);
                    insertLayer(obj.net, 'roipool5', 'fc6', 'roipoolfreeform5', roiPoolFreeformBlock, 'blobMasks');
                    
                    % Share fully connected layer weights for foreground and entire box
                    if isfield(roiPool.freeform, 'shareWeights') && ~roiPool.freeform.shareWeights
                        fcLayers = {obj.net.layers(~cellfun(@isempty, regexp({obj.net.layers.name}, 'fc.*'))).name};
                        for relIdx = 1 : numel(fcLayers)
                            relLayer = fcLayers{relIdx};
                            relLayerIdx = obj.net.getLayerIndex(relLayer);
                            paramIndexes = obj.net.layers(relLayerIdx).paramIndexes;
                            
                            % Duplicate input size for all but the first fc layer
                            if relIdx > 1
                                obj.net.layers(relLayerIdx).block.size(3) = obj.net.layers(relLayerIdx).block.size(3) * 2;
                                obj.net.params(paramIndexes(1)).value = cat(3, ...
                                    obj.net.params(paramIndexes(1)).value, ...
                                    obj.net.params(paramIndexes(1)).value);
                            end
                            % Duplicate output size for all but the last fc layers
                            if relIdx < numel(fcLayers)
                                obj.net.layers(relLayerIdx).block.size(4) = obj.net.layers(relLayerIdx).block.size(4) * 2;
                                obj.net.params(paramIndexes(1)).value = cat(4, ...
                                    obj.net.params(paramIndexes(1)).value, ...
                                    obj.net.params(paramIndexes(1)).value);
                                obj.net.params(paramIndexes(2)).value = cat(2, ...
                                    obj.net.params(paramIndexes(2)).value, ...
                                    obj.net.params(paramIndexes(2)).value);
                            end
                        end
                    end
                end
            end
            
            % Rename variables for use on superpixel level (not pixel-level)
            obj.net.renameVar('label', 'labelsSP');
            obj.net.renameVar('instanceWeights', 'instanceWeightsSP');
            
            % Insert a regiontopixel layer before the loss
            if obj.nnOpts.misc.regionToPixel.use                
                if isfield(obj.nnOpts.misc.regionToPixel, 'soft') && obj.nnOpts.misc.regionToPixel.soft.use
                    % Special option where we use a softer function than
                    % max (depends on weighted ranks)
                    regionToPixelBlock = dagnn.RegionToPixelSoft('decay', obj.nnOpts.misc.regionToPixel.soft.decay);
                else
                    % Max
                    regionToPixelBlock = dagnn.RegionToPixel();
                end
                
                insertLayer(obj.net, 'fc8', 'softmaxloss', 'regiontopixel8', regionToPixelBlock, 'overlapListAll', {});
            end
            
            % Weakly supervised learning options
            if isfield(obj.nnOpts.misc, 'weaklySupervised')
                weaklySupervised = obj.nnOpts.misc.weaklySupervised;
            else
                weaklySupervised.use = false;
            end
            
            % Map from superpixels to pixels
            if true
                fprintf('Adding mapping from superpixel to pixel level...\n');
                
                insertLayer(obj.net, 'regiontopixel8', 'softmaxloss', 'pixelmap', dagnn.SuperPixelToPixelMap, {'blobsSP', 'oriImSize'}, {}, {});
                pixelMapIdx = obj.net.getLayerIndex('pixelmap');
                obj.net.renameVar(obj.net.layers(pixelMapIdx).outputs{1}, 'prediction');
                
                % Add an optional accuracy layer
                accLayer = dagnn.SegmentationAccuracyFlexible('labelCount', obj.imdb.numClasses);
                obj.net.addLayer('accuracy', accLayer, {'prediction', 'labels'}, 'accuracy');
                
                % FS loss
                if ~weaklySupervised.use
                    lossIdx = obj.net.getLayerIndex('softmaxloss');
                    scoresVar = obj.net.layers(lossIdx).inputs{1};
                    layerFS = dagnn.SegmentationLossPixel();
                    replaceLayer(obj.net, 'softmaxloss', 'softmaxloss', layerFS, {scoresVar, 'labels', 'classWeights'}, {}, {}, true);
                end
            end
            
            % Weakly supervised loss
            if weaklySupervised.use
                if isfield(weaklySupervised, 'labelPresence') && weaklySupervised.labelPresence.use,
                    assert(obj.nnOpts.misc.regionToPixel.use);
                    
                    % Change parameters for loss
                    % (for compatibility we don't change the name of the loss)
                    lossIdx = obj.net.getLayerIndex('softmaxloss');
                    scoresVar = obj.net.layers(lossIdx).inputs{1};
                    layerWS = dagnn.SegmentationLossImage('useAbsent', obj.nnOpts.misc.weaklySupervised.useAbsent);
                    replaceLayer(obj.net, 'softmaxloss', 'softmaxloss', layerWS, {scoresVar, 'labelsImage', 'classWeights', 'masksThingsCell'}, {}, {}, true);
                end
            end
            
            % Sort layers by their first occurrence
            sortLayers(obj.net);
        end
        
        function[stats] = testOnSet(obj, varargin)
            % [stats] = testOnSet(obj, varargin)
            
            % Initial settings
            p = inputParser;
            addParameter(p, 'subset', 'test');
            addParameter(p, 'doCache', true);
            addParameter(p, 'limitImageCount', Inf);
            addParameter(p, 'storeOutputMaps', false);
            parse(p, varargin{:});
            
            subset = p.Results.subset;
            doCache = p.Results.doCache;
            limitImageCount = p.Results.limitImageCount;
            storeOutputMaps = p.Results.storeOutputMaps;
            
            % Set the datasetMode to be active
            if strcmp(subset, 'test'),
                temp = [];
            else
                temp = obj.imdb.data.test;
                obj.imdb.data.test = obj.imdb.data.(subset);
            end
            
            % Run test
            stats = obj.test('subset', subset, 'doCache', doCache, 'limitImageCount', limitImageCount, 'storeOutputMaps', storeOutputMaps);
            if ~strcmp(subset, 'test')
                stats.loss = [obj.stats.(subset)(end).objective]';
            end
            
            % Restore the original test set
            if ~isempty(temp)
                obj.imdb.data.test = temp;
            end
        end
        
        function extractFeatures(obj, varargin)
            % extractFeatures(obj, varargin)
            
            % Initial settings
            p = inputParser;
            addParameter(p, 'subset', 'test');
            addParameter(p, 'outputVarName', '');
            parse(p, varargin{:});
            
            subset = p.Results.subset;
            outputVarName = p.Results.outputVarName;
            
            % Init
            imageList = obj.imdb.data.(subset);
            imageCount = numel(imageList);
            
            % Update imdb's test set
            tempTest = obj.imdb.data.test;
            obj.imdb.data.test = imageList;
            
            % Set network to testing mode
            outputVarIdx = obj.prepareNetForTest();
            if exist('outputVarName', 'var') && ~isempty(outputVarName)
                outputVarIdx = obj.net.getVarIndex(outputVarName);
            else
                outputVarName = obj.net.vars(outputVarIdx).name;
            end
            
            % Create output folder
            epoch = numel(obj.stats.train);
            featFolder = fullfile(obj.nnOpts.expDir, sprintf('features-%s-%s-epoch-%d', outputVarName, subset, epoch));
            
            for imageIdx = 1 : imageCount,
                printProgress('Classifying images', imageIdx, imageCount, 10);
                
                % Get batch
                inputs = obj.imdb.getBatch(imageIdx, obj.net);
                
                % Run forward pass
                obj.net.eval(inputs);
                
                % Extract probs
                curProbs = obj.net.vars(outputVarIdx).value;
                curProbs = gather(reshape(curProbs, [size(curProbs, 3), size(curProbs, 4)]))';
                
                % Store
                imageName = imageList{imageIdx};
                featPath = fullfile(featFolder, [imageName, '.mat']);
                features = double(curProbs); %#ok<NASGU>
                save(featPath, 'features', '-v6');
            end;
            
            % Reset test set
            obj.imdb.data.test = tempTest;
        end
        
        function[outputVarIdx] = prepareNetForTest(obj)
            % [outputVarIdx] = prepareNetForTest(obj)
            
            % Move to GPU
            if ~isempty(obj.nnOpts.gpus)
                obj.net.move('gpu');
            end
            
            % Enable test mode
            obj.imdb.setDatasetMode('test');
            obj.net.mode = 'test';
            
            % Reset segments to default
            obj.imdb.batchOpts.segments.switchColorTypesEpoch = false;
            obj.imdb.batchOpts.segments.switchColorTypesBatch = false;
            obj.imdb.batchOpts.segments.colorTypeIdx = 1;
            obj.imdb.updateSegmentNames();
            
            % Replace softmaxloss by softmax
            lossIdx = find(cellfun(@(x) isa(x, 'dagnn.Loss'), {obj.net.layers.block}));
            accuracyIdx = obj.net.getLayerIndex('accuracy');
            lossIdx(lossIdx == accuracyIdx) = [];
            assert(numel(lossIdx) == 1);
            lossName = obj.net.layers(lossIdx).name;
            lossType = obj.net.layers(lossIdx).block.loss;
            lossInputs = obj.net.layers(lossIdx).inputs;
            if strcmp(lossType, 'softmaxlog')
                obj.net.removeLayer(lossName);
                outputLayerName = 'softmax';
                obj.net.addLayer(outputLayerName, dagnn.SoftMax(), lossInputs{1}, 'scores', {}); % Should not be necessary
                outputLayerIdx = obj.net.getLayerIndex(outputLayerName);
                outputVarIdx = obj.net.layers(outputLayerIdx).outputIndexes;
            elseif strcmp(lossType, 'log')
                % Only output the scores of the regiontopixel layer
                outputVarIdx = obj.net.layers(lossIdx).inputIndexes(1);
                obj.net.removeLayer(lossName);
            else
                error('Error: Unknown loss function!');
            end
            
            assert(numel(outputVarIdx) == 1);
        end
        
        function[stats] = test(obj, varargin)
            % [stats] = test(obj, varargin)
            
            % Initial settings
            p = inputParser;
            addParameter(p, 'subset', 'test');
            addParameter(p, 'doCache', true);
            addParameter(p, 'plotFreq', 15);
            addParameter(p, 'limitImageCount', Inf);
            addParameter(p, 'storeOutputMaps', false);
            parse(p, varargin{:});
            
            subset = p.Results.subset;
            doCache = p.Results.doCache;
            plotFreq = p.Results.plotFreq;
            limitImageCount = p.Results.limitImageCount;
            storeOutputMaps = p.Results.storeOutputMaps;
            
            % Check that settings are valid
            if ~isinf(limitImageCount)
                assert(~doCache);
            end
            
            if isfield(obj.nnOpts.misc, 'testOpts') && isfield(obj.nnOpts.misc.testOpts, 'testColorSpace') && ~isempty(obj.nnOpts.misc.testOpts.testColorSpace)
                testAppendStr = sprintf('-%s', lower(obj.imdb.batchOpts.segments.colorTypes{obj.nnOpts.misc.testOpts.testColorSpace}));
            else
                testAppendStr = '';
            end
            epoch = numel(obj.stats.train);
            statsPath = fullfile(obj.nnOpts.expDir, sprintf('stats-%s-epoch%d%s.mat', subset, epoch, testAppendStr));
            labelingFolder = fullfile(obj.nnOpts.expDir, sprintf('labelings-%s-epoch%d%s', subset, epoch, testAppendStr));
            outputFolder = fullfile(obj.nnOpts.expDir, sprintf('outputMaps-%s-epoch%d%s', subset, epoch, testAppendStr));
            if exist(statsPath, 'file') && doCache
                % Get stats from disk
                stats = load(statsPath);
            else
                % Create output folder
                if ~exist(labelingFolder, 'dir')
                    mkdir(labelingFolder);
                end
                if ~exist(outputFolder, 'dir') && storeOutputMaps
                    mkdir(outputFolder);
                end
                
                % Limit images if specified (for quicker evaluation)
                if ~isinf(limitImageCount)
                    sel = randperm(numel(obj.imdb.data.test), min(limitImageCount, numel(obj.imdb.data.test)));
                    obj.imdb.data.test = obj.imdb.data.test(sel);
                end
                
                % Init
                imageCount = numel(obj.imdb.data.test); % even if we test on train it must say "test" here
                confusion = zeros(obj.imdb.numClasses, obj.imdb.numClasses);
                evalTimer = tic;
                
                % Prepare colors for visualization
                labelNames = obj.imdb.dataset.getLabelNames();
                colorMapping = pascalColors(obj.imdb.numClasses);
                colorMappingError = [0, 0, 0; ...    % background
                    1, 0, 0; ...    % too much
                    1, 1, 0; ...    % too few
                    0, 1, 0; ...    % rightClass
                    0, 0, 1];       % wrongClass
                
                % Set network to testing mode
                outputVarIdx = obj.prepareNetForTest();
                
                for imageIdx = 1 : imageCount                    
                    % Check whether GT labels are available for this image
                    imageName = obj.imdb.data.test{imageIdx};
                    labelMap = obj.imdb.dataset.getImLabelMap(imageName);
                    if all(labelMap(:) == 0)
                        continue;
                    end
                    
                    % Get batch
                    inputs = obj.imdb.getBatch(imageIdx, obj.net, obj.nnOpts);
                    
                    % Run forward pass
                    obj.net.eval(inputs);
                    
                    % Get pixel level predictions
                    scores = obj.net.vars(outputVarIdx).value;
                    [~, outputMap] = max(scores, [], 3);
                    outputMap = gather(outputMap);
                    
                    % Update confusion matrix
                    ok = labelMap > 0;
                    confusion = confusion + accumarray([labelMap(ok), outputMap(ok)], 1, size(confusion));
                    
                    % Plot example images
                    if mod(imageIdx - 1, plotFreq) == 0 || imageIdx == imageCount
                        
                        % Create tiled image with image+gt+outputMap
                        if true
                            % Create tiling
                            tile = ImageTile();
                            
                            % Add GT image
                            image = obj.imdb.dataset.getImage(imageName) * 255;
                            tile.addImage(image / 255);
                            labelMapIm = ind2rgb(double(labelMap), colorMapping);
                            labelMapIm = imageInsertBlobLabels(labelMapIm, labelMap, labelNames);
                            tile.addImage(labelMapIm);
                            
                            % Add prediction image
                            outputMapNoBg = outputMap;
                            outputMapNoBg(labelMap == 0) = 0;
                            outputMapIm = ind2rgb(outputMapNoBg, colorMapping);
                            outputMapIm = imageInsertBlobLabels(outputMapIm, outputMapNoBg, labelNames);
                            tile.addImage(outputMapIm);
                            
                            % Highlight differences between GT and outputMap
                            errorMap = ones(size(labelMap));
                            
                            % For datasets without bg
                            rightClass = labelMap == outputMap & labelMap >= 1;
                            wrongClass = labelMap ~= outputMap & labelMap >= 1;
                            errorMap(rightClass) = 4;
                            errorMap(wrongClass) = 5;
                            errorIm = ind2rgb(double(errorMap), colorMappingError);
                            tile.addImage(errorIm);
                            
                            % Save segmentation
                            image = tile.getTiling('totalX', numel(tile.images), 'delimiterPixels', 1, 'backgroundBlack', false);
                            imPath = fullfile(labelingFolder, [imageName, '.png']);
                            imwrite(image, imPath);
                        end
                    end
                    
                    % Store outputMaps to disk
                    if storeOutputMaps
                        outputPath = fullfile(outputFolder, [imageName, '.mat']);
                        if obj.imdb.numClasses > 70
                            save(outputPath, 'outputMap');
                        else
                            save(outputPath, 'outputMap', 'scores');
                        end
                    end
                    
                    % Print message
                    if mod(imageIdx - 1, plotFreq) == 0 || imageIdx == imageCount
                        evalTime = toc(evalTimer);
                        fprintf('Processing image %d of %d (%.2f Hz)...\n', imageIdx, imageCount, imageIdx / evalTime);
                    end
                end
                
                % Final statistics, remove classes missing in test
                % Note: Printing statistics earlier does not make sense if we remove missing
                % classes
                [stats.pacc, stats.macc, stats.miu] = confMatToAccuracies(confusion);
                stats.confusion = confusion;
                fprintf('Results:\n');
                fprintf('pixelAcc: %5.2f%%, meanAcc: %5.2f%%, meanIU: %5.2f%%\n', ...
                    100 * stats.pacc, 100 * stats.macc, 100 * stats.miu);
                
                % Save results
                if doCache
                    if exist(statsPath, 'file'),
                        error('StatsPath already exists: %s', statsPath);
                    end
                    save(statsPath, '-struct', 'stats');
                end
            end
        end
    end
end