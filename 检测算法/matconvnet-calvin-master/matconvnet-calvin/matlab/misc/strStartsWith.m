function[result] = strStartsWith(str, prefix)
% [result] = strStartsWith(str, prefix)
%
% Check whether a given string starts with a given prefix.
%
% Copyright by Holger Caesar, 2014

result = false;
assert(~isempty(prefix));

if iscell(str),
    result = cellfun(@(x) strStartsWith(x, prefix), str);
else
    if numel(str) >= numel(prefix) && strcmp(str(1:numel(prefix)), prefix),
        result = true;
    end;
end;