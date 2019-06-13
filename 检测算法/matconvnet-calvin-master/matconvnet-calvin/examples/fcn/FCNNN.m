classdef FCNNN < CalvinNN
    % FCNNN Fully Convolutional Network class implemented as subclass of
    % CalvinNN.
    %
    % Copyright by Holger Caesar, 2016
    
    methods
        function obj = FCNNN(net, imdb, nnOpts)
            obj = obj@CalvinNN(net, imdb, nnOpts);
        end
        
        function convertNetwork(obj)
            % convertNetwork(obj)
            %
            % Does not call the equivalent function in CalvinNN.
            
            fprintf('Converting test AlexNet-style network to train FCN (1x1 convolutions, loss, etc.)...\n');
            
            % Get initial model from VGG-VD-16
            obj.net = fcnInitializeModelGeneric(obj.imdb, 'sourceModelPath', obj.nnOpts.misc.netPath, ...
                'init', obj.nnOpts.misc.init, 'initLinCombPath', obj.nnOpts.misc.initLinCombPath);
            if any(strcmp(obj.nnOpts.misc.modelType, {'fcn16s', 'fcn8s'}))
                % upgrade model to FCN16s
                obj.net = fcnInitializeModel16sGeneric(obj.imdb.numClasses, obj.net);
            end
            if strcmp(obj.nnOpts.misc.modelType, 'fcn8s')
                % upgrade model fto FCN8s
                obj.net = fcnInitializeModel8sGeneric(obj.imdb.numClasses, obj.net);
            end
            obj.net.meta.normalization.rgbMean = obj.imdb.batchOpts.rgbMean;
            obj.net.meta.classes = obj.imdb.batchOpts.classes.name;
            
            if obj.nnOpts.misc.weaklySupervised
                wsPresentWeight = 1 / (1 + wsUseAbsent);
                
                if obj.nnOpts.misc.wsEqualWeight
                    wsAbsentWeight = obj.imdb.numClasses * wsUseAbsent;
                else
                    wsAbsentWeight = 1 - wsPresentWeight;
                end
            else
                wsPresentWeight = [];
                wsAbsentWeight = [];
            end
            
            % Replace unweighted loss layer
            layerFS = dagnn.SegmentationLossPixel();
            layerWS = dagnn.SegmentationLossImage('useAbsent', obj.nnOpts.misc.wsUseAbsent, 'useScoreDiffs', obj.nnOpts.misc.wsUseScoreDiffs, 'presentWeight', wsPresentWeight, 'absentWeight', wsAbsentWeight);
            objIdx = obj.net.getLayerIndex('objective');
            assert(strcmp(obj.net.layers(objIdx).block.loss, 'softmaxlog'));
            
            % Add a layer that automatically decides whether to use FS or WS
            layerSS = dagnn.SegmentationLossSemiSupervised('layerFS', layerFS, 'layerWS', layerWS);
            layerSSInputs = [obj.net.layers(objIdx).inputs, {'labelsImage', 'classWeights', 'isWeaklySupervised', 'masksThingsCell'}];
            layerSSOutputs = obj.net.layers(objIdx).outputs;
            obj.net.removeLayer('objective');
            obj.net.addLayer('objective', layerSS, layerSSInputs, layerSSOutputs, {});
            
            % Accuracy layer
            if obj.imdb.dataset.annotation.hasPixelLabels
                % Replace accuracy layer with 21 classes by flexible accuracy layer
                accIdx = obj.net.getLayerIndex('accuracy');
                accLayer = obj.net.layers(accIdx);
                accInputs = accLayer.inputs;
                accOutputs = accLayer.outputs;
                accBlock = dagnn.SegmentationAccuracyFlexible('labelCount', obj.imdb.numClasses);
                obj.net.removeLayer('accuracy');
                obj.net.addLayer('accuracy', accBlock, accInputs, accOutputs, {});
            else
                % Remove accuracy layer if no pixel-level labels exist
                obj.net.removeLayer('accuracy');
            end
            
            % Add similarity mapping layer
            if isfield(obj.nnOpts.misc, 'useSimilarityLoss') && obj.nnOpts.misc.useSimilarityLoss
                % Get class similarities from hierarchy
                similarities = obj.imdb.dataset.hierarchyDistances;
                
                if obj.nnOpts.misc.similarityLossNonLinear
                    % 2nd setup
                    % Use a similarity function that scales distances more non-linearly
                    % and attributes ~80% of contributions to the true class
                    % (afterwards mean(diag(similarities)) ~ 0.8)
                    similarities = 0.17 .^ (similarities);
                elseif obj.nnOpts.misc.similarityLossClose
                    % 3rd setup: TODO: replace dummy values after testing
                    % equivalence
                    newSimilarities = zeros(size(similarities));
                    newSimilarities(similarities == 0) = 1; %0.9;
                    newSimilarities(similarities == 2) = 0; %0.1;
                    similarities = newSimilarities;
                else
                    % 1st setup
                    similarities = 1 - similarities ./ max(similarities(:));
                end
                
                % Renormalize similarities to sum to 1 per class
                similarities = bsxfun(@rdivide, similarities, sum(similarities, 2));
                
                % Add similarity mapping layer
                block = dagnn.SimilarityMap('similarities', similarities);
                obj.net.addLayer('similaritymap', block, {'prediction', 'label'}, {'predictionmixed'});
                
                % Rename loss input
                lossName = 'objective';
                lossIdx = obj.net.getLayerIndex(lossName);
                obj.net.layers(lossIdx).inputs{1} = 'predictionmixed';
                obj.net.rebuild();
            end
            
            % Sort layers by their first occurrence
            sortLayers(obj.net);
        end
        
        function[stats] = testOnSet(obj, varargin)
            % [stats] = testOnSet(obj, varargin)
            
            % Initial settings
            p = inputParser;
            addParameter(p, 'subset', 'test');
            addParameter(p, 'limitImageCount', Inf);
            addParameter(p, 'findMapping', false);
            addParameter(p, 'storeOutputMaps', false);
            addParameter(p, 'plotFreq', 15);
            parse(p, varargin{:});
            
            subset = p.Results.subset;
            limitImageCount = p.Results.limitImageCount;
            findMapping = p.Results.findMapping;
            storeOutputMaps = p.Results.storeOutputMaps;
            plotFreq = p.Results.plotFreq;
            
            % Set the datasetMode to be active
            if strcmp(subset, 'test'),
                temp = [];
            else
                temp = obj.imdb.data.test;
                obj.imdb.data.test = obj.imdb.data.(subset);
            end
            
            % Run test
            stats = obj.test('subset', subset, 'limitImageCount', limitImageCount, 'findMapping', findMapping, 'storeOutputMaps', storeOutputMaps, 'plotFreq', plotFreq);
            
            % Restore the original test set
            if ~isempty(temp),
                obj.imdb.data.test = temp;
            end;
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
            featFolder = fullfile(obj.nnOpts.expDir, sprintf('features-%s-%s-epoch%d', outputVarName, subset, epoch));
            if ~exist(featFolder, 'dir')
                mkdir(featFolder);
            end
            
            for imageIdx = 1 : imageCount,
                printProgress('Classifying images', imageIdx, imageCount, 10);
                
                % Get batch
                inputs = obj.imdb.getBatch(imageIdx, obj.net);
                
                % Run forward pass
                obj.net.eval(inputs);
                
                % Extract probs
                curProbs = obj.net.vars(outputVarIdx).value;
                curProbs = gather(curProbs);
                
                % Store
                imageName = imageList{imageIdx};
                featPath = fullfile(featFolder, [imageName, '.mat']);
                features = double(curProbs); %#ok<NASGU>
                save(featPath, 'features', '-v7.3');
            end;
            
            % Reset test set
            obj.imdb.data.test = tempTest;
        end
        
        function[outputVarIdx] = prepareNetForTest(obj)
            % [outputVarIdx] = prepareNetForTest(obj)
            
            % Move to GPU
            if ~isempty(obj.nnOpts.gpus),
                obj.net.move('gpu');
            end;
            
            % Enable test mode
            obj.imdb.setDatasetMode('test');
            obj.net.mode = 'test';
            
            % Remove accuracy layer
            accuracyIdx = obj.net.getLayerIndex('accuracy');
            if ~isnan(accuracyIdx),
                obj.net.removeLayer('accuracy');
            end;
            
            % Remove SimilarityMap layer
            simMapName = 'similaritymap';
            simMapIdx = obj.net.getLayerIndex(simMapName);
            if ~isnan(simMapIdx)
                % Change loss input
                lossIdx = obj.net.getLayerIndex('objective');
                obj.net.layers(lossIdx).inputs{1} = 'prediction';
                
                % Remove layer
                obj.net.removeLayer(simMapName);
            end
            
            % Remove loss or replace by normal softmax
            lossIdx = find(cellfun(@(x) isa(x, 'dagnn.Loss'), {obj.net.layers.block}));
            lossName = obj.net.layers(lossIdx).name;
            lossType = obj.net.layers(lossIdx).block.loss;
            lossInputs = obj.net.layers(lossIdx).inputs;
            if strcmp(lossType, 'softmaxlog'),
                obj.net.removeLayer(lossName);
                outputLayerName = 'softmax';
                outputVarName = 'scores';
                obj.net.addLayer(outputLayerName, dagnn.SoftMax(), lossInputs{1}, outputVarName, {});
                outputVarIdx = obj.net.getVarIndex(outputVarName);
            elseif strcmp(lossType, 'log'),
                % Only output the scores of the regiontopixel layer
                obj.net.removeLayer(lossName);
                outputVarIdx = obj.net.getVarIndex(obj.net.getOutputs{1});
            else
                error('Error: Unknown loss function!');
            end;
            assert(numel(outputVarIdx) == 1);
        end
        
        function[stats] = test(obj, varargin)
            % [stats] = test(obj, varargin)
            
            % Initial settings
            p = inputParser;
            addParameter(p, 'subset', 'test');
            addParameter(p, 'limitImageCount', Inf);
            addParameter(p, 'doCache', true);
            addParameter(p, 'findMapping', false);
            addParameter(p, 'plotFreq', 15);
            addParameter(p, 'storeOutputMaps', false);
            parse(p, varargin{:});
            
            subset = p.Results.subset;
            limitImageCount = p.Results.limitImageCount;
            doCache = p.Results.doCache;
            findMapping = p.Results.findMapping;
            plotFreq = p.Results.plotFreq;
            storeOutputMaps = p.Results.storeOutputMaps;
            
            epoch = numel(obj.stats.train);
            statsPath = fullfile(obj.nnOpts.expDir, sprintf('stats-%s-epoch%d.mat', subset, epoch));
            labelingDir = fullfile(obj.nnOpts.expDir, sprintf('labelings-%s-epoch%d', subset, epoch));
            mapOutputFolder = fullfile(obj.nnOpts.expDir, sprintf('outputMaps-%s-epoch%d', subset, epoch));
            if exist(statsPath, 'file'),
                % Get stats from disk
                stats = load(statsPath);
            else
                % Limit images if specified (for quicker evaluation)
                if ~isinf(limitImageCount),
                    sel = randperm(numel(obj.imdb.data.test), min(limitImageCount, numel(obj.imdb.data.test)));
                    obj.imdb.data.test = obj.imdb.data.test(sel);
                end;
                
                % Set network to testing mode
                outputVarIdx = obj.prepareNetForTest();
                
                % Create output folder
                if storeOutputMaps && ~exist(mapOutputFolder, 'dir')
                    mkdir(mapOutputFolder)
                end
                if ~exist(labelingDir, 'dir')
                    mkdir(labelingDir);
                end
                
                % Prepare colors for visualization
                labelNames = obj.imdb.dataset.getLabelNames();
                cmap = obj.imdb.dataset.cmap;
                colorMapping = cmap(obj.imdb.numClasses);
                colorMappingError = [0, 0, 0; ...    % background
                    0, 0, 1; ...    % too much
                    1, 1, 0; ...    % too few
                    0, 1, 0; ...    % rightClass
                    1, 0, 0];       % wrongClass
                
                if findMapping
                    % Special mode where we use a net from a different dataset
                    labelNamesPred = getIlsvrcClsClassDescriptions()';
                    labelNamesPred = lower(labelNamesPred);
                    labelNamesPred = cellfun(@(x) x(1:min(10, numel(x))), labelNamesPred, 'UniformOutput', false);
                    colorMappingPred = pascalColors(numel(labelNamesPred));
                else
                    % Normal test mode
                    labelNamesPred = labelNames;
                    colorMappingPred = colorMapping;
                end
                
                % Init
                evalTimer = tic;
                imageCount = numel(obj.imdb.data.test); % even if we test on train it must say "test" here
                confusion = zeros(obj.imdb.numClasses, numel(labelNamesPred));
                
                for imageIdx = 1 : imageCount
                    % Get batch
                    inputs = obj.imdb.getBatch(imageIdx, obj.net, obj.nnOpts);
                    
                    % Get labelMap
                    imageName = obj.imdb.data.(obj.imdb.datasetMode){imageIdx};
                    labelMap = uint16(obj.imdb.batchOpts.imageNameToLabelMap(imageName));
                    if obj.imdb.batchOpts.translateLabels
                        % Before: 255 = ignore, 0 = bkg, 1:n = classes
                        % After : 0 = ignore, 1 = bkg, 2:n+1 = classes
                        labelMap = mod(labelMap + 1, 256);
                    end;
                    % 0 = ignore, 1:n = classes
                    
                    % Run forward pass
                    obj.net.eval(inputs);
                    
                    % Get pixel level predictions
                    scores = obj.net.vars(outputVarIdx).value;
                    [~, outputMap] = max(scores, [], 3);
                    outputMap = gather(outputMap);
                    outputMap = imresize(outputMap, size(labelMap), 'method', 'nearest');
                    
                    % Update confusion matrix
                    ok = labelMap > 0;
                    confusion = confusion + accumarray([labelMap(ok), outputMap(ok)], 1, size(confusion));
                    
                    % If a folder was specified, output the predicted label maps
                    if storeOutputMaps
                        outputPath = fullfile(mapOutputFolder, [imageName, '.mat']);
                        if obj.imdb.numClasses > 70
                            save(outputPath, 'outputMap');
                        else
                            save(outputPath, 'outputMap', 'scores');
                        end
                    end;
                    
                    % Plot example images
                    if mod(imageIdx - 1, plotFreq) == 0 || imageIdx == imageCount
                        % Create tiled image with image+gt+outputMap
                        if obj.imdb.dataset.annotation.labelOneIsBg
                            skipLabelInds = 1;
                        else
                            skipLabelInds = [];
                        end;
                        
                        % Create tiling
                        tile = ImageTile();
                        
                        if obj.imdb.dataset.annotation.labelOneIsBg
                            mapFormatter = @double;
                        else
                            mapFormatter = @uint16;
                        end
                        
                        % Add GT image
                        image = obj.imdb.dataset.getImage(imageName) * 255;
                        tile.addImage(image / 255);
                        labelMapIm = ind2rgb(mapFormatter(labelMap), colorMapping);
                        labelMapIm = imageInsertBlobLabels(labelMapIm, labelMap, labelNames, 'skipLabelInds', skipLabelInds);
                        tile.addImage(labelMapIm);
                        
                        % Add prediction image
                        outputMapNoBg = outputMap;
                        outputMapNoBg(labelMap == 0) = 0;
                        outputMapIm = ind2rgb(mapFormatter(outputMapNoBg), colorMappingPred);
                        outputMapIm = imageInsertBlobLabels(outputMapIm, outputMapNoBg, labelNamesPred, 'skipLabelInds', skipLabelInds);
                        tile.addImage(outputMapIm);
                        
                        % Highlight differences between GT and outputMap
                        if ~findMapping
                            errorMap = ones(size(labelMap));
                            if obj.imdb.dataset.annotation.labelOneIsBg
                                % Datasets where bg is 1 and void is 0 (i.e. VOC)
                                tooMuch = labelMap ~= outputMap & labelMap == 1 & outputMap >= 2;
                                tooFew  = labelMap ~= outputMap & labelMap >= 2 & outputMap == 1;
                                rightClass = labelMap == outputMap & labelMap >= 2 & outputMap >= 2;
                                wrongClass = labelMap ~= outputMap & labelMap >= 2 & outputMap >= 2;
                                errorMap(tooMuch) = 2;
                                errorMap(tooFew) = 3;
                                errorMap(rightClass) = 4;
                                errorMap(wrongClass) = 5;
                            else
                                % For datasets without bg
                                rightClass = labelMap == outputMap & labelMap >= 1;
                                wrongClass = labelMap ~= outputMap & labelMap >= 1;
                                errorMap(rightClass) = 4;
                                errorMap(wrongClass) = 5;
                            end
                            errorIm = ind2rgb(double(errorMap), colorMappingError);
                            tile.addImage(errorIm);
                        end
                        
                        % Add a map to show the maximum scores
                        % (~confidence)
                        heatMapBinCount = 255;
                        scoresMap = gather(max(scores, [], 3));
                        scoresThreshs = [prctile(scoresMap(:), linspace(0, 100, heatMapBinCount))'; Inf];
                        [~, ~, scoresInds] = histcounts(scoresMap, scoresThreshs);
                        scoresMapIm = ind2rgb(scoresInds, hot(heatMapBinCount));
                        tile.addImage(scoresMapIm);
                        
                        % Save segmentation
                        image = tile.getTiling('totalX', 3, 'delimiterPixels', 1, 'backgroundBlack', false);
                        imPath = fullfile(labelingDir, [imageName, '.png']);
                        imwrite(image, imPath);
                    end
                    
                    % Print message
                    if mod(imageIdx - 1, plotFreq) == 0 || imageIdx == imageCount
                        evalTime = toc(evalTimer);
                        fprintf('Processing image %d of %d (%.2f Hz)...\n', imageIdx, imageCount, imageIdx / evalTime);
                    end
                end;
                
                if findMapping
                    % Save mapping to disk
                    mappingPath = fullfile(obj.nnOpts.expDir, sprintf('mapping-%s.mat', subset));
                    save(mappingPath, 'confusion');
                else
                    % Final statistics, remove classes missing in test
                    % Note: Printing statistics earlier does not make sense if we remove missing
                    % classes
                    [stats.pacc, stats.macc, stats.miu] = confMatToAccuracies(confusion);
                    stats.confusion = confusion;
                    fprintf('Results:\n');
                    fprintf('pixelAcc: %5.2f, meanAcc: %5.2f, meanIU: %5.2f \n', 100 * stats.pacc, 100 * stats.macc, 100 * stats.miu);
                    
                    % Save results
                    if doCache
                        save(statsPath, '-struct', 'stats');
                    end
                end
            end
        end
    end
end
