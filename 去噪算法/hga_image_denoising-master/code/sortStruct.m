function [sortedStruct index] = sortStruct(aStruct, fieldName, direction)
% [sortedStruct index] = sortStruct(aStruct, fieldName, direction)
% sortStruct returns a sorted struct array, and can also return an index vector. The
% (one-dimensional) struct array (aStruct) is sorted based on the field specified by the
% string fieldName. The field must a single number or logical, or a char array (usually a
% simple string).
%
% direction is an optional argument to specify whether the struct array should be sorted
% in ascending or descending order. By default, the array will be sorted in ascending
% order. If supplied, direction must equal 1 to sort in ascending order or -1 to sort in
% descending order.

%% check inputs
if ~isstruct(aStruct)
    error('first input supplied is not a struct.')
end % if

if sum(size(aStruct)>1)>1 % if more than one non-singleton dimension
    error('I don''t want to sort your multidimensional struct array.')
end % if

if ~ischar(fieldName) || ~isfield(aStruct, fieldName)
    error('second input is not a valid fieldname.')
end % if

if nargin < 3
    direction = 1;
elseif ~isnumeric(direction) || numel(direction)>1 || ~ismember(direction, [-1 1])
    error('direction must equal 1 for ascending order or -1 for descending order.')
end % if

%% figure out the field's class, and find the sorted index vector
fieldEntry = aStruct(1).(fieldName);

if (isnumeric(fieldEntry) || islogical(fieldEntry)) && numel(fieldEntry) == 1 % if the field is a single number
    [dummy index] = sort([aStruct.(fieldName)]);
elseif ischar(fieldEntry) % if the field is char
    [dummy index] = sort({aStruct.(fieldName)});
else
    error('%s is not an appropriate field by which to sort.', fieldName)
end % if ~isempty

%% apply the index to the struct array
if direction == 1 % ascending sort
    sortedStruct = aStruct(index);
else % descending sort
    sortedStruct = aStruct(index(end:-1:1));
end