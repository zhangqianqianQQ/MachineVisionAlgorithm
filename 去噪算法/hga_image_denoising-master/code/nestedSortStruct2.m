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


function [sortedStruct index] = nestedSortStruct2(aStruct, fieldNamesCell, directions, classFields)
% [sortedStruct index] = nestedSortStruct2(aStruct, fieldNamesCell, directions, classFields)
% nestedSortStruct2 returns a nested sort of a (one-dimensional) struct array
% (aStruct), and can also return an index vector. The fields by which to sort are
% specified in a cell array of strings fieldNamesCell. Fields must be single numbers or
% logicals, or chars (usually simple strings).
%
% fieldNamesCell can also be a simple string of one fieldname, in which case
% nestedSortStruct2 will simply call sortStruct. This will be faster than putting the
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
% classFields is an optional argument that should not be used when calling
% nestedSortStruct2 directly. recursive calls to nestedSortStruct2 use classFields to
% bypass checking inputs and determining classes of fields.
%
% nestedSortStruct2 sorts the struct array recursively, without converting it to a cell
% array.
%
% nestedSortStruct will usually be faster than nestedSortStruct2. For nestedSortStruct,
% the speed of sorting is mostly independent of the order of the fieldnames in
% fieldNamesCell.
%
% For nestedSortStruct2, the order of the fields in fieldNamesCell affects the speed. The
% sooner a field for which most entries in the struct array have unique values will be
% used to sort the struct array (i.e., the earlier that field's location in
% fieldNamesCell), the faster nestedSortStruct2 will be. If a field with mostly unique
% entries is the first field by which the struct array will be sorted, nestedSortStruct2
% could be faster than nestedSortStruct.

%% check inputs, construct classFields
if nargin < 4 % if classFields does not exist, check inputs
    if ~isstruct(aStruct)
        error('first input supplied is not a struct.')
    end % if
    
    if sum(size(aStruct)>1)>1 % if more than one non-singleton dimension
        error('I don''t want to sort your multidimensional struct array.')
    end % if

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
        error('at least one entry in fieldNamesCell is not actually a fieldname in the struct.')
    end % if
    
    % check classes of fieldnames, construct classFields (0 for numeric, 1 for char)
    classFields = zeros(1, length(fieldNamesCell));
    for ii=1:length(fieldNamesCell)
        fieldEntry = aStruct(1).(fieldNamesCell{ii});
        classFields(ii) = 1*((isnumeric(fieldEntry) || islogical(fieldEntry)) && numel(fieldEntry)==1) + 2*(ischar(fieldEntry)) - 1;
    end % for ii
    if any(classFields == -1)
        for ii=find(classFields==-1)
            fprintf('%s is not a valid fieldname by which to sort.\n', fieldNamesCell{ii})
        end % for ii
        error('at least one fieldname is not a valid one by which to sort.')
    end % if any...
    
    % check directions, create directNew
    if nargin < 3 % if directions doesn't exist
        directNew = ones(1, length(fieldNamesCell));
    else % check directions if it does exist
        if ~(isnumeric(directions) && all(ismember(directions, [-1 1])))
            error('directions, if given, must be a single number or a vector with 1 (ascending) and -1 (descending).')
        end % if ~(...
        
        if numel(directions)==1
            directNew = directions * ones(1, length(fieldNamesCell)); % create vector from single element
        elseif length(fieldNamesCell)~=length(directions)
            error('fieldNamesCell and directions vector are different lengths.')
        end % if numel...
    end % if exist...

else % classFields exists, so directions should be in correct form
    directNew = directions;
end % if check

%% sort by the first fieldname, then recursively call nestedSortStruct2 to sort by remaining fieldnames
if length(fieldNamesCell)==1 % if one fieldname
    [sortedStruct index] = sortStruct2(aStruct, fieldNamesCell{1}, directNew(1), 0); % don't check inputs
else
    [sortedStruct1 index1] = sortStruct2(aStruct, fieldNamesCell{1}, directNew(1), 0); % don't check inputs
    
    switch classFields(1)
        case 0 % numeric
            [b m n] = unique([sortedStruct1.(fieldNamesCell{1})]);
        case 1 % char
            [b m n] = unique({sortedStruct1.(fieldNamesCell{1})});
        otherwise
            error('invalid classFields value encountered. you shouldn''t be here.')
    end % switch
     
    index2 = zeros(length(aStruct),1); % initialize index2
    sortedStruct = aStruct; % initialization of sortedStruct
    
    for ii=1:length(b) % for each group that has the same value for fieldname1
        startIdx = find(n==ii, 1, 'first'); % starting index of the group
        nNum = sum(n==ii); % number of members are in the group
        
        if nNum == 1 % don't sort if only one member in the group
            sortedStruct(startIdx) = sortedStruct1(n==ii);
            indexTemp = 1; % with only one member, that member is in position 1 of its group
        else % sort multiple members of the group
            [sortedStruct(startIdx:startIdx+nNum-1) indexTemp] = nestedSortStruct2(sortedStruct1(n==ii), fieldNamesCell(2:end), directNew(2:end), classFields(2:end)); % nested sort of remaining fieldnames
        end
        
        index2(startIdx:startIdx+nNum-1) = indexTemp + startIdx - 1; % correct the index offset for that group
    end % for ii
    
    index = index1(index2); % correct for two rounds of sorting
    
end % if length(fieldNamesCell)>1
    