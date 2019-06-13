function[var] = getFreeVariable(obj)
% [var] = getFreeVariable(obj)
%
% Returns the name of a new free variable.
% The name is xi where i is the smallest unused integer in the existing
% variables.
%
% Copyright by Holger Caesar, 2015

names = {obj.vars.name};
inds = nan(numel(names, 1));

for i = 1 : numel(names),
    [tok, ~] = regexp(names{i}, 'x(\d+)', 'tokens', 'match');
    if ~isempty(tok),
        inds(i) = str2double(tok{1});
    end;
end;

maxInd = max(inds);
var = sprintf('x%d', maxInd+1);