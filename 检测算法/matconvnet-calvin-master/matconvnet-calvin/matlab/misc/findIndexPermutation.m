function[perm] = findIndexPermutation(from, to)
% [perm] = findIndexPermutation(from, to)
%
% Find a permutation that maps indices from to to.
% Make sure that both lists include exactly the same elements (but possibly
% in different order).
%
% Copyright by Holger Caesar, 2014

% Convert to column vectors
from = from(:);
to = to(:);

% Check identical length
assert(numel(from) == numel(to));

[fromS, a] = sort(from);
[toS, b] = sort(to);

assert(all(fromS == toS), 'Cannot find permutation between vectors with entirely different elements!');

perm = b(a);

