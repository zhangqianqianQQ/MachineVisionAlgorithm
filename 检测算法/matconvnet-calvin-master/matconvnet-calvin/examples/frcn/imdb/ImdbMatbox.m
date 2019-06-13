classdef ImdbMatbox < ImdbCalvin
    % Imdb class for use with matconvnet, made in same style as the python imdb_calvin
    % class which is used in rcnn. You need to initialize the class with the following
    % arguments:
    %   imageDir:           directory with images
    %   imExt:              image extension {',jpg', '.png'}
    %   matBoxDir:          directory with matlab boxes, overlap, and class, girshick format
    %   filenames:          list of filenames without extension
    %   datasetIdx:         EITHER: cell array of size 1x3 with indices for train/val/test
    %                       OR:     percentages to use for train/val/test
    %   meanIm:             Average image (for CNN net)
    %
    % Filenames are created as 'imageDir + filenames[i] + imExt' and 'matBoxDir + filenames[i] + '.mat'
    %
    % Imdb class for easy use when you have .mat files with the following variables, per
    % Girshick style:
    %   boxes:      N x 4 single array
    %   class:      N x 1 uint16 array
    %   overlap:    N x C array with overlap scores for each box for class C
    %
    % Implements several useful functions to deal with the mat files
    %
    % Jasper Uijlings - 2015
    
    properties(SetAccess = protected, GetAccess = public)
        imageDir
        matBoxDir
        imExt
        meanIm
        targetClasses = [];
        posFraction = 0.25;
        minBoxSize = 20;
        
        flipLR = true;  % Flag if data will be flipped or not
    end
    
    methods
        % Constructor
        function obj = ImdbMatbox(imageDir, imExt, matBoxDir, filenames, datasetIdx, meanIm)
            % Set fields of the imdb class
            obj.imageDir = imageDir;
            obj.matBoxDir = matBoxDir;
            obj.imExt = imExt;
            obj.meanIm = single(meanIm);
            
            % Split into train/val/test
            if ~iscell(datasetIdx)
                % We have three numbers specifying the random split
                if sum(datasetIdx) ~= 1
                    error('Complete dataset should be divided');
                end
                
                % Randomly split the data
                idx = randperm(length(filenames));
                numTrain = length(filenames) * datasetIdx(1);
                numVal = length(filenames) * datasetIds(2);
                
                idxTrain = idx(1:numTrain);
                idxVal = idx(numTrain+1:numTrain+1+numVal);
                idxTest = idx(numTrain+1+numVal+1:end);
                obj.imagesTrain = filenames(idxTrain);
                obj.imagsVal = filenames(idxVal);
                obj.imagesTest = filenames(idxTest);
            else
                % We have cell arrays specifying the predefined split
                % Check if split is correct
                allIdx = cat(1, datasetIdx{:});
                if ~isequal(sort(allIdx), (1:length(filenames))')
                    warning('Dataset not correctly divided');
                end
                
                obj.data.train = filenames(datasetIdx{1});
                obj.data.val = filenames(datasetIdx{2});
                obj.data.test = filenames(datasetIdx{3});
            end
            
            % Get number of classes
            obj.setDatasetMode('train');
            gStruct = obj.LoadGStruct(1);
            obj.numClasses = size(gStruct.overlap, 2) + 1; % Plus 1 for background class
        end
        
        
        % Set positive fraction
        function SetPosFraction(obj, thePosFraction)
            obj.posFraction = thePosFraction;
        end
        
        % Set target classes. Useful for debugging purposes
        function SetTargetClasses(obj, targetClasses)
            obj.targetClasses = targetClasses;
            obj.numClasses = length(targetClasses);
        end
        
        % Load gStruct
        function gStruct = LoadGStruct(obj,imI)
            gStruct = load([obj.matBoxDir obj.data.(obj.datasetMode){imI} '.mat']);
            
            % Make sure that no GT boxes/labels/etc are given when using test phase
            if strcmp(obj.datasetMode, 'test')
                goodIds = ~(gStruct.gt);
                gStruct.gt = gStruct.gt(goodIds);
                gStruct.overlap = zeros(size(gStruct.overlap(goodIds,:)), 'single');
                gStruct.boxes = gStruct.boxes(goodIds,:);
                gStruct.class = zeros(size(gStruct.class(goodIds,:)), 'uint16');
            end
            
            % Remove small boxes
            [nR, nC] = BoxSize(gStruct.boxes);
            badI = ((nR < obj.minBoxSize) | (nC < obj.minBoxSize)) & ~gStruct.gt;
            gStruct.gt = gStruct.gt(~badI,:);
            gStruct.overlap = gStruct.overlap(~badI,:);
            gStruct.boxes = gStruct.boxes(~badI,:);
            gStruct.class = gStruct.class(~badI,:);
            
            
            % Remove non-target classes if applicable (only then targetClasses have
            % been set)
            if ~isempty(obj.targetClasses)
                goodIds = ~gStruct.gt;
                goodIds(ismember(gStruct.class, obj.targetClasses)) = 1;
                gStruct.gt = gStruct.gt(goodIds);
                gStruct.overlap = gStruct.overlap(goodIds,obj.targetClasses);
                gStruct.boxes = gStruct.boxes(goodIds,:);
                gStruct.class = gStruct.class(goodIds);
                
                % Map classes to consecutive 0:n
                for i=1:length(obj.targetClasses)
                    gStruct.class(gStruct.class == obj.targetClasses(i)) = i;
                end
            end
        end
        
        % Determine how many negatives negF to sample for each positive sample. This is
        % based on obj.posFraction.
        function negF = GetNegativeFactor(obj)
            negF = (1-obj.posFraction) / obj.posFraction;
        end
        
        % Get batch from keys
        % WARNING: Mostly deprecated function for fast-rcnn. But may be useful for
        % debug purposes.
        function [batch, labels, boxes] = BatchFromKeys(obj, currBatchKeys)
            % Extract images
            currBatchIms = unique(currBatchKeys(:,1));
            currBatchIms = reshape(currBatchIms, 1, []);
            
            % Preallocate memory
            currBatchSize = size(currBatchKeys,1);
            cropSize = size(obj.meanIm,1);
            if obj.gpuMode
                batch = zeros(cropSize, cropSize, size(obj.meanIm,3), currBatchSize, 'single', 'gpuArray');
            else
                batch = zeros(cropSize, cropSize, size(obj.meanIm,3), currBatchSize, 'single');
            end
            labVec = zeros(currBatchSize, 1, 'single');
            boxes = zeros(currBatchSize, 4, 'single');
            
            if obj.gpuMode
                batch = gpuArray(batch);
            end
            
            for i = 1:length(currBatchIms)
                % Load correct gStruct
                currIm = currBatchIms(i);
                gStruct = obj.LoadGStruct(currIm);
                
                % Get boxes, overlap, and keys
                currI = find(currBatchKeys(:,1) == currIm);
                currKeys = currBatchKeys(currI,:);
                currBoxes = gStruct.boxes(currKeys(:,2),:);
                currOverlap = gStruct.overlap(currKeys(:,2),:);
                
                % Get cropped and warped windows from the image
                currBatch = obj.GetImageWindows(currIm, currBoxes);
                
                % Get labels
                [maxOverlap, currLabVec] = max(currOverlap, [], 2);
                currLabVec(maxOverlap < 0.5) = 0;
                
                % Put everything at the correct place of the batch
                batch(:,:,:,currI) = currBatch;
                labVec(currI,:) = currLabVec;
                boxes(currI,:) = currBoxes;
            end
            
            labels = labVec + 1; % Negative class is one
        end
        
        % Get windows from an image
        % WARNING: Mostly deprecated function for fast-rcnn. But may be useful for
        % debug purposes.
        function imageWindows = GetImageWindows(obj, imId, boxes)
            % Load image. Add padding around image to deal with border issues
            im = imread([obj.imageDir obj.filenames{imId} obj.imExt]);
            nR = size(im, 1);
            nC = size(im, 2);
            avgMeanIm = mean(obj.meanIm(:));
            im = single(im);
            cropIm = padarray(im, [obj.padding obj.padding], avgMeanIm);
            %             cropIm2 = imresize(obj.meanIm, [(nR + 2*obj.padding) (nC + 2*obj.padding)]);
            cropIm(obj.padding+1:nR+obj.padding,obj.padding+1:nC+obj.padding,:) = im;
            
            % Get boxes in correct format. Do padding
            boxes = double(boxes(:,[2 1 4 3]));
            boxes = bsxfun(@plus, boxes, [0 0 (2*obj.padding) (2*obj.padding)]);
            
            cropSize = [size(obj.meanIm, 1) size(obj.meanIm,2)];
            
            %             if obj.gpuMode
            %                 imageWindows = cropRectanglesMex(cropIm, boxes, cropSize);
            %             else
            imageWindows = zeros([size(obj.meanIm) size(boxes,1)], 'single');
            for i = 1:size(boxes,1)
                croppedIm = cropIm(boxes(i,1):boxes(i,3), ...
                    boxes(i,2):boxes(i,4),:);
                imageWindows(:,:,:,i) = imresize(croppedIm, cropSize, ...
                    'bilinear', 'antialiasing', false);
            end
            %             end
            imageWindows = bsxfun(@minus, imageWindows, obj.meanIm); % subtract the mean image
            
            % FlipLR if requested
            if obj.flipLR
                imageWindows = fliplr(imageWindows);
            end
        end
        
        %
        %         % Transform label matrix to label vector. Note: background is 1
        %         % If there are multiple positive labels, only last one is used
        %         function labelVec = LabelMatToLabelVec(obj, labelMatrix)
        %             [maxLM, labelVec] = max(labelMatrix, [], 2);
        %             labelVec = labelVec + 1; % Make space for background class
        %             labelVec(maxLM < 0) = 1; % Assign background class
        %         end
        %
        %         % Transfor label vector to label matrix with values {-1, 0, 1}, where 0 is ignored
        %         % Possibly has extra indices to indicate unknown classes which are put to zero
        %         function labelMat = LabelVecToLabelMat(obj, labelVec, unknownClasses)
        %             labelMat = -ones(length(labelVec), obj.numClasses);
        %             labelVec = labelVec - 1; % Background class is put to zero
        %             for i=1:length(labelVec)
        %                 if labelVec(i) > 0
        %                     labelMat(i, labelVec(i)) = 1;
        %                 end
        %             end
        %
        %             % Remove unknown classes if applicable
        %             if nargin == 3
        %                 unknownClasses = unknownClasses -1; % Correct for background
        %                 for i=1:length(unknownClasses)
        %                     % Make only negatives unknown.
        %                     labelMat(:, unknownClasses(i)) = max(labelMat(:, unknownClasses(i)), 0);
        %                 end
        %             end
        %         end
        
        function initEpoch(obj, epoch)
            initEpoch@ImdbCalvin(obj, epoch);
            
            % Flip image vertically at the start of each epoch
            obj.switchFlipLR();
        end
        
        function switchFlipLR(obj)
            % Switch the flipLR switch
            obj.flipLR = mod(obj.flipLR + 1, 2);
        end
    end
end