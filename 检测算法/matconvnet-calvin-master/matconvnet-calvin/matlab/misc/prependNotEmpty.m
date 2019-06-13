function[res] = prependNotEmpty(str, prefix)
% [res] = prependNotEmpty(str, prefix)
%
% Prepend a prefix to a string, if it is not empty.
%
% Copyrights by Holger Caesar, 2015

if ~isempty(str),
    res = [prefix, str];
else
    res = '';
end;