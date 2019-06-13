
%% Parameters
loadParameters;

patches_per_scale = 5;

im_name = '101_0173.JPG';
set_id = '1'; % describes the set id assigned in the training/validation split (1=MSRC, 2=PASCAL)
path_images = '/Volumes/SHARED HD/Video Summarization Project Data Sets/MSRC/JPEGImages';
% path_images = '/Volumes/SHARED HD/Video Summarization Project Data Sets/PASCAL_12/VOCdevkit/VOC2012/JPEGImages';

%% Load maps
if(~isempty(set_id))
    im_name_ = [set_id '_' im_name];
else
    im_name_ = im_name;
end
load([path_maps '/' im_name_ '_maps.mat']); % maps
props = maps.resizeMaps;
maps = maps.maps;
% load([path_maps '/' im_name '_objects.mat']); % objects

%% Load image
img = imread([path_images '/' im_name]);
img = imresize(img, [size(img,1)/props size(img,2)/props]);

ratio_general = size(img,1)/size(img,2);
scale = [0 1];

%% Generate objects list
[objects_list, ~, scales] = mergeWindows(maps, ODCNN_params);
objects.list = objects_list;
objects.scales = scales;

%% Prepare plot dimensions
nCols = patches_per_scale;
nMaps = length(maps);
nRows = ceil(nMaps/nCols)+1;

%% Plot
f = figure;
% Fixed figure size
set(f, 'Position', [1 1 750 720])

%% Plot original image
ha = tight_subplot(nRows, nCols, [.02 .00],[.02 .00],[.01 .01]);
original_position = round(patches_per_scale/2);
axes(ha(original_position)); imshow(img);

%% Remove unuseful figures
for nInvisible = setdiff(1:patches_per_scale, original_position)
    set(ha(nInvisible),'visible','off');
end

%% Plot each map
for i = 1:nMaps
    if(size(maps(i).map,3) == 0)
        set(ha(i+patches_per_scale),'visible','off');
    else
        axes(ha(i+patches_per_scale)); h = imagesc(imresize(maps(i).map, [size(img,1) size(img,2)]), scale);
        % Copy original image aspect ratio
        aH = ancestor(h,'axes');
        axis equal;
        set(aH,'PlotBoxAspectRatio',[1 ratio_general 1])
    end
    
    % Show x and y axis labels
	if(i <= patches_per_scale)
        title(['patch props: [' num2str(maps(i).patch_props) ']']);
    end
    if(mod(i-1, patches_per_scale) == 0)
        ylabel(['image scale: [' num2str(maps(i).image_scale) ']']);
    end
end

%% Plot final object windows
f2 = figure;
set(f2, 'Position', [1200 650 100 200])
imshow(img);
title('Selected Bounding Boxes', 'FontSize', 14);

nScales = length(objects.list);
for i = 1:nScales
    s = regexp(objects.scales{i}, '_', 'split');
    s = [str2num(s{1}) str2num(s{2})];
    objs = objects.list{i};
    
    ratio = size(img,2)/s(2);
    for o = objs'
        o = o*ratio;
        rectangle('Position', [o(1) o(2) o(3)-o(1)+1 o(4)-o(2)+1], 'EdgeColor', 'r', 'LineWidth', 2);
    end
end

%% Set colorbar
axes(ha(original_position+1));
colorbar('south');
caxis(scale);

