function imdb = imdb_from_caltech(root_dir, image_set)
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

cache_file = ['./imdb/cache/imdb_caltech_' image_set];

try
    load(cache_file);
catch
    imdb.name = image_set;
    imdb.extension = '.jpg';
    imdb.image_dir = fullfile(root_dir, imdb.name, 'caltech', 'images');
    imgs=dir(fullfile(imdb.image_dir,'*.jpg'));
    flip=true;
    
    
    for i = 1:length(imgs)
        imdb.image_ids{i} = imgs(i).name(1:end-4);
    end


    imdb.image_at = @(i) fullfile(imdb.image_dir, [imdb.image_ids{i} imdb.extension]);

    for i = 1:length(imdb.image_ids)
        % resize all of Caltech images from 640x480 to 640x512 to be comparable with KAIST images 
        % annotations are also modified in roidb_from_caltech.m
        img=imread(imdb.image_at(i));
        img=imresize(img,[512,640]);
        imwrite(img,imdb.image_at(i));
        imdb.sizes(i, :) = [512 640]; 
    end

    imdb.num_classes = 1;
    imdb.classes{1} = 'pedestrian';

    fprintf('Saving imdb to cache...');
    save(cache_file, 'imdb', '-v7.3');
    fprintf('done\n');
end
