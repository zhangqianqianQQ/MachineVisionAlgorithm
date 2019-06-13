function D=imdir(dirname,filter)

% IMDIR lists image content in the directory specified by dirname.
%   Returns a structure similar to the one returned by MATLAB's dir
%   function. Additional filter on the image file name can be specified.
%
% See also DIR
% (c) Michael Rubinstein, MIT
%

if nargin<2
    filter='';
end

if ~exist(dirname,'dir')
    error([dirname ' not found.']);
end

D=dir(fullfile(dirname,sprintf('*%s*',filter)));
D=D(cellfun(@isImageFile,{D(:).name}));


function tf=isImageFile(filename)

% supported formats
formats = {'jpg','jpeg','png','bmp','pgm','gif','ppm','tif','tiff'};

[path,name,ext]=fileparts(filename);
ext = ext(2:end); % remove '.'

tf = any(strcmpi(ext,formats));
