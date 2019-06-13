function startup()

curdir = fileparts(mfilename('fullpath'));

% set to edge_boxes_path the path where the edge boxes code 
% (https://github.com/pdollar/edges) is installed 
edge_boxes_path = '../edges/'; 
if exist(edge_boxes_path,'dir') > 0
    addpath(edge_boxes_path) 
else
    warning('The Edge Boxes installation directory "%s" is not valid. Please install the Edge boxes code (https://github.com/pdollar/edges) and set the path to its installation directory in the edge_boxes_path variable of the startup.m file if you want use the Edge Box proposals', edge_boxes_path)
end

edge_boxes_link_path = fullfile(curdir, 'external', 'edges');
if exist(edge_boxes_link_path, 'dir') == 0
    warning('A link to the edge box installation directory is missing from external/edges; See README.md');
end

% set to pdollar_toolbox_path the path where the Piotr's Matlab Toolbox 
% (http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html) is installed   
pdollar_toolbox_path = '../pdollar-toolbox/';
if exist(pdollar_toolbox_path,'dir') > 0 
    addpath(genpath(pdollar_toolbox_path))
else
    warning('The installation directory "%s" to Piotrs image processing toolbox (http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html) is not valid. Please install the toolbox and set the installation directory path to the pdollar_toolbox_path variable of the startup.m file if you to want use the Edge Box proposals', pdollar_toolbox_path)
end

% set to selective_search_boxes_path the path where the Selective Search code 
% (http://huppelen.nl/publications/SelectiveSearchCodeIJCV.zip) is installed   
selective_search_boxes_path = '../selective_search/';
if exist(selective_search_boxes_path,'dir') > 0 
    addpath(genpath(selective_search_boxes_path))
else
    warning('The installation directory "%s" to the Selective Serach code (http://huppelen.nl/publications/SelectiveSearchCodeIJCV.zip) is not valid. Please install the Selective Search code and set the installation directory path to the selective_search_boxes_path variable of the startup.m file if you want to use the Selective Search proposals', selective_search_boxes_path)
end

addpath(genpath(fullfile(curdir, 'code')));
addpath(fullfile(curdir, 'bin'));

mkdir_if_missing(fullfile(curdir, 'external'));
caffe_path = fullfile(curdir, 'external', 'caffe', 'matlab');
if exist(caffe_path, 'dir') == 0
    error('matcaffe is missing from external/caffe/matlab; See README.md');
end
addpath(genpath(caffe_path));




mkdir_if_missing(fullfile(curdir, 'models-exps'));
mkdir_if_missing(fullfile(curdir, 'feat_cache'));
mkdir_if_missing(fullfile(curdir, 'data'));
mkdir_if_missing(fullfile(curdir, 'bin'));

end
