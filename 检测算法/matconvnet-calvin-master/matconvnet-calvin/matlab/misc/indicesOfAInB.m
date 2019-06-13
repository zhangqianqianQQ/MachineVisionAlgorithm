function[inds] = indicesOfAInB(A, B)
% [inds] = indicesOfAInB(A, B)
%
% Get the indices of a list B such that B(inds) == A.
% This assumes that each element of A is in B (but not the other way
% around).
% Note: % B need not be unique, but A does!
% Afterwards: B(indicesOfAInB(A, B)) == A
%
% Copyright by Holger Caesar, 2014

% Make column vectors
A = A(:)';
B = B(:)';

% Check for duplicates in A
Aun = unique(A, 'stable');
assert(isequal(A, Aun), 'Error: This function only works for unique elements in A (but not in B)!');

% Intersect A and B
[~, indsIntoB] = intersect(B, A);

% Since inter is sorted, we need to sort A as well
[~, AunSorting] = sort(A);

% Additional assertions to understand what's going on
% assert(isequal(A(Asorting), inter));
% assert(isequal(inter, B(indsIntoB)));

% Check if A is really included in B
checkIncluded = ismember(A, B);
if ~all(checkIncluded),
    notIncludedList = strjoin(A(find(~checkIncluded, 5)), ', ');
    error('Error: Some elements of A are not included in B! Examples are %s', notIncludedList);
end;

% Apply mappings from B to inter and then from inter to A
inds = indsIntoB(invertPermutation(AunSorting));

% Consistency check
assert(isequal(A, B(inds)));