classdef SegmentationLossImage < dagnn.Loss
    % SegmentationLossImage
    %
    % Same as SegmentationLossPixel, but weakly supervised following
    % "What's the point: Semantic segmentation with point supervision" by
    % Russakovsky et al., arxiv 2015
    %
    % scoresMap -> scoresMapSoftmax -> scoresImageSoftmax -> scoresImageSoftmaxAbs
    % -> loss <-
    % dzdImageSoftmax <- dzdMapSoftmax <- dzdMap
    %
    % Inputs: scoresMap, labelsImage, [classWeights], [masksThingsCell]
    % Outputs: loss
    %
    % Note: All weights can be empty, which means they are ignored.
    %
    % Copyright by Holger Caesar, 2016
    
    
    properties
        useAbsent = true;
        useScoreDiffs = false;
        presentWeight = 1 / 2;
        absentWeight = 1 / 2
    end
    
    properties (Transient)
        mask
        scoresMapSoftmax
        scoresImageSoftmaxAbs
        instanceWeights
        isPresent
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            
            %%%% Get inputs
            assert(numel(inputs) == 4);
            scoresMap = inputs{1};
            labelsImageCell = inputs{2};
            classWeights = inputs{3};
            masksThingsCell = inputs{4};
            labelCount = size(scoresMap, 3);
            imageCount = size(scoresMap, 4);
            sampleCount = labelCount * imageCount;
            labelsDummy = repmat(1:labelCount, [1, imageCount]);
            labelsDummy = reshape(labelsDummy, 1, 1, 1, []);
            assert(~any(cellfun(@(x) isempty(x), labelsImageCell)));
            assert((obj.absentWeight == 0 & ~obj.useAbsent) | (obj.absentWeight ~= 0 & obj.useAbsent == 1));
            
            %%%% Pixel to image mapping
            % Softmax pixel-level scores
            if true
                % Compute loss
                % To simplify things we remove the subtraction of Xmax from
                % X, which is supposed to reduce numerical problems
                X = scoresMap;
                ex = exp(bsxfun(@minus, X, max(X, [], 3)));
                sumEx = sum(ex, 3);
                obj.scoresMapSoftmax = bsxfun(@rdivide, ex, sumEx);
            end
            
            % Get the scores of the pixel with the highest score per GT label
            [scoresImageSoftmax, obj.mask] = segmentationLossImage_extractMaxScores(obj, labelCount, sampleCount, imageCount, masksThingsCell);
            
            %%% Loss function adapted from vl_nnloss
            if true,
                % Get presence/absence info
                presentInds = cell(imageCount, 1);
                for imageIdx = 1 : imageCount,
                    presentInds{imageIdx} = labelsImageCell{imageIdx} + (imageIdx-1) * labelCount;
                end;
                presentInds = cell2mat(presentInds);
                obj.isPresent = ismember(1:sampleCount, presentInds)';
                
                % Take 1 - p for classes missing in the image
                % (make sure that no probability becomes 0, as that will
                % cause infs in the loss)
                obj.scoresImageSoftmaxAbs = scoresImageSoftmax;
                if obj.useAbsent
                    obj.scoresImageSoftmaxAbs(:, :, :, ~obj.isPresent) = 1 - obj.scoresImageSoftmaxAbs(:, :, :, ~obj.isPresent);
                    obj.scoresImageSoftmaxAbs = max(1e-8, obj.scoresImageSoftmaxAbs);
                    
                    % Renormalize the absent scores
                    divisor = sum(obj.scoresImageSoftmaxAbs(:, :, :, ~obj.isPresent), 3) / (labelCount-1);
                    obj.scoresImageSoftmaxAbs(:, :, :, ~obj.isPresent) = bsxfun(@rdivide, obj.scoresImageSoftmaxAbs(:, :, :, ~obj.isPresent), divisor);
                end
                
                X = obj.scoresImageSoftmaxAbs;
                c = labelsDummy;
                
                % from category labels to indexes
                inputSize = [size(X, 1) size(X, 2) size(X, 3) size(X, 4)];
                labelSize = [size(c, 1) size(c, 2) size(c, 3) size(c, 4)];
                numPixelsPerImage = prod(inputSize(1:2));
                numPixels = numPixelsPerImage * inputSize(4);
                imageVolume = numPixelsPerImage * inputSize(3);
                
                n = reshape(0:numPixels-1, labelSize);
                offset = 1 + mod(n, numPixelsPerImage) + ...
                    imageVolume * fix(n / numPixelsPerImage);
                ci = offset + numPixelsPerImage * max(c - 1, 0);
                
                % Compute loss
                t = -log(X(ci));
                
                % Weight per class
                obj.instanceWeights = ones(1, 1, 1, sampleCount);
                if ~isempty(classWeights)
                    obj.instanceWeights = obj.instanceWeights .* classWeights(labelsDummy);
                end
                
                % Normalize weights per image
                sampleImage = repmatEach(1:imageCount, labelCount);
                for imageIdx = 1 : imageCount
                    selPresent = sampleImage == imageIdx &  obj.isPresent;
                    selAbsent  = sampleImage == imageIdx & ~obj.isPresent;
                    obj.instanceWeights(selPresent) = obj.instanceWeights(selPresent) ./ (sum(obj.instanceWeights(selPresent)) / obj.presentWeight);
                    obj.instanceWeights(selAbsent)  = obj.instanceWeights(selAbsent ) ./ (sum(obj.instanceWeights(selAbsent )) / obj.absentWeight );
                end
                
                % Apply weights
                loss = sum(t .* obj.instanceWeights);
            end;
            
            % Debug: how many labels are really present?
            if false
                imageIdx = 1; %#ok<UNRCH>
                [~, pixPred] = max(scoresMap(:, :, :, imageIdx), [], 3);
                histo = histc(pixPred(:), 1:labelCount);
                [histo, ismember(1:labelCount, labelsImageCell{imageIdx})'];
                presentPredCount = nnz(histo);
                presentGtCount = numel(labelsImageCell{imageIdx});
                presentDiff = presentGtCount - presentPredCount;
            end
            
            %%%% Assign outputs
            outputs{1} = loss;
            
            % Update statistics
            assert(~isnan(loss) && ~isinf(loss));
            n = obj.numAveraged;
            m = n + imageCount;
            obj.average = (n * obj.average + double(gather(loss))) / m;
            obj.numAveraged = m;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>
            % Modifications for absent classes: 1 / x becomes - 1 / (1 - x)
            % scoresImageSoftmaxAbs contains 1 - x
            % - dzdImageSoftmax(ci(~obj.isPresent)) changes the sign
            
            %%%% Get inputs
            assert(numel(inputs) == 4);
            scoresMap = inputs{1};
            imageSizeY = size(scoresMap, 1);
            labelCount = size(scoresMap, 3);
            imageCount = size(scoresMap, 4);
            labelsDummy = repmat(1:labelCount, [1, imageCount]);
            labelsDummy = reshape(labelsDummy, 1, 1, 1, []);
            
            assert(numel(derOutputs) == 1);
            dzdOutput = derOutputs{1};
            
            %%%% Loss derivatives
            %%% Output to image-level
            if true,
                X = obj.scoresImageSoftmaxAbs;
                c = labelsDummy;
                
                inputSize = [size(X, 1), size(X, 2), size(X, 3), size(X, 4)];
                labelSize = [size(c, 1), size(c, 2), size(c, 3), size(c, 4)];
                assert(isequal(labelSize(1:2), inputSize(1:2)));
                assert(labelSize(4) == inputSize(4));
                
                % from category labels to indexes
                numPixelsPerImage = prod(inputSize(1:2));
                numPixels = numPixelsPerImage * inputSize(4);
                imageVolume = numPixelsPerImage * inputSize(3);
                
                n = reshape(0:numPixels-1, labelSize);
                offset = 1 + mod(n, numPixelsPerImage) + ...
                    imageVolume * fix(n / numPixelsPerImage);
                ci = offset + numPixelsPerImage * max(c - 1,0);
                
                % Weight gradients per instance
                dzdOutput = dzdOutput * obj.instanceWeights;
                
                % Compute gradients for log-loss
                dzdImageSoftmax = zeros(size(X), 'like', X);
                dzdImageSoftmax(ci) = - dzdOutput ./ X(ci);
                if obj.useAbsent
                    % For opposite probabilities the gradients includes an
                    % additional minus sign
                    dzdImageSoftmax(ci(~obj.isPresent)) = - dzdImageSoftmax(ci(~obj.isPresent));
                end
            end;
            
            %%% Image to pixel-level
            dzdMapSoftmax = zeros(size(scoresMap), 'like', obj.scoresImageSoftmaxAbs);
            for imageIdx = 1 : imageCount
                for labelIdx = 1 : labelCount
                    if ~obj.useAbsent && ~obj.isPresent(labelIdx)
                        % Skip irrelevant labels
                        continue;
                    end
                    offset = (imageIdx-1) * labelCount;
                    sampleIdx = offset + labelIdx;
                    pos = obj.mask(sampleIdx, 1);
                    x = 1 + floor((pos-1) / imageSizeY);
                    y = pos - (x-1) * imageSizeY;
                    
                    dzdMapSoftmax(y, x, :, imageIdx) = dzdMapSoftmax(y, x, :, imageIdx) + dzdImageSoftmax(1, 1, :, sampleIdx);
                end
            end
            
            %%% Softmax to non-softmax
            dzdMap = obj.scoresMapSoftmax .* bsxfun(@minus, dzdMapSoftmax, sum(dzdMapSoftmax .* obj.scoresMapSoftmax, 3));
            
            %%%% Assign outputs
            derInputs = cell(1, 4);
            derInputs{1} = dzdMap;
            derInputs{2} = [];
            derInputs{3} = [];
            derInputs{4} = [];
            derParams = {};
        end
        
        function obj = SegmentationLossImage(varargin)
            obj.load(varargin);
        end
        
        function forwardAdvanced(obj, layer)
            % Modification: Overrides standard forward pass to avoid giving up when any of
            % the inputs is empty.
            
            in = layer.inputIndexes;
            out = layer.outputIndexes;
            par = layer.paramIndexes;
            net = obj.net;
            inputs = {net.vars(in).value};
            
            % clear inputs if not needed anymore
            for v = in
                net.numPendingVarRefs(v) = net.numPendingVarRefs(v) - 1;
                if net.numPendingVarRefs(v) == 0
                    if ~net.vars(v).precious && ~net.computingDerivative && net.conserveMemory
                        net.vars(v).value = [];
                    end
                end
            end
            
            % call the simplified interface
            outputs = obj.forward(inputs, {net.params(par).value});
            for oi = 1:numel(out)
                net.vars(out(oi)).value = outputs{oi};
            end
        end
    end
end