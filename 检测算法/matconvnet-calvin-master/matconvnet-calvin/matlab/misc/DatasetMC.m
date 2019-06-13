classdef (Abstract) DatasetMC < handle
    %DATASET Abstract class that each dataset must inherit from.
    %
    %   For each new dataset, a new class must be created that inherits
    %   from Dataset. All properties must be implemented to ensure normal
    %   behavior throughout this codebase.
    %
    % Copyright by Holger Caesar, 2014
    
    % Public properties
    properties
        % General settings
        name
        path
        
        % Image settings
        imageCount = [];
        imageExt = '.jpg';
        imageFolder = 'Images';
        maxSize = 1024;
        fixSizeX = [];
        imageListFunc = @getImageListAll;
        
        % Label settings
        annotations    % All available annotations
        annotation     % The currently active annotation
        
        % Subset settings
        subset = 'train';
        imageSubset = '';
        imageSubsetGen = @(x) '';
    end
    
    % Private properties
    properties (Access = protected)
    end
    
    methods
        % Constructor
        function[obj] = DatasetMC()
            % Set default annotation
            obj.setDefaultAnnotation();
        end
        
        %%% Compatibility functions for older versions
        function[annotationFolder] = annotationFolder(obj)
            annotationFolder = obj.annotation.annotationFolder;
        end
        function[labelFolder] = labelFolder(obj)
            labelFolder = obj.annotation.labelFolder;
        end
        function[labelIdx] = labelIdx(obj)
            labelIdx = obj.annotation.labelIdx;
        end
        function[labelCount] = labelCount(obj)
            labelCount = obj.annotation.labelCount;
        end
        function[labelExt] = labelExt(obj)
            labelExt = obj.annotation.labelExt;
        end
        function[labelFormat] = labelFormat(obj)
            labelFormat = obj.annotation.labelFormat;
        end
        function[namesFile] = namesFile(obj)
            namesFile = obj.annotation.namesFile;
        end
        function[cmap] = cmap(obj)
            cmap = obj.annotation.cmap;
        end
        
        %%% Getters
        function[imagePath] = getImagePath(obj)
            % [imagePath] = getImagePath(obj)
            %
            % Get the path where the images lie.
            %
            % This function should be overwritten by Dataset
            % implementations if the imageFolder does not lie in the
            % dataset path.
            
            % Note: using fullfile here is too slow!
            imagePath = [obj.path, filesep, obj.imageFolder];
        end
        
        function[labelPath] = getLabelPath(obj)
            % [labelPath] = getLabelPath(obj)
            %
            % Get the path where the labels lie.
            %
            % This function should be overwritten by Dataset
            % implementations if the labelFolder does not lie in the
            % dataset path.
            % (formerly known as "getLabelsPath")
            
            % Note: using fullfile here is too slow!
            labelPath = [obj.path, filesep, obj.labelFolder];
        end
        
        function[labelImagePath] = getLabelImagePath(obj)
            % [labelImagePath] = getLabelImagePath(obj)
            %
            % Get the path where the image-level labels lie.
            
            labelImagePath = [obj.path, filesep, obj.annotation.labelImageFolder];
        end
        
        function[labelPath] = getAnnotationPath(obj)
            % [labelPath] = getAnnotationPath(obj)
            %
            % Get the root path of the annotation lie.
            %
            % This function should be overwritten by Dataset
            % implementations if the annotationFolder does not lie in the
            % dataset path.
            
            % Note: using fullfile here is too slow!
            labelPath = [obj.path, filesep, obj.annotationFolder];
        end
        
        function[metaPath] = getMetaPath(obj)
            % [metaPath] = getMetaPath(obj)
            %
            % Get the path where the meta files lie.
            %
            % This function should be overwritten by Dataset
            % implementations if the meta folder does not lie in the
            % dataset path.
            metaPath = fullfile(obj.getAnnotationPath(), obj.annotation.metaFolder);
        end
        
        function[namePath] = getNamePath(obj)
            % [namePath] = getNamePath(obj)
            %
            % Get the path of the name file.
            %
            % This function should be overwritten by Dataset
            % implementations if the meta folder does not lie in the
            % dataset path.
            % (formerly known as "getNamesPath")
            namePath = fullfile(obj.getMetaPath(), obj.namesFile);
        end
        
        function imageCount = getImageCount(obj)
            % imageCount = getImageCount(obj)
            %
            % Retrieve the number of images
            
            if isempty(obj.imageCount),
                % If not done yet, count the images
                [~, imageCount] = obj.getImageList();
                obj.imageCount = imageCount;
            else
                % Otherwise return the known result
                imageCount = obj.imageCount;
            end
        end
        
        function[annotation] = getAnnotation(obj, annotationName)
            % [annotation] = getAnnotation(obj, [annotationName])
            %
            % Returns the specified annotation struct of this dataset.
            % If no annotationName is set, the default is returned.
            
            % Return the selected annotation
            if ~exist('annotationName', 'var') || isempty(annotationName),
                % By active flag
                annotation = obj.annotations([obj.annotations.active]);
            else
                % By name
                annotation = obj.annotations(strcmp({obj.annotations.name}, annotationName));
            end
        end
        
        %%% Setters
        
        function setLabelIdx(obj, labelIdx)
            % setLabelIdx(obj, labelIdx)
            %
            % Set the label that is to be used and update the number of
            % images available for this label. labelIdx can be empty.
            
            % Set imageCount
            if isempty(labelIdx),
                obj.imageCount = obj.annotation.imageCount;
            else
                obj.imageCount = [];
            end
            
            % Set labelIdx
            obj.annotation.labelIdx = labelIdx;
        end
        
        function setDefaultAnnotation(obj)
            % setDefaultAnnotation(obj)
            %
            % Sets the default annotation for this dataset. This is useful
            % so that new datasets need not do manually, if  they choose to
            % stay with the default parameters.
            
            obj.annotations = AnnotationMC();
            obj.setActiveAnnotation('Original');
        end
        
        function setActiveAnnotation(obj, annotationName)
            % setActiveAnnotation(obj, annotationName)
            %
            % Find the annotation, set it to active and all others to
            % inactive.
            sel = strcmp({obj.annotations.name}, annotationName);
            if ~any(sel),
                error('Error: Unknown annotation: %s', annotationName);
            end
            obj.annotations(sel).active = true;
            obj.annotation = obj.annotations(sel);
            
            negInds = find(~sel);
            for i = 1 : numel(negInds),
                obj.annotations(negInds(i)).active = false;
            end
            
            % Set new imageListFunc
            obj.imageListFunc = obj.annotation.imageListFunc;
            
            % Set imageCount if all images are used (can be [])
            if isempty(obj.labelIdx),
                obj.imageCount = obj.annotation.imageCount;
            end
        end
        
        function setSubset(obj, subset)
            % setSubset(subset)
            %
            % Update the subset (train/val/test) that is used in this class.
            
            % Update subset names (there might be a nicer way, but it works)
            obj.subset = subset;
            obj.imageSubset = obj.imageSubsetGen(obj, subset);
            
            % The images should be counted again when necessary
            obj.imageCount = [];
        end
        
        %%% More complex functions
        function[stuffLabels, thingLabels, stuffLabelInds, thingLabelInds] = getStuffThingLabels(obj)
            % [stuffLabels, thingLabels, stuffLabelInds, thingLabelInds] = getStuffThingLabels(obj)
            %
            % Get names and indices of the stuff and thing labels.
            
            namesFilePath = fullfile(obj.getMetaPath(), obj.namesFile);
            namesStruct = load(namesFilePath, 'stuffLabels', 'thingLabels', 'stuffLabelInds', 'thingLabelInds');
            stuffLabels = namesStruct.stuffLabels;
            stuffLabelInds = namesStruct.stuffLabelInds;
            
            if isfield(namesStruct, 'thingLabels'),
                thingLabelInds = namesStruct.thingLabelInds;
                thingLabels = namesStruct.thingLabels;
            else
                thingLabelInds = setdiff((1:obj.labelCount)', stuffLabelInds);
                labelNames = obj.getLabelNames();
                thingLabels = labelNames(thingLabelInds);
            end
        end
        
        function[names, labelCount] = getLabelNames(obj)
            % [names, labelCount] = getLabelNames(obj)
            %
            % Get a cell of strings that specify the names of each label
            
            % Specify names file path
            namesFilePath = fullfile(obj.getMetaPath(), obj.namesFile);
            if ~exist(namesFilePath, 'file'),
                error('Error: Names file does not exist! Please execute ds_extractLabelNames() on the current annotation!');
            end
            
            % Retrieve names and labelCount
            namesStruct = load(namesFilePath, 'names');
            names = namesStruct.names;
            labelCount = numel(names);
            
            % Warning: If names are in the wrong order, we cannot find out
            % their indices
        end
        
        function[image] = getImage(obj, imageName, colorDim)
            % [image] = getImage(obj, imageName)
            %
            % Read an image from disk and correct its color dimensionality.
            %
            % Input:
            %   imageName:  file name without extension
            %   colorDim:   1 for grayscale or 3 for rgb
            % Output:
            %   image:      the image in double format.
            
            % Default arguments
            if ~exist('colorDim', 'var'),
                colorDim = 3;
            end
            
            % Create path
            imagePath = fullfile(obj.getImagePath(), [imageName, obj.imageExt]);
            
            % Read in image and convert to double
            image = im2double(imread(imagePath));
            
            % Resize image if it is too big
            % Attention: This might be dangerous, if boundingboxes still use the original image size.
            assert(~isempty(obj.maxSize) + ~isempty(obj.fixSizeX) <= 1);
            if ~isempty(obj.maxSize),
                imSize = [size(image, 1), size(image, 2)];
                maxImSize = max(imSize);
                if any(imSize > obj.maxSize),
                    newSize = round(imSize / maxImSize * obj.maxSize);
                    image = imresize(image, newSize);
                    
                    % After resize, make sure that the maximum value is 1
                    image(image > 1) = 1;
                    image(image < 0) = 0;
                end
            end
            
            if ~isempty(obj.fixSizeX),
                % Resize image s.t. the width is fixed throughout the whole
                % dataset.
                if size(image, 2) ~= obj.fixSizeX,
                    image = imresize(image, [nan, obj.fixSizeX]);
                    assert(size(image, 2) == obj.fixSizeX);
                    
                    % After resize, make sure that the maximum value is 1
                    image(image > 1) = 1;
                    image(image < 0) = 0;
                end
            end
            
            % Correct color if necessary
            if size(image, 3) ~= colorDim,
                if size(image, 3) == 3 && colorDim == 1,
                    image = rgb2gray(image);
                elseif size(image, 3) == 1 && colorDim == 3,
                    image = repmat(image, [1, 1, 3]);
                else
                    error('Error: Invalid color dim!');
                end
            end
        end
        
        function[imageListTrn, imageCountTrn] = getImageListTrn(obj, varargin)
            % [imageListTst, imageCountTst] = getImageListTrn(obj, varargin)
            %
            % Get a list of only the train images.
            
            imageList = obj.getImageList(varargin{:});
            trainList = obj.getTrainTestLists();
            imageListTrn = imageList(trainList);
            imageCountTrn = numel(imageListTrn);
        end
        
        function[imageListTst, imageCountTst] = getImageListTst(obj, varargin)
            % [imageListTst, imageCountTst] = getImageListTst(obj, varargin)
            %
            % Get a list of only the test images.
            
            imageList = obj.getImageList(varargin{:});
            [~, testList] = obj.getTrainTestLists();
            imageListTst = imageList(testList);
            imageCountTst = numel(imageListTst);
        end
        
        function[imageList, imageCount] = getImageList(obj, varargin)
            % [imageList, imageCount] = getImageList(obj, removeExt)
            %
            % Get list of images in dataset. This will call the specified
            % imageListFunc which can be updated to match special needs
            % (smaller dataset etc.)
            
            imageListFilePath = [obj.getMetaPath(), filesep, 'imageList.mat'];
            if exist(imageListFilePath, 'file'),
                imageListFileStruct = load(imageListFilePath, 'imageList');
                imageList = imageListFileStruct.imageList;
                imageCount = numel(imageList);
            else
                [imageList, imageCount] = obj.imageListFunc(obj, varargin{:});
                save(imageListFilePath, 'imageList', '-v6');
            end
        end
        
        function[imageList, imageCount] = getImageListSubset(obj, subset, varargin)
            % [imageList, imageCount] = getImageListSubset(obj, subset, varargin)
            %
            % Get the image names for a subset (or all).
            
            % Get images
            if strcmp(subset, 'train'),
                [imageList, imageCount] = obj.getImageListTrn(varargin{:});
            elseif strcmp(subset, 'test'),
                [imageList, imageCount] = obj.getImageListTst(varargin{:});
            elseif strcmp(subset, 'all'),
                [imageList, imageCount] = obj.getImageList(varargin{:});
            else
                error('Error: Unknown subset: %s', subset);
            end
        end
        
        function[imageList, imageCount] = getImageListAll(obj, removeExt)
            % [imageList, imageCount] = getImageListAll(obj, removeExt)
            %
            % Get list of all images in dataset.
            
            % Set default arguments
            if ~exist('removeExt', 'var')
                removeExt = true;
            end
            
            % Get a list of image names and rel. paths
            [imageList, imageCount] = dirSubfolders(obj.getImagePath(), obj.imageExt, removeExt);
            
            % Check that the images were really there
            if imageCount == 0,
                error('Error: Image input folder is empty!');
            end
            
            % Check if the number of images are as expected
            if ~isempty(obj.imageCount) && imageCount ~= obj.imageCount,
                error('Error: Dataset is not consistent! This error is non-deterministic, try again!');
            end
            
            % Save imageCount for other purposes
            obj.imageCount = imageCount;
        end
        
        function[labelFileList, labelFileCount] = getLabelList(obj, removeExt)
            % [labelFileList, labelFileCount] = getLabelList(obj, removeExt)
            %
            % Get a list of all image label files of the dataset.
            % Similar to getImageList, but with different subset and
            % extension.
            
            % Set default arguments
            if ~exist('removeExt', 'var')
                removeExt = true;
            end
            
            [labelFileList, labelFileCount] = obj.getImageList(true);
            
            % Append extension
            if ~removeExt,
                labelFileList = strcat(labelFileList, obj.labelExt);
            end
        end
        
        function[trainImages, testImages] = getTrainTestLists(obj)
            % [trainImages, testImages] = getTrainTestLists(obj)
            %
            % Get lists of train and test images of this dataset.
            splitFilePath = fullfile(obj.getMetaPath(), 'splits.mat');
            splitStruct = load(splitFilePath);
            splits = splitStruct.splits;
            trainImages = splits.train;
            testImages = splits.test;
            
            % Check consistency
            assert(numel(trainImages) + numel(testImages) == obj.imageCount);
            assert(numel(unique([trainImages; testImages])) == obj.imageCount)
        end
        
        function[labelListNames] = getImLabelList(obj, imageName)
            % [labelListNames] = getImLabelList(obj, imageName)
            %
            % Get a cell of label names that occur in the image ground truth.
            % labelListNames is unique (no duplicates)!
            
            % Since image labels can differ from pixel-derived image
            % labels, we want to check for image labels first.
            if obj.annotation.hasImageLabels,
                labelListNames = obj.getImLabelListDirectly(imageName);
            elseif obj.annotation.hasPixelLabels || obj.annotation.hasPixelLabelsOnlyTst
                if obj.annotation.hasPixelLabelsOnlyTst,
                    imageListTst = obj.getImageListTst();
                    
                    if ~ismember(imageName, imageListTst),
                        % For unlabeled train images we cannot use the
                        % labelMap
                        labelListNames = obj.getImLabelListDirectly(imageName);
                        return;
                    end
                end
                
                % Load entire labelMap
                labelMap = obj.getImLabelMap(imageName);
                labelNames = obj.getLabelNames();
                labelInds = unique(labelMap(:));
                labelInds(labelInds == 0) = [];
                labelListNames = labelNames(labelInds);
            else
                error('Error: Cannot find suitable labels!');
            end
        end
        
        function[labelListNames] = getImLabelListDirectly(obj, imageName)
            % [labelListNames] = getImLabelListDirectly(obj, imageName)
            %
            % Get a cell of label names that occur in the image ground truth.
            % Contrary to getImLabelList() these are not derived from the
            % pixel-level labels.
            % labelListNames is unique (no duplicates)!
            
            labelPath = [obj.getLabelImagePath(), filesep, imageName, obj.labelExt];
            labelImageFormat = obj.annotation.labelImageFormat;
            if strcmp(labelImageFormat, 'txt-labelList'),
                % Load ground truth
                fileContent = fileread(labelPath);
                
                % Split lines
                labelListNames = strsplit(fileContent, '\n');
                labelListNames = cellRemoveEmptyEntries(labelListNames);
            elseif strcmp(labelImageFormat, 'mat-labelList'),
                % Load ground truth
                labelStruct = load(labelPath, 'labelList');
                
                % Split lines
                labelListNames = labelStruct.labelList;
            elseif strcmp(labelImageFormat, 'xml') || strcmp(labelImageFormat, 'xml-ImageNet'),
                % Load ground truth
                fileContent = fileread(labelPath);
                
                % Extract xml fields
                labelListNames = xmlExtractField(fileContent, 'name');
            else
                error('Unknown label format!');
            end
            
            % Convert to col format
            labelListNames = labelListNames(:);
            
            % Make unique
            labelListNames = unique(labelListNames);
        end
        
        function[labelMap] = getImLabelMap(obj, imageName)
            % labelMap = getImLabelMap(obj, imageName)
            %
            % Load a per-pixel map that shows which pixel has which label.
            %
            % Note: the labelNames don't have the order of the labelMap.
            % Instead all non-occurring names are removed.
            
            % Check whether a label map is available for this annotation
            labelPixelPath = [obj.getLabelPath(), filesep, imageName, obj.labelExt];
            if exist(labelPixelPath, 'file'),
                if strcmp(obj.labelFormat, 'mat-labelMap'),
                    % Just return labelMap
                    labelMapStruct = load(labelPixelPath, 'S');
                    labelMap = labelMapStruct.S;
                    
                    % Check consistency of labelMap scale
                    assert(isempty(obj.maxSize) || all(size(labelMap) <= obj.maxSize));
                elseif strcmp(obj.labelFormat, 'xml') || strcmp(obj.labelFormat, 'xml-LabelMe'),
                    [labelMap, ~] = xmlToObjectMap(labelPixelPath);
                elseif strcmp(obj.labelFormat, 'xml-ImageNet'),
                    [labelMap, ~] = xmlToObjectMap(labelPixelPath, 'ImageNet');
                elseif strcmp(obj.labelFormat, 'im-labelMap'),
                    labelMap = imread(labelPixelPath);
                else
                    error('Error: Unknown label format!');
                end
            else
                error('Error: No labelMap available for image: %s', imageName);
            end
        end
        
        function[labelBoxes, labelList] = getImLabelBoxes(obj, imageName, filterCurLabel)
            % [labelBoxes, labelList] = getImLabelBoxes(obj, imageName, filterCurLabel)
            %
            % Load a list of boxes and names for each object in the image.
            
            if ~exist('filterCurLabel', 'var'),
                filterCurLabel = false;
            end
            
            if strcmp(obj.labelFormat, 'xml-ImageNet'),
                % Get bounding box
                labelPath = fullfile(obj.getLabelPath(), [imageName, obj.labelExt]);
                [labelBoxes, labelNames, imSize] = imageNetXmlLabelsToBBox(labelPath);
                
                % Scale bounding boxes to fit resized image
                if ~isempty(obj.maxSize),
                    maxImSize = max(imSize);
                    if any(imSize > obj.maxSize),
                        % Round up to avoid zeros
                        labelBoxes = ceil(labelBoxes ./ maxImSize .* obj.maxSize);
                    end
                end
                
                % Get label indices for image and all boxes
                hashPath = fullfile(obj.getMetaPath(), 'objectLabelNameToLabelInd_hash.mat');
                hashStruct = load(hashPath);
                boxInds = cellfun(@(x) hashStruct.hash.get(x), labelNames);
                
                % If requested, use only the boxes that have the correct label
                if filterCurLabel,
                    % Remove all boxes that do not have the current label (or children of that)
                    error('TODO: update this to allow multiple labelInds!');
                    imageLabelInd = obj.labelIdx; %#ok<UNRCH>
                    boxMatches = boxInds == imageLabelInd;
                    labelBoxes = labelBoxes(boxMatches, :);
                    labelList = boxInds(boxMatches);
                else
                    labelList = boxInds;
                end
            else
                error('Error: Label format not supported yet!');
            end
        end
        
        function[mask] = getImLabelBoxesMask(obj, imageName)
            % Returns a boolean mask where all pixels inside any bounding box
            % are set to true and all others to false.
            
            % Get boxes
            labelBoxes = obj.getImLabelBoxes(imageName); % box format is [y1, y2, x1, x2]
            
            % Get image size
            imageSize = obj.getImageSize(imageName);
            
            % Overwrite mask for each box
            mask = false(imageSize);
            for boxIdx = 1 : size(labelBoxes, 1)
                box = labelBoxes(boxIdx, :);
                mask(box(1):box(2), box(3):box(4)) = true;
            end
        end
        
        function imageBrowser(obj, startIdx)
            % imageBrowser(obj, startIdx)
            %
            % Start an interactive image browser.
            % You can jump to the next image by pressing a,d.
            % The labels are enlisted upon pressing s
            
            % Store image index in global variable
            global ds_imageBrowser_idx;
            if exist('startIdx', 'var'),
                ds_imageBrowser_idx = startIdx;
            elseif exist('ds_imageBrowser_idx', 'var') && ~isempty(ds_imageBrowser_idx),
                % Keep current idx
            else
                ds_imageBrowser_idx = 1;
            end
            
            % Preload image list to avoid overhead on each update
            imageList = obj.getImageList(true);
            
            function updateImageBrowserIndex(dataset, command)
                fprintf('Pressed key is: %s\n', command);
                if command == 'a',
                    ds_imageBrowser_idx = ds_imageBrowser_idx - 1;
                    if ds_imageBrowser_idx < 1,
                        ds_imageBrowser_idx = dataset.imageCount;
                    end
                    dataset.showWithAnnotation('imageIdx', ds_imageBrowser_idx, 'imageList', imageList, 'displayPlot', true);
                elseif command == 'd',
                    ds_imageBrowser_idx = ds_imageBrowser_idx + 1;
                    if ds_imageBrowser_idx > dataset.imageCount,
                        ds_imageBrowser_idx = 1;
                    end
                    dataset.showWithAnnotation('imageIdx', ds_imageBrowser_idx, 'imageList', imageList, 'displayPlot', true);
                elseif command == 's',
                    labelNames = dataset.showWithAnnotation('imageIdx', ds_imageBrowser_idx, 'imageList', imageList, 'displayPlot', true);
                    for labelInd = 1 : numel(labelNames),
                        fprintf('%d: %s\n', labelIdx, labelNames{labelInd});
                    end
                else
                    % Do nothing
                end
            end
            
            % Open figure and install key listener
            f = figure();
            set(f, 'KeyPressFcn', @(x, y) updateImageBrowserIndex(obj, get(f, 'CurrentCharacter')));
            
            % Show an image
            obj.showWithAnnotation('imageIdx', ds_imageBrowser_idx, 'displayPlot', true);
        end
        
        function[labelNames, image, tiling] = showWithAnnotation(obj, varargin)
            % [labelNames, image, tiling] = showWithAnnotation(obj, varargin)
            %
            % Shows an image either with its active annotation or with the
            % labelNames specified. The image and labelNames are returned
            % for further use.
            %
            % Note: Only imageIdx XOR imageName can be specified!
            
            % Parse input
            p = inputParser;
            addParameter(p, 'imageIdx', []);
            addParameter(p, 'imageName', []);
            addParameter(p, 'imageList', []);
            addParameter(p, 'labelNames', {});
            addParameter(p, 'labelNamesImage', {});
            addParameter(p, 'labelMap', []);
            addParameter(p, 'showImage', true);
            addParameter(p, 'showLabelMapGT', true);
            addParameter(p, 'showLabelMap', true);
            addParameter(p, 'insertBlobLabelsGT', true);
            addParameter(p, 'insertBlobLabels', true);
            addParameter(p, 'displayPlot', true);
            addParameter(p, 'cmap', @jet);
            parse(p, varargin{:});
            
            imageIdx = p.Results.imageIdx;
            imageName = p.Results.imageName;
            imageList = p.Results.imageList;
            labelNames = p.Results.labelNames;
            labelNamesImage = p.Results.labelNamesImage;
            labelMap = p.Results.labelMap;
            showImage = p.Results.showImage;
            showLabelMapGT = p.Results.showLabelMapGT;
            showLabelMap = p.Results.showLabelMap;
            insertBlobLabelsGT = p.Results.insertBlobLabelsGT;
            insertBlobLabels = p.Results.insertBlobLabels;
            displayPlot = p.Results.displayPlot;
            cmap = p.Results.cmap;
            
            % Check arguments
            if ~xor(isempty(imageIdx), isempty(imageName)),
                error('Error: Only imageIdx XOR imageName can be specified!');
            end
            
            % If necessary, lookup which image name this index corresponds to
            if ~isempty(imageIdx),
                % Load imageList
                if isempty(imageList),
                    [imageList, ~] = obj.getImageList(true);
                end
                
                % Select image
                if imageIdx >= 1 && imageIdx <= obj.getImageCount(),
                    imageName = imageList{imageIdx};
                else
                    error('Error: Invalid image index!');
                end
            end
            
            % Prepare image
            imagePath = fullfile(obj.getImagePath(), [imageName, obj.imageExt]);
            image = imread(imagePath);
            
            % Prepare labelImageGT
            if showLabelMapGT,
                if obj.hasLabelMap(imageName),
                    % Get labelMapGT
                    try
                        labelMapGT = obj.getImLabelMap(imageName);
                        labelNames = obj.getLabelNames();
                    catch e,
                        fprintf('Warning: Cannot load label file! Maybe it doesn''t exist?\n%s\n', e.message);
                        labelMapGT = [];
                        labelNames = [];
                    end
                else
                    error('Error: Cannot show labelMapGT as it does not exist!');
                end
                
                % Convert labelMapGT to a color image
                if isempty(labelMapGT),
                    showLabelMapGT = false;
                else
                    labelImageGT = labelMapToColorImage(labelMapGT, obj.labelCount, cmap);
                    
                    % Add labelNames
                    if insertBlobLabelsGT && ~isempty(labelNames),
                        labelImageGT = imageInsertBlobLabels(labelImageGT, labelMapGT, labelNames);
                    end
                end
            end
            
            % Prepare labelImage
            if showLabelMap && ~isempty(labelMap),
                % Convert labelMap to a color image
                labelImage = labelMapToColorImage(labelMap, obj.labelCount, cmap);
                
                % Add labelNames
                if insertBlobLabels && ~isempty(labelNames),
                    % Fully supervised
                    labelImage = imageInsertBlobLabels(labelImage, labelMap, labelNames);
                end
            end
            
            % Insert image-level labels
            if ~isempty(labelNamesImage),
                image = imageInsertText(image, labelNamesImage);
            end
            
            % Concatenate image and labelMap side by side
            tiling = ImageTile();
            if showImage,
                tiling.addImage(image);
            end
            if showLabelMapGT,
                tiling.addImage(labelImageGT);
            end
            if ~isempty(labelMap),
                tiling.addImage(labelImage);
            end
            image = tiling.getTiling('totalX', tiling.getTotalX());
            
            % Show image
            if displayPlot && ~isempty(image),
                fprintf('Showing image: %s\n', imageName);
                imshow(image);
                set(gcf, 'Name', imageName, 'NumberTitle', 'off')
            end
        end
        
        function[result] = hasLabelMap(obj, imageName)
            % [result] = hasLabelMap(obj, imageName)
            %
            % Indicates whether the annotation's labelFormat holds a
            % labelMap. Then getImLabelMap(..) can be called.
            
            assert(~isempty(imageName));
            if obj.annotation.hasPixelLabels,
                result = true;
            elseif obj.annotation.hasPixelLabelsOnlyTst,
                imageListTst = obj.getImageListTst();
                result = ismember(imageName, imageListTst);
            else
                result = false;
            end
        end
        
        function[labelOrder, labelNames] = getLabelOrder(obj)
            if obj.annotation.hasStuffThingLabels,
                % Put stuff labels first, then things
                [~, ~, stuffLabelInds, thingLabelInds] = obj.getStuffThingLabels();
                labelOrder = [stuffLabelInds; thingLabelInds];
            else
                % Enumerate in default order
                labelOrder = (1:obj.labelCount)';
            end
            
            if nargout > 1,
                labelNames = obj.getLabelNames();
                labelNames = labelNames(labelOrder);
            end
        end
        
        function[imageSizes] = getImageSizes(obj)
            % [imageSizes] = getImageSizes(obj)
            %
            % Get the sizes of all images.
            % The order is the same as in getImageList().
            % Note that obj.maxSize and obj.fixSizeX affect the sizes.
            
            % Load imageSizes from file, if it exists
            imageSizesPath = fullfile(obj.getMetaPath(), 'imageSizes.mat');
            if exist(imageSizesPath, 'file'),
                imageSizesStruct = load(imageSizesPath, 'imageSizes');
                imageSizes = imageSizesStruct.imageSizes;
            else
                % Get image list
                [imageList, imageCount] = obj.getImageList(); %#ok<PROP>
                
                % Initialize
                imageSizes = nan(imageCount, 2); %#ok<PROP>
                
                % Load each image and determine its size
                for imageIdx = 1 : imageCount, %#ok<PROP>
                    printProgress('Extracting imageSizes for the first time', imageIdx, imageCount, 50); %#ok<PROP>
                    
                    imageName = imageList{imageIdx};
                    image = obj.getImage(imageName);
                    imageSizes(imageIdx, :) = [size(image, 1), size(image, 2)];
                end
                
                % Save to disk for next time
                save(imageSizesPath, 'imageSizes', '-v6');
            end
        end
        
        function[imageSize] = getImageSize(obj, imageName)
            % [imageSize] = getImageSize(obj, imageName)
            %
            % Pretty slow. Datasets with fixed image sizes can just
            % overwrite this and return constants.
            
            image = obj.getImage(imageName);
            imageSize = [size(image, 1), size(image, 2)];
        end
        
        function showImageBlob(obj, imageName, blob)
            % showImageBlob(obj, imageName, blob)
            %
            % She the image with the blob emphasized in red color.
            
            % Get image indices
            image = obj.getImage(imageName);
            [blobSubY, blobSubX] = blobToImageSubs(blob);
            blobInds = sub2indFast(size(image), blobSubY, blobSubX, ones(size(blobSubY)));
            
            % Set blob pixels to red
            image(blobInds) = min(image(blobInds) + 0.5, 1);
            
            % Show image
            imshow(image);
        end
        
        function[image] = getRandImage(obj)
            % [image] = getRandImage(obj)
            %
            % Returns an arbitrary image (can be train or test).
            
            imageList = obj.getImageList();
            imageName = imageList{randi(numel(imageList))};
            image = obj.getImage(imageName);
        end
        
        function[imageName] = getRandImageName(obj)
            % [imageName] = getRandImage(obj)
            %
            % Returns the name of an arbitrary image (can be train or test).
            
            imageList = obj.getImageList();
            imageName = imageList{randi(numel(imageList))};
        end
        
        function[freqs, imageCount] = getLabelPixelFreqs(obj, subset)
            % [freqs, imageCount] = getLabelPixelFreqs(obj, [subset])
            %
            % Returns the pixel-level frequencies of each label.
            % This is computed on the train set.
            % It ignores invalid pixels (id == 0).
            
            % Default arguments
            if ~exist('subset', 'var'),
                subset = 'train';
            end
            
            imPixelFreqPath = fullfile(obj.getMetaPath(), 'labelPixelFreqs.mat');
            if exist(imPixelFreqPath, 'file') && strcmp(subset, 'train'),
                % Load from disk
                imPixelFreqStruct = load(imPixelFreqPath, 'freqs', 'imageCount');
                freqs = imPixelFreqStruct.freqs;
                imageCount = imPixelFreqStruct.imageCount;
            else
                % Get images
                [imageList, imageCount] = obj.getImageListSubset(subset);
                
                % Init
                labelCount = obj.labelCount;
                freqs = zeros(labelCount, 1);
                
                for imageIdx = 1 : imageCount,
                    printProgress('Loading pixel-level frequencies for image', imageIdx, imageCount);
                    
                    % Get label map
                    imageName = imageList{imageIdx};
                    labelMap = obj.getImLabelMap(imageName);
                    
                    % Sum frequencies (label 0 is excluded)
                    freqs = freqs + histc(labelMap(:), 1:labelCount);
                end
                
                % Save to disk
                if strcmp(subset, 'train'),
                    save(imPixelFreqPath, 'freqs', 'imageCount', '-v6');
                end
            end
        end
        
        function[freqs, imageCount] = getLabelImFreqs(obj, subset)
            % [freqs, imageCount] = getLabelImFreqs(obj, [subset])
            %
            % Returns the image-level frequencies of each label.
            % By default this is computed on the train set to avoid taking
            % a look at test when computing inverse class frequencies to
            % weight the loss of a classifier.
            % It ignores invalid pixels (id == 0).
            
            % Default arguments
            if ~exist('subset', 'var'),
                subset = 'train';
            end
            
            imLabelFreqPath = fullfile(obj.getMetaPath(), 'labelImFreqs.mat');
            if exist(imLabelFreqPath, 'file') && strcmp(subset, 'train'),
                % Load from disk
                imLabelFreqStruct = load(imLabelFreqPath, 'freqs', 'imageCount');
                freqs = imLabelFreqStruct.freqs;
                imageCount = imLabelFreqStruct.imageCount;
            else
                % Get images
                [imageList, imageCount] = obj.getImageListSubset(subset);
                
                % Init
                [labelNames, labelCount] = obj.getLabelNames();
                freqs = zeros(labelCount, 1);
                
                for imageIdx = 1 : imageCount,
                    printProgress('Loading pixel-level frequencies for image', imageIdx, imageCount);
                    
                    % Get label inds (don't call getImLabelMap to allow
                    % weakly supervised learning)
                    imageName = imageList{imageIdx};
                    labelList = obj.getImLabelList(imageName);
                    labelInds = find(ismember(labelNames, labelList));
                    
                    % Sum frequencies (label 0 is excluded) (special care taken
                    % for empty histos)
                    histo = histc(labelInds, 1:labelCount);
                    histo = histo(:);
                    freqs = freqs + histo;
                end
                
                % Save to disk
                if strcmp(subset, 'train'),
                    save(imLabelFreqPath, 'freqs', 'imageCount', '-v6');
                end
            end
        end
        
        function[imLabelLists] = getImLabelLists(obj)
            % [imLabelLists] = getImLabelLists(obj)
            %
            % Extract the labelLists of each image and cache them all in one file.
            % Each labelList does not contain duplicates.
            
            imLabelListsPath = fullfile(obj.getMetaPath(), 'imLabelLists.mat');
            if exist(imLabelListsPath, 'file'),
                imLabelListsStruct = load(imLabelListsPath, 'imLabelLists');
                imLabelLists = imLabelListsStruct.imLabelLists;
                assert(numel(imLabelLists) == obj.imageCount);
            else
                % Get images
                [imageList, imageCountLoc] = obj.getImageList();
                
                % Init
                imLabelLists = cell(imageCountLoc, 1);
                
                % Load each image's labels
                for imageIdx = 1 : imageCountLoc,
                    printProgress('Loading image label lists for image', imageIdx, imageCountLoc);
                    
                    imageName = imageList{imageIdx};
                    labelList = obj.getImLabelList(imageName);
                    imLabelLists{imageIdx} = labelList(:);
                end
                
                % Save to disk
                save(imLabelListsPath, 'imLabelLists', '-v6');
            end
        end
        
        function[regionBlobSizes] = getRegionBlobSizes(obj, segmentFolder, subset)
            % [regionBlobSizes] = getRegionBlobSizes(obj, segmentFolder, [subset])
            
            if ~exist('subset', 'var'),
                subset = 'all';
            end
            
            % Get images
            [imageList, curImageCount] = obj.getImageListSubset(subset);
            
            % Init
            regionBlobSizes = cell(curImageCount, 1);
            
            for imageIdx = 1 : curImageCount,
                imageName = imageList{imageIdx};
                blobsPath = fullfile(segmentFolder, [imageName, '.mat']);
                blobsStruct = load(blobsPath, 'propBlobs');
                regionBlobSizes{imageIdx} = [blobsStruct.propBlobs.size]';
            end
        end
        
        function[labelList] = getImLabelInds(obj, imageName)
            % [labelList] = getImLabelInds(obj, imageName)
            
            % Get label names
            [labelListNames] = obj.getImLabelList(imageName);
            labelNames = obj.getLabelNames();
            
            labelList = find(ismember(labelNames, labelListNames));
        end
        
        function[rgbMean] = getMeanColor(obj)
            % [rgbMean] = getMeanColor(obj)
            %
            % Compute the mean color of all pixels in all images in the
            % train set. Each image has the same weight, regardless of the
            % number of pixels in it.
            
            rgbMeanPath = fullfile(obj.getMetaPath(), 'rgbMean.mat');
            if exist(rgbMeanPath, 'file'),
                rgbMeanStruct = load(rgbMeanPath, 'rgbMean');
                rgbMean = rgbMeanStruct.rgbMean;
            else
                % Get image list
                [imageListTrn, imageCountTrn] = obj.getImageListTrn();
                
                % Init
                rgbSum = zeros(3, 1);
                
                for imageIdx = 1 : imageCountTrn,
                    printProgress('Computing mean color for image', imageIdx, imageCountTrn, 50);
                    
                    imageName = imageListTrn{imageIdx};
                    image = obj.getImage(imageName);
                    
                    for c = 1 : 3,
                        rgbSum(c) = rgbSum(c) + mean2(image(:, :, c));
                    end
                end
                
                rgbMean = rgbSum ./ imageCountTrn;
                
                % Store result
                save(rgbMeanPath, 'rgbMean');
            end
        end
        
        
        function[missingLabels] = getMissingImageIndices(obj, subset)
            % [missingLabels] = getMissingImageIndices(obj, subset)
            
            assert(~isempty(subset));
            missingLabelsPath = fullfile(obj.getMetaPath(), sprintf('missingLabels-%s.mat', subset));
            if exist(missingLabelsPath, 'file'),
                % Load from disk
                missingLabelsStruct = load(missingLabelsPath, 'missingLabels');
                missingLabels = missingLabelsStruct.missingLabels;
            else
                % Get images
                [imageList, imageCountCur] = obj.getImageListSubset(subset);
                
                missingLabels = false(imageCountCur, 1);
                for imageIdx = 1 : imageCountCur,
                    printProgress('Checking whether image has labels', imageIdx, imageCountCur, 50);
                    
                    imageName = imageList{imageIdx};
                    labels = obj.getImLabelList(imageName);
                    if isempty(labels),
                        missingLabels(imageIdx) = true;
                    end
                end
                missingLabels = find(missingLabels);
                
                % Write to disk
                save(missingLabelsPath, 'missingLabels');
            end
        end
    end
end