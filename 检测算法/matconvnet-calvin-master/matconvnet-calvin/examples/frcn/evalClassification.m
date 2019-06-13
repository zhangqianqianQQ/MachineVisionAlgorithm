function evalClassification(imdb, stats, nnOpts)
% evalClassification(imdb, stats, nnOpts)

% Get scores and labels
scores = zeros(size(imdb.misc.testLabs));
for i = 1 : length(stats.results)
    scores(i, :) = stats.results(i).scores;
end
testLabsAp = imdb.misc.testLabs;
testLabsAp(testLabsAp == 0) = -1;

% Compute AP
ap = zeros(size(testLabsAp, 2), 1);
for cI = 1:size(testLabsAp, 2)    
    gt = testLabsAp(:, cI);
    out = scores(:, cI);
    
    [~, si] = sort(-out);
    tp = gt(si) > 0;
    fp = gt(si) < 0;
    
    fp = cumsum(fp);
    tp = cumsum(tp);
    rec = tp / sum(gt > 0);
    prec = tp ./ (fp + tp);
    
    ap(cI) = VOCap(rec, prec);
end
map = mean(ap);

% Equivalent to the following (without writing to disk)
% for classIdx = 1 : 20
%     className = DATAopts.classes{classIdx};
%     [~, ~, ap(classIdx)] = VOCevalcls(DATAopts, 'FastRcnnMatconvnet', className, false);
% end

ap
map

% Save results to disk
epoch = nnOpts.numEpochs; %#ok<NASGU>
save([nnOpts.expDir, '/', 'resultsEpochFinalTest.mat'], 'nnOpts', 'stats', 'ap', 'map', 'epoch');