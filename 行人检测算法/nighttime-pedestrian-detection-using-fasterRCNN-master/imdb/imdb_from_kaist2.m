function imdb = imdb_from_kaist2(root_dir, image_set)
% imdb = imdb_from_caltech(root_dir, image_set, flip)
%   Package the image annotations into the imdb. 
%
%   Inspired by Ross Girshick's imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

cache_file = ['./imdb/cache/imdb_kaist_' image_set];

try
    load(cache_file);
catch
    imdb.name = image_set;
    imdb.extension = '.png';
    
    imgs=[];
    if(strcmp(image_set,'train'))
        flip=true;
        imdb.image_dir = fullfile(root_dir,'train','kaist','images');
        imgs=dir(fullfile(imdb.image_dir, ['*', imdb.extension]));
    else
        flip=false;
        imdb.image_dir = fullfile(root_dir,'test','images');
        imgs=dir(fullfile(imdb.image_dir, ['*', imdb.extension]));
    end
    
    imdb.image_ids = cell(length(imgs), 1); 

    for i = 1:length(imgs)
        imdb.image_ids{i} = imgs(i).name(1:end-4);
    end

    imdb.image_at = @(i) fullfile(imdb.image_dir, [imdb.image_ids{i} imdb.extension]);

    for i = 1:length(imdb.image_ids)
        imdb.sizes(i, :) = [512 640]; % the size is fix for kaist
    end

    imdb.num_classes = 1;
    imdb.classes{1} = 'pedestrian';

    fprintf('Saving imdb to cache...');
    save(cache_file, 'imdb', '-v7.3');
    fprintf('done\n');
end
