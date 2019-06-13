function[c] = cellRemoveEmptyEntries(c)
% [c] = cellRemoveEmptyEntries(c)
%
% Remove empty entries of a cell. The output is the resulting cell vector.
%
% Copyright by Holger Caesar, 2014

c = c(cellfun(@(x) ~isempty(x), c));