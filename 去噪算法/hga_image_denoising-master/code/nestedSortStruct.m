%%%
%{
Copyright (c) 2010, Jake Hughey
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
%}
%%%

function [sortedStruct index] = nestedSortStruct(aStruct, fieldNamesCell, directions)
% [sortedStruct index] = nestedSortStruct(aStruct, fieldNamesCell, directions)
% nestedSortStruct returns a nested sort of a (one-dimensional) struct array
% (aStruct), and can also return an index vector. The fields by which to sort are
% specified in a cell array of strings fieldNamesCell. Fields must be single numbers or
% logicals, or chars (usually simple strings).
%
% fieldNamesCell can also be a simple string of one fieldname, in which case
% nestedSortStruct will simply call sortStruct. This will be faster than putting the
% single fieldname in a cell array.
%
% directions is an optional argument to specify whether the struct array should be sorted
% in ascending or descending order for the fields. By default, the struct array will be
% sorted in ascending order for each field. If supplied, directions must be
%       1) a single 1 to sort in ascending order for all fields, or
%       2) a single -1 to sort in descending order for all fields, or
%       3) a vector of 1's and -1's, the same length as fieldNamesCell, where the struct
%          array will be sorted in the order specified by directions(ii) for
%          fieldNamesCell(ii).
%
% nestedSortStruct basically converts the struct array to a cell array, then converts
% relevants parts of the cell array to a matrix, on which sortrows is run.
%
% nestedSortStruct will usually be faster than nestedSortStruct2. For nestedSortStruct,
% the speed of sorting is mostly independent of the order of the fieldnames in fieldNamesCell.
%
% For nestedSortStruct2, the order of the fields in fieldNamesCell affects the speed. The
% sooner a field for which most entries in the struct array have unique values will be
% used to sort the struct array (i.e., the earlier that field's location in
% fieldNamesCell), the faster nestedSortStruct2 will be. If a field with mostly unique
% entries is the first field by which the struct array will be sorted, nestedSortStruct2
% could be faster than nestedSortStruct.

%% check struct
if ~isstruct(aStruct)
    error('first input supplied is not a struct.')
end % if

if sum(size(aStruct)>1)>1 % if more than one non-singleton dimension
    error('I don''t want to sort your multidimensional struct array.')
end % if

%% check fieldnames
if ~iscell(fieldNamesCell)
    if isfield(aStruct, fieldNamesCell) % if fieldNamesCell is a simple string of a valid fieldname
        [sortedStruct index] = sortStruct(aStruct, fieldNamesCell);
        return
    else
        error('second input supplied is not a cell array or simple string of a fieldname.')
    end % if isfield
end % if ~iscell

if ~isfield(aStruct, fieldNamesCell)
    for ii=find(~isfield(aStruct, fieldNamesCell))
        fprintf('%s is not a fieldname in the struct.\n', fieldNamesCell{ii})
    end % for
    error('at least one entry in fieldNamesCell is not a fieldname in the struct.')
end % if

%% check classes of fieldnames
fieldFlag = 0;
for ii=1:length(fieldNamesCell)
    fieldEntry = aStruct(1).(fieldNamesCell{ii});
    if ~( ((isnumeric(fieldEntry) || islogical(fieldEntry)) && numel(fieldEntry)==1) || ischar(fieldEntry) )
        fprintf('%s is not a valid fieldname by which to sort.\n', fieldNamesCell{ii})
        fieldFlag = 1;
    end % if
end % for ii

if fieldFlag
    error('at least one fieldname is not a valid one by which to sort.')
end

%% check directions, create if necessary (1 for ascending, -1 for descending)
if nargin < 3 % if directions doesn't exist
    directions = ones(1, length(fieldNamesCell));
else % check directions if it does exist
    if ~(isnumeric(directions) && all(ismember(directions, [-1 1])))
        error('directions, if given, must be a single number or a vector with 1 (ascending) and -1 (descending).')
    end % if ~(...
    
    if numel(directions)==1
        directions = directions * ones(1, length(fieldNamesCell)); % create vector from single element
    elseif length(fieldNamesCell)~=length(directions)
        error('fieldNamesCell and directions vector are different lengths.')
    end % if numel...
end % if exist...

%% fieldNamesIdx is a vector of the indices of the fields by which to sort
[dummy fieldNamesIdx] = ismember(fieldNamesCell, fieldnames(aStruct));

%% convert the struct to a cell, squeeze makes sure both row and column arrays are sorted properly, transpose for sortrows
aCell = squeeze(struct2cell(aStruct))';

%% sortrows of aCell, using indices from fieldNamesIdx and directions
[sortedCell index] = sortrows(aCell, fieldNamesIdx .* directions);

sortedStruct = aStruct(index); % apply the index to the struct array