function [positive_images, negative_images] = get_files(pos_elems, neg_elems, paths)
% GET_FILES retrieves complete paths to every JPG, PNG or PPM image file. 
%  
% INPUT:
%       pos/neg_elems: pos/negs max elems to retrieve
%       paths: paths from where to retrieve image paths
%
% OUTPUT:
%       positive / negative_images: paths to the images.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 25-Dec-2013 23:41:52 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_files.m 

IMG_WILDCARDS = {'*.jpg','*.png','*.ppm'};

    %% path stuff
    if nargin < 3
        positive_images_path = uigetdir('.images','Select positive image folder');
        negative_images_path = uigetdir('.images','Select negative image folder');
        
        if isa(positive_images_path,'double')  || ...
           isa(negative_images_path,'double')
            cprintf('Errors','Invalid paths...\nexiting...\n\n')
            return 
        end
        
    else
        positive_images_path = paths{1};
        negative_images_path = paths{2};
    end
    

    %% getting POSITIVE images and count
    positive_images = [];
    for i=1:numel(IMG_WILDCARDS)
        wildcard = strcat(positive_images_path,filesep,IMG_WILDCARDS{i});
        positive_images = [positive_images; rdir(wildcard)];
    end
    fprintf('current positive path: %s \n', positive_images_path);


    % getting a random sample of the total number of images
    if pos_elems < 0
        pos_elems = numel(positive_images);
    end
    idx = randperm(numel(positive_images));
    positive_images = positive_images(idx(1:pos_elems));
    num_pos_images = size(positive_images,1);
    fprintf('getting %d positive images HOGs\n', num_pos_images);
    
    
    %% getting NEGATIVE images path and count
    negative_images = [];
    for i=1:numel(IMG_WILDCARDS)
        wildcard = strcat(negative_images_path,filesep,IMG_WILDCARDS{i});
        negative_images = [negative_images; rdir(wildcard)];
    end
    fprintf('current negative path: %s \n', negative_images_path);

    
    % getting a random sample of the total number of images
    if neg_elems < 0
        neg_elems = numel(negative_images);
    end
    idx = randperm(numel(negative_images));
    negative_images = negative_images(idx(1:neg_elems));
    num_neg_images = size(negative_images,1);
    fprintf('getting %d negative images HOGs\n', num_neg_images);
