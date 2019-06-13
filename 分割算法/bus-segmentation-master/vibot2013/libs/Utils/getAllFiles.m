% Function to get all files only under specific directory 
% (including subdirectories)
%
% ref: stackoverflow 
%      2652630/how-to-get-all-files-under-a-specific-directory-in-matlab

function fileList = getAllFiles(dirName,fileExtension)

  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir,fileExtension)];  %# Recursively call getAllFiles
  end

end