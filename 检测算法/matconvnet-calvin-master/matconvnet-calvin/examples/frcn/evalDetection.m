function evalDetection(testName, imdb, stats, nnOpts)

global DATAopts;

% Get test images
testIms = imdb.misc.testIms;

% get image sizes
testCount = length(testIms);
for i = testCount : -1 : 1
    im = imread(sprintf(DATAopts.imgpath, testIms{i}));
    imSizes(i, :) = size(im);
end

for cI = 1 : 20
    %
    currBoxes = cell(testCount, 1);
    currScores = cell(testCount, 1);
    for i = 1 : testCount
        currBoxes{i} = stats.results(i).boxes{cI + 1};
        currScores{i} = stats.results(i).scores{cI + 1};
    end
    
    [currBoxes, fileIdx] = Cell2Matrix(gather(currBoxes));
    [currScores, fileIdx2] = Cell2Matrix(gather(currScores));
    
    assert(isequal(fileIdx, fileIdx2)); % Should be equal
    
    currFilenames = testIms(fileIdx);
    
    [~, sI] = sort(currScores, 'descend');
    currScores = currScores(sI);
    currBoxes = currBoxes(sI,:);
    currFilenames = currFilenames(sI);
    
    %     ShowImageRects(currBoxes(1:32, [2 1 4 3]), 4, 4, currFilenames(1:32), currScores(1:32));
    
    %
    [recall{cI}, prec{cI}, ap(cI,1), upperBound{cI}] = ...
        DetectionToPascalVOCFiles(testName, cI, currBoxes, currFilenames, currScores, ...
        'Matconvnet-Calvin', 1, nnOpts.misc.overlapNms);
    ap(cI)
end

ap
mean(ap)

if isfield(stats.results(1), 'boxesRegressed')
    for cI = 1 : 20
        %
        currBoxes = cell(testCount, 1);
        currScores = cell(testCount, 1);
        
        for i=1:testCount
            % Get regressed boxes and refit them to the image
            currBoxes{i} = stats.results(i).boxesRegressed{cI+1};
            currBoxes{i}(:,1) = max(currBoxes{i}(:, 1), 1);
            currBoxes{i}(:,2) = max(currBoxes{i}(:, 2), 1);
            currBoxes{i}(:,3) = min(currBoxes{i}(:, 3), imSizes(i,2));
            currBoxes{i}(:,4) = min(currBoxes{i}(:, 4), imSizes(i,1));
            
            currScores{i} = stats.results(i).scoresRegressed{cI+1};
        end
        
        [currBoxes, fileIdx] = Cell2Matrix(gather(currBoxes));
        [currScores, fileIdx2] = Cell2Matrix(gather(currScores));
        
        assert(isequal(fileIdx, fileIdx2)); % Should be equal
        
        currFilenames = testIms(fileIdx);
        
        [~, sI] = sort(currScores, 'descend');
        currScores = currScores(sI);
        currBoxes = currBoxes(sI, :);
        currFilenames = currFilenames(sI);
        
        %     ShowImageRects(currBoxes(1:32, [2 1 4 3]), 4, 4, currFilenames(1:32), currScores(1:32));
        
        %
        [recall{cI}, prec{cI}, apRegressed(cI,1), upperBound{cI}] = ...
            DetectionToPascalVOCFiles(testName, cI, currBoxes, currFilenames, currScores, ...
            'Matconvnet-Calvin', 1, nnOpts.misc.overlapNms);
        apRegressed(cI)
    end
    
    apRegressed
    mean(apRegressed)
else
    apRegressed = 0;
end

% Save results to disk
save([nnOpts.expDir, '/', 'resultsEpochFinalTest.mat'], 'nnOpts', 'stats', 'ap', 'apRegressed');