function[invPerm] = invertPermutation(perm)
% [invPerm] = invertPermutation(perm)
%
% Invert a given permutation such that the following statement is true for row vectors:
% isequal(perm(invertPermutation(perm)), 1:numel(perm))
%
% Copyright by Holger Caesar, 2014

invPerm = findIndexPermutation(perm, 1:numel(perm));