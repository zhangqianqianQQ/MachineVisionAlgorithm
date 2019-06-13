function result = testClassification(~, ~, net, ~, batchInds)
% result = testClassification(~, ~, net, ~, batchInds)
%
% Get classification scores.
%
% Copyright by Jasper Uijlings, 2015

vI = net.getVarIndex('scores');
scoresStruct = net.vars(vI);
scores = permute(scoresStruct.value, [4 3 2 1]);

for i = numel(batchInds) : -1 : 1
    result(i).scores = gather(scores(i, :));
end
