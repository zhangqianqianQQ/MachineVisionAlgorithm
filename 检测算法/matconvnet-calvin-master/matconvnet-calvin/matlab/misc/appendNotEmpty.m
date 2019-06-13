function[res] = appendNotEmpty(str, suffix)
% [res] = appendNotEmpty(str, suffix)
%
% Append a suffix to a string, if it is not empty.
%
% Copyrights by Holger Caesar, 2015

if ~isempty(str),
    res = [str, suffix];
else
    res = '';
end;