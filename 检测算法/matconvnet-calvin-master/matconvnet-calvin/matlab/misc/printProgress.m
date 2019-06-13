function printProgress(message, iterIdx, iterCount, iterStep)
% printProgress(message, iterIdx, iterCount, [iterStep])
%
% Prints out the current iteration index.
% Only each (iterStep)th index will be printed to reduce logfile output.
%
% Copyright by Holger Caesar, 2014

% Default arguments
if ~exist('iterStep', 'var'),
    stepCount = 10;
    iterStep = floor(iterCount / stepCount);
    iterStep = max(1, min(iterCount, iterStep));
end;

if iterIdx == 1,
    % Start first line
    if ~isempty(message),
        fprintf('%s (total: %d)... 1', message, iterCount);
    end;
elseif iterIdx == iterCount,
    % Print final index
    fprintf(' %d', iterIdx);
elseif mod(iterIdx, iterStep) == 0
    % Regular status update
    fprintf(' %d', iterIdx);
end;

% Finally add a newline symbol
if iterIdx == iterCount,
    fprintf('\n');
end;