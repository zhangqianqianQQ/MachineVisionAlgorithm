function [features, labels] = load_images()
    %% Check if dataset file already exists and only execute script if not
    if exist('cache/dataset.mat', 'file') == 2
        display('Cache file found, loading precomputed data ...')
        tic
        
        load('cache/dataset')
        
        display(['   ... Completed in ' num2str(toc) ' seconds.'])
        return
    end

    %% Load all images to memory
    display('Loading images ...')
    tic

    pos_folder = 'INRIAPerson/train_64x128_H96/pos';
    neg_folder = 'INRIAPerson/train_64x128_H96/neg';

    % Get positive folder images
    pos_filenames = dir(pos_folder);
    pos_filenames = {pos_filenames.name}';
    pos_filenames = pos_filenames(3:end);

    % Get negative folder images
    neg_filenames = dir(neg_folder);
    neg_filenames = {neg_filenames.name}';
    neg_filenames = neg_filenames(3:end);

    % Each negative will generate 10 images
    imcount = size(pos_filenames, 1) + 10 * size(neg_filenames, 1);
    imsize = [128, 64, 3];
    images = single(zeros(imsize(1), imsize(2), imsize(3), imcount));

    % Load positive samples
    for i = 1:size(pos_filenames, 1)
        imloaded = im2single(imread([pos_folder '/' pos_filenames{i}]));
        images(:, :, :, i) = imloaded(17:end-16, 17:end-16, :);
    end

    % Load negative samples
    offset = size(pos_filenames, 1);
    rng(0);  % Use fixed seed for mining to get reproductable results

    for i = 1:size(neg_filenames, 1)
        imloaded = im2single(imread([neg_folder '/' neg_filenames{i}]));
        % Skip image if it's too small
        if any((size(imloaded) - imsize) <= 0)
            continue;
        end

        for j = 1:10
            r = randi([0, size(imloaded, 1) - imsize(1)]);
            c = randi([0, size(imloaded, 2) - imsize(2)]);

            imcut = imloaded(r + [1:imsize(1)], c + [1:imsize(2)], :);
            images(:, :, :, offset + 10*i + j - 10) = imcut;
        end
    end

    %% Create ground-truth label
    labels = zeros(imcount, 1);
    labels(1:offset) = 1;  % Pedestrian is 1, Nonpedestrian is 0

    display(['   ... Completed in ' num2str(toc) ' seconds.'])

    %% Calculate image HoG feature set
    display('Calculating HoG features ...')
    tic

    featsize = numel(hog(images(:,:,:,1)));
    features = single(zeros(imcount, featsize));

    for i = 1:imcount
        imhog = hog(images(:,:,:,i));
        features(i, :) = imhog(:)';
    end

    display(['   ... Completed in ' num2str(toc) ' seconds.'])
    
    %% Randomly permute the dataset
    display('Permuting the dataset ...')

    idx = randperm(size(features, 1));
    features = features(idx, :);
    labels = labels(idx, :);

    display(['   ... Completed in ' num2str(toc) ' seconds.'])

    %% Saving results to file
    save('cache/dataset', 'features', 'labels')
end