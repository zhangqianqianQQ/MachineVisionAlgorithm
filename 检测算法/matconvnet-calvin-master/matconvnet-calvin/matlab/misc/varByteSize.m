function[size] = varByteSize(var) %#ok<INUSD>
% [size] = varByteSize(var)
%
% Returns the size of a variable in bytes.
%
% Copyright by Holger Caesar, 2014

s = whos('var');
size = s.bytes;