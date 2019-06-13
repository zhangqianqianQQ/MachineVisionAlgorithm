function[res] = struct2Varargin(stru)
% [res] = struct2Varargin(stru)
%
% Convert a struct to the varargin format of Matlab.
% (alternating name and value of each field)
%
% Copyright by Holger Caesar, 2015

% Check inputs
assert(numel(stru) == 1);

% Get struct fields
fields = fieldnames(stru);
fieldCount = numel(fields);

% Init result
res = cell(1, fieldCount * 2);

for fieldIdx = 1 : fieldCount,
    res{1 + ((fieldIdx-1) * 2)} = fields{fieldIdx};
    res{2 + ((fieldIdx-1) * 2)} = stru.(fields{fieldIdx});
end;