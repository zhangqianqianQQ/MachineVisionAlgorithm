function stats = accumulateStats(obj, stats_)
% stats = accumulateStats(obj, stats_)
%
% Goes through each GPUs struct stats_{g} and averages the values of all
% stats fields.
%
% Copyright by Matconvnet
% Modified by Holger Caesar, 2016

stats = struct();
datasetMode = obj.imdb.datasetMode;
total = 0;

for g = 1 : numel(stats_)
    stats__ = stats_{g};
    num__ = stats__.(datasetMode).num;
    total = total + num__;
    
    for field = setdiff(fieldnames(stats__.(datasetMode))', 'num')
        field = char(field); %#ok<FXSET>
        
        if g == 1
            stats.(datasetMode).(field) = 0;
        end
        stats.(datasetMode).(field) = stats.(datasetMode).(field) + stats__.(datasetMode).(field) * num__;
        
        if g == numel(stats_)
            stats.(datasetMode).(field) = stats.(datasetMode).(field) / total;
        end
    end
end
stats.(datasetMode).num = total;