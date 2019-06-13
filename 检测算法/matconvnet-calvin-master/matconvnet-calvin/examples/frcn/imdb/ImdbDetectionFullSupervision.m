classdef ImdbDetectionFullSupervision < ImdbMatbox
    properties(SetAccess = protected, GetAccess = public)
        negOverlapRange = [0.1 0.5];
        boxesPerIm = 64;
        boxRegress = true;
        instanceWeighting = false;
        maxImageSize = 600;
    end
    methods
        function obj = ImdbDetectionFullSupervision(imageDir, imExt, matboxDir, filenames, datasetIdx, meanIm)
            obj@ImdbMatbox(imageDir, imExt, matboxDir, filenames, datasetIdx, meanIm);
        end
        
        function [batchData, numElements] = getBatch(obj, batchInds, net, ~)
            if length(batchInds) > 1
                error('Error: Only supports subbatches of 1!');
            end
            
            if nargin == 2
                gpuMode = false;
            else
                gpuMode = strcmp(net.device, 'gpu');
            end

            % Load image. Make correct size. Subtract average im.
            [image, oriImSize] = obj.LoadImage(batchInds, gpuMode);
            
            % Sample boxes
            gStruct = obj.LoadGStruct(batchInds);
            
            % Flip the image and boxes at training time
            % Note: flipLR alternates between true and false in ImdbMatbox.initEpoch()
            if obj.flipLR && strcmp(obj.datasetMode, 'train')
                currImT = fliplr(image);
                currBoxesT = gStruct.boxes;
                currBoxesT(:,3) = oriImSize(2) - gStruct.boxes(:,1) + 1;
                currBoxesT(:,1) = oriImSize(2) - gStruct.boxes(:,3) + 1;
                gStruct.boxes = currBoxesT;
                image = currImT;
            end
            
            if ismember(obj.datasetMode, {'train', 'val'})
                [boxes, labels, ~, overlapScores, regressionFactors] = obj.SamplePosAndNegFromGstruct(gStruct, obj.boxesPerIm);

                % Assign elements to cell array for use in training the network
                numElements = obj.boxesPerIm;
                
                numBatchFields = 2 * (4 + obj.boxRegress + obj.instanceWeighting);
                batchData = cell(numBatchFields, 1);
                idx = 1;
                batchData{idx} = 'input';       idx = idx + 1;
                batchData{idx} = image;         idx = idx + 1;
                batchData{idx} = 'label';       idx = idx + 1;
                batchData{idx} = labels';       idx = idx + 1;
                batchData{idx} = 'boxes';       idx = idx + 1;
                batchData{idx} = boxes';        idx = idx + 1;
                batchData{idx} = 'oriImSize';   idx = idx + 1;
                batchData{idx} = oriImSize;     idx = idx + 1;
                
                if obj.boxRegress
                    batchData{idx} = 'regressionTargets';   idx = idx + 1;
                    batchData{idx} = regressionFactors';    idx = idx + 1;                    
                end
                if obj.instanceWeighting
                    instanceWeights = overlapScores;
                    instanceWeights(labels == 1) = 1;
                    instanceWeights = reshape(instanceWeights, [1 1 1 length(instanceWeights)]); % VL-Feat way :-S
                    batchData{idx} = 'instanceWeights';     idx = idx + 1;
                    batchData{idx} = instanceWeights;       %idx = idx + 1;
                end
                
            else
                % Test set. Get all boxes
                numElements = size(gStruct.boxes,1);
                batchData{6} = oriImSize;
                batchData{5} = 'oriImSize';
                batchData{4} = gStruct.boxes';
                batchData{3} = 'boxes';
                batchData{2} = image;
                batchData{1} = 'input';
            end
            
        end
        
        function [image, oriImSize] = LoadImage(obj, batchIdx, gpuMode)
            % image = LoadImage(obj, batchIdx)
            % Loads an image from disk, resizes it, and subtracts the mean image
            imageT = single(imread([obj.imageDir obj.data.(obj.datasetMode){batchIdx} obj.imExt]));
            oriImSize = double(size(imageT));
            if numel(obj.meanIm) == 3
                for colourI = 1:3
                    imageT(:,:,colourI) = imageT(:,:,colourI) - obj.meanIm(colourI);
                end
            else
                imageT = imageT - imresize(obj.meanIm, [oriImSize(1) oriImSize(2)]); % Subtract mean im
            end
            
            % Resize image to be at most x pixels in each dimension
            % If you notice a "CUDA_ERROR_ILLEGAL_ADDRESS" error, use a
            % smaller maximum image size.
            resizeFactor = obj.maxImageSize / max(oriImSize(1:2));
            if gpuMode
                image = gpuArray(imageT);
                image = imresize(image, resizeFactor);
            else
                image = imresize(imageT, resizeFactor, 'bilinear', 'antialiasing', false);
            end
        end
        
        
        function [boxes, labels, keys, overlapScores, regressionTargets] = SamplePosAndNegFromGstruct(obj, gStruct, numSamples)
            % Get positive, negative, and true GT keys
            [maxOverlap, classOverlap] = max(gStruct.overlap, [], 2);

            posKeys = find(maxOverlap >= 0.5 & gStruct.class == 0);
            negKeys = find(maxOverlap < obj.negOverlapRange(2) & maxOverlap >= obj.negOverlapRange(1) & gStruct.class == 0);
            gtKeys = find(gStruct.class > 0);

            % Get correct number of positive and negative samples
            numExtraPos = numSamples * obj.posFraction - length(gtKeys);
            numExtraPos = min(numExtraPos, length(posKeys));
            if numExtraPos > 0
                posKeys = posKeys(randperm(length(posKeys), numExtraPos));
            else
               numExtraPos = 0;
            end
            numNeg = numSamples - numExtraPos - length(gtKeys);
            numNeg = min(numNeg, length(negKeys));
            negKeys = negKeys(randperm(length(negKeys), numNeg));

            % Concatenate for final keys and labs
            keys = cat(1, gtKeys, posKeys, negKeys);
            labels = cat(1, gStruct.class(gtKeys), classOverlap(posKeys), zeros(numNeg, 1));
            labels = single(labels + 1); % Add 1 for background class
            boxes = gStruct.boxes(keys,:);

            overlapScores = cat(1, ones(length(gtKeys),1), maxOverlap(posKeys), maxOverlap(negKeys));
            
            % Calculate regression targets.
            % Jasper: I simplify Girshick by implementing regression through four
            % scalars which scale the box with respect to its center.
            if nargout == 5
                % Create NaN array: nans represent numbers which will not be active
                % in regression
                regressionTargets = nan([size(boxes,1) 4 * obj.numClasses], 'like', boxes);
                
                % Get scaling factors for all positive boxes
                gtBoxes = gStruct.boxes(gtKeys,:);
                for bI = 1:length(gtKeys)+length(posKeys)
                    % Get current box and corresponding GT box
                    currPosBox = boxes(bI,:);
                    [~, gtI] = BoxBestOverlapFastRcnn(gtBoxes, currPosBox);
                    currGtBox = gtBoxes(gtI,:);
                    
                    % Get range of regression target based on the label of the gt box
                    targetRangeBegin = 4 * (labels(bI)-1)+1;
                    targetRange = targetRangeBegin:(targetRangeBegin+3);
                    
                    % Set regression targets
                    regressionTargets(bI, targetRange) = BoxRegressionTargetGirshick(currGtBox, currPosBox);
                end
            end 
        end
        
        function SetBoxRegress(obj, doRegress)
            obj.boxRegress = doRegress;
        end
        
        function SetInstanceWeighting(obj, doInstanceWeighting)
            obj.instanceWeighting = doInstanceWeighting;
        end
    end % End methods
end % End classdef