function[answer] = isfieldRec(struct, varargin)
% [answer] = isfieldRec(struct, varargin)
%
% Check if a struct has all the fields and subfields specified by their name strings.
% I.e. to see if struct a has child b with element c, call isfieldRec(a, 'b', 'c')
%
% Copyright by Holger Caesar, 2014

answer = true;
nargs = numel(varargin);

for i = 1 : nargs,
    fieldName = varargin{i};
    if ~isfield(struct, fieldName),
        answer = false;
        return;
    elseif i < nargs,
        struct = getfield(struct, fieldName);
    end;
end;