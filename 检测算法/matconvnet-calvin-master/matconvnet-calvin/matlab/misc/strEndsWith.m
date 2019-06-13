function[result] = strEndsWith(str, prefix)
% [result] = strEndsWith(str, prefix)
%
% Check whether a given string end with a given prefix.
%
% Copyright by Holger Caesar, 2014

result = false;
assert(~isempty(prefix));
if numel(str) >= numel(prefix) && strcmp(str(end-numel(prefix)+1:end), prefix),
    result = true;
end;