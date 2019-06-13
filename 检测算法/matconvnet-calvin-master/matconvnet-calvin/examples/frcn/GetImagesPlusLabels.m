function [images, labels, boxes, labelCounts] = GetImagesPlusLabels(set)
% [images, labels] = GetImagesPlusLabels(set)
%
% Get image names and labels for the target set
%
% set:      Element of {'train', 'val', 'test'}
% 
% images:   Image names (without path, without .jpg)
% labels:   M x N logical array denoting labels for all N classes

global DATAopts;

sal = length('StanfordAction');
if length(set) > sal && strcmp(set(1:sal), 'StanfordAction')
    set = set(sal+1:end);
    
    for cI=1:length(DATAopts.classes)
        images{cI} = textread([DATAopts.datadir 'ImageSplits/' DATAopts.classes{cI} '_' set '.txt'], '%s');
        labels{cI} = false(length(images{cI}), length(DATAopts.classes));
        labels{cI}(:,cI) = true;
    end
    
    images = cat(1, images{:});
    labels = cat(1, labels{:});
    
    % Remove .jpg from images
    for i=1:length(images)
        images{i} = images{i}(1:end-4);
    end
    return
end

if length(set) > 6 && strcmp(set(1:6), 'Action')
    set = set(7:end);
    for cI = 1:length(DATAopts.actions)
        cls = DATAopts.actions{cI};
        [imsA{cI} objIndsA{cI} labsA{cI}] = textread(sprintf(DATAopts.action.clsimgsetpath, cls, set), '%s %d %d');
    end
    
    % Somehow the first action is incorrect and has too few images. Fix this
    images = imsA{2};
    [tf loc] = ismember(imsA{1}, images);
    
    % Also fix labels
    labs1 = zeros(size(labsA{2}));
    labs1(loc) = labsA{1};
    labsA{1} = labs1;
    labels = cat(2, labsA{:}) == 1;
    
%     % Somehow there are also duplicate images?!?!?!
%     [imagesT idx] = unique(images);
%     images = images(idx);
%     labels = labels(idx,:);
else

% This block is to get the segmentation images plus labels
if strcmp(set(end-2:end), 'Seg')
    set = set(1:end-3);
    images = textread(sprintf(DATAopts.seg.imgsetpath, set), '%s');
    
    labels = zeros(length(images), DATAopts.nclasses);
    
    % Get the labels
    if (~strcmp(set,'test') || DATAopts.year == 2007)
        for i=1:length(images)
            rec = PASreadrecord(sprintf(DATAopts.annopath, images{i}));
            for j=1:length(rec.objects)
                [tf classNr] = ismember(rec.objects(j).class, DATAopts.classes);
                labels(i,classNr) = 1;
            end
        end
    end
    
else % This block is to get all the images plus labels

    % Make label array
    sprintf(DATAopts.imgsetpath,set)
    [images, lbs] = textread(sprintf(DATAopts.imgsetpath,set),'%s %d');
    labels = zeros(length(images), DATAopts.nclasses);

    % Get all testlabels
    if (~strcmp(set,'test') || DATAopts.year == 2007)
        for classIdx = 1:DATAopts.nclasses
            class = DATAopts.classes{classIdx};
            [images, labels(:,classIdx)] = textread(sprintf(DATAopts.clsimgsetpath,class,set),'%s %d');
        end

        labels(labels == -1) = 0;
    end
end
end

labels = logical(labels);

if nargout > 2
    labelCounts = zeros(size(labels));
    labelCountsEasy = zeros(size(labels)); % Non-difficult labels
    if  (~strcmp(set,'test') || DATAopts.year == 2007)
        boxes = cell(length(images), DATAopts.nclasses);        
        for i=1:length(images)
            rec = PASreadrecord(sprintf(DATAopts.annopath, images{i}));
            for j=1:length(rec.objects)
                [~, classNr] = ismember(rec.objects(j).class, DATAopts.classes);
                labelCounts(i,classNr) = labelCounts(i,classNr) + 1;
                if rec.objects(j).difficult == 0
                    labelCountsEasy(i,classNr) = labelCountsEasy(i,classNr) + 1;
                end
                    
            end
            % Allocate memory for boxes
            for cI=1:DATAopts.nclasses
                if labelCountsEasy(i,cI) > 0
                    boxes{i,cI} = zeros(labelCountsEasy(i,cI), 4);
                end
            end
            % Fill actual boxes
            ccI = ones(1,20);
            for j=1:length(rec.objects)
                if rec.objects(j).difficult == 0
                    [~, classNr] = ismember(rec.objects(j).class, DATAopts.classes);
                    theBox = rec.objects(j).bbox;
                    theBox = theBox([2 1 4 3]); % Reverse for row-col coordinates
                    boxes{i,classNr}(ccI(classNr),:) = theBox;
                    ccI(classNr) = ccI(classNr) + 1;
                end
            end
        end
    else
        boxes = [];
        labelCounts = labels;
    end
end