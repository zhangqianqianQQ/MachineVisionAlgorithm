function[fileList, fileCount] = dirSubfolders(folderPath, ext, removeExt)
% [fileList, fileCount] = dirSubfolders(folderPath, [ext], [removeExt])
%
% List the contents of a directory and each subdirectory
% ext can be '' or a specific string
%
% Updates:
%  15.12.2014: Imposing numerical sort order.
%
% Copyright by Holger Caesar, 2014

if nargin <= 1,
    ext = '';
end;

if nargin <= 2,
    removeExt = false;
end;

% Check if folder exists
if ~exist(folderPath, 'dir'),
    error('Error: Folder does not exist: %s', folderPath);
end;

% Depending on the OS, choose the appropriate method
if isunix(),
    fileList = dirSubfoldersLinux(folderPath, '', ext, removeExt);
    fileList = sort(fileList);
else
    fileList = dirSubfoldersRec(folderPath, '', ext);
    % Strip off the file extension (slow)
    if removeExt && ~isempty(ext),
        fileList = cellfun(@(x) regexprep(x, '.[a-zA-Z0-9]+$', ''), fileList, 'UniformOutput', false);
    end;
    fileList = sort(fileList);
end;

% Count images
fileCount = numel(fileList);


function[resultList] = dirSubfoldersLinux(folderPath, ~, ext, removeExt)
% [resultList] = dirSubfoldersLinux(folderPath, ~, ext, removeExt)

%%% Construct syscall
% Define system call (use only files, not directories)
syscall = ['SEARCHDIR="', folderPath, '/"; find "$SEARCHDIR" -type f'];

% Add extension if required
if ~isempty(ext),
    syscall = [syscall, ' -iname "*', ext, '"'];
end;

% Add syscall to remove SEARCHDIR
syscall = [syscall, ' | sed "s|$SEARCHDIR||"'];


% Remove the extension
if removeExt
%     assert(~isempty(ext)),
%     syscall = [syscall, ' | sed "s/', ext, '//"'];
    syscall = [syscall, ' | sed "s/\..*$//"'];
end;

%%% Execute syscall
% Write output to file and read it again
% Note: Always do useTempFile, because otherwise the beginning of output
% can be randomly dropped, which will result in serious bugs.
useTempFile = true;
if useTempFile,
    tempOutFile = tempname;
    syscall = sprintf('%s > "%s"', syscall, tempOutFile);
    [status, ~] = system(syscall);
    output = fileread(tempOutFile);
else
    [status, output] = system(syscall);
end;

%%% Check for errors
% Check status of system call
% Note this was changed because without , '\ņ' file names with spaces were
% trimmed as well.
if status,
    error('Error: System call failed: %s', output);
elseif isempty(output),
    % Return an empty cell
    resultList = cell(0, 1);
else
    % Make each row of the output an entry in a cell
    resultList = strsplit(strtrim(output), '\n')';
end;

function[resultList] = dirSubfoldersRec(folderPath, relPath, ext)
% [resultList] = dirSubfoldersRec(folderPath, relPath, ext)
%
% Recursively list the contents of a directory

% Concatenation even works if relPath is empty
fileList = dir(fullfile(folderPath, relPath));

% Remove folders . and ..
fileList = fileList(3:end);

resultList = cell(0, 1);

fileIdx = 1;
while fileIdx <= numel(fileList),
    % Check if it's a directory
    if fileList(fileIdx).isdir,
        newFolderPath = fullfile(relPath, fileList(fileIdx).name);
        newList = dirSubfoldersRec(folderPath, newFolderPath, ext);
        resultList(end+1:end+numel(newList), 1) = newList;
    elseif isempty(ext) || strcmp(fileList(fileIdx).name(end-numel(ext)+1:end), ext),
        resultList{end+1, 1} = fullfile(relPath, fileList(fileIdx).name); %#ok<AGROW>
    end;
    fileIdx = fileIdx + 1;
end;