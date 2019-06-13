function[imdb] = setupImdbClassification(trainName, testName, net)
% [imdb] = setupImdbClassification(trainName, testName, net)

global DATAopts;

% Setup the Imdb
% Get images and labels
set = trainName;
[trainIms, ~] = textread(sprintf(DATAopts.imgsetpath,set),'%s %d'); %#ok<DTXTRD>
trainLabs = zeros(length(trainIms), DATAopts.nclasses);

% Get all testlabels
if ~strcmp(set,'test') || DATAopts.year == 2007
    for classIdx = 1 : DATAopts.nclasses
        class = DATAopts.classes{classIdx};
        [~, trainLabs(:,classIdx)] = textread(sprintf(DATAopts.clsimgsetpath, class, set), '%s %d'); %#ok<DTXTRD>
    end
    
    trainLabs(trainLabs == 0) = -1;
end

set = testName;
[testIms, ~] = textread(sprintf(DATAopts.imgsetpath,set),'%s %d'); %#ok<DTXTRD>
testLabs = zeros(length(testIms), DATAopts.nclasses);

% Get all testlabels
if ~strcmp(set,'test') || DATAopts.year == 2007
    for classIdx = 1 : DATAopts.nclasses
        class = DATAopts.classes{classIdx};
        [~, testLabs(:, classIdx)] = textread(sprintf(DATAopts.clsimgsetpath, class, set), '%s %d'); %#ok<DTXTRD>
    end
    
    testLabs(testLabs == -1) = 0;
end

% Make train, val, and test set.
numValIms = 500;
allIms = cat(1, trainIms, testIms);
allLabs = cat(1, trainLabs, testLabs);
datasetIdx{1} = (1 : length(trainIms) - numValIms)';  % Last numValIms are val set
datasetIdx{2} = (length(trainIms) - numValIms + 1 : length(trainIms))';
datasetIdx{3} = (length(trainIms) + 1 : length(allIms))';

% Setup the classification imdb
imdb = ImdbClassification(DATAopts.imgpath(1:end-6), ...        % path
    DATAopts.imgpath(end-3:end), ...      % image extension
    allIms, ...                           % all images
    allLabs, ...                          % all labels
    datasetIdx, ...                       % division into train/val/test
    net.meta.normalization.averageImage, ...   % average image used to pretrain network
    20);                                  % num classes

% Store lists for use in eval
imdb.misc.trainName = trainName;
imdb.misc.testName  = testName;
imdb.misc.trainIms  = trainIms;
imdb.misc.trainLabs = trainLabs;
imdb.misc.testIms   = testIms;
imdb.misc.testLabs  = testLabs;