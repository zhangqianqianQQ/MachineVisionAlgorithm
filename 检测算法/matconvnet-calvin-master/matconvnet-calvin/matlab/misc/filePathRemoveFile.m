function[path] = filePathRemoveFile(path)
% [path] = filePathRemoveFile(path)
%
% Removes the file name from a file path to have just the path of the folder.
% Files will be reduced to empty strings.
%
% Copyright by Holger Caesar, 2014

delims = strfind(path, filesep);
if iscell(path),
    % For cells
    empties = find(cellfun(@isempty, delims));
    delims(empties) = repmat({1}, [numel(empties), 1]);
    path = cellfun(@(x, y) x(1:y(end)-1), path, delims, 'UniformOutput', false);
else
    % For strings
    if isempty(delims),
        path = [];
    else
        path = path(1:delims(end)-1);
    end;
end;