function[res] = matFileHasField(path, fieldName)
% [res] = matFileHasField(path, fieldName)
%
% Check whether a mat file includes a variable, without loading it.
% Returns true if it is included or else false.
%
% Copyright by Holger Caesar, 2015

matObj = matfile(path, 'Writable', false);
info = whos(matObj, fieldName);
res = numel(info) == 1;