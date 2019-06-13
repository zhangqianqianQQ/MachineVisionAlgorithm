function epoch = findLastCheckpoint(modelDir)
% epoch = findLastCheckpoint(modelDir)
%
% Find the last checkpoint to continue previous trainings.
%
% Copyright by Holger Caesar, 2015

list = dir(fullfile(modelDir, 'net-epoch-*.mat'));
tokens = regexp({list.name}, 'net-epoch-([\d]+).mat', 'tokens');
epoch = cellfun(@(x) sscanf(x{1}{1}, '%d'), tokens);
if isempty(epoch)
    epoch = NaN;
else
    epoch = max(epoch);
end