function training(video)

previousMethod = 'MSCNN'; % BasicCNN or MSCNN

opts.expDir = [previousMethod 'net/', video];

opts.train.batchSize = 5 ;
opts.train.numEpochs = 20;
opts.train.continue = true ;
opts.train.useGpu = true ;
opts.train.learningRate = 1e-3;
opts.train.expDir = opts.expDir;

% --------------------------------------------------------------------
% Prepare data
% --------------------------------------------------------------------
imgDir = ['../SBMIDataset/' video '/input'];
labelDir = ['../SBMIDataset/' video '/groundtruth'];
grayDir = ['../' previousMethod '/result/', video];

imdb = getImdb_new(video, imgDir, labelDir, grayDir);


imdb.half_size = 15;

%%%%%%Yi%%%%%% redefined the net
load('net');

net.layers{1} = struct('type', 'conv', ...
    'filters', 0.01 * randn(7, 7, 4, 32, 'single'), ...
    'biases', zeros(1, 32, 'single'), ...
    'stride', 1, ...
    'pad', 0) ;

net.layers{end-1} = struct('type', 'conv', ...
    'filters', 0.1*randn(1,1,64,1, 'single'), ...
    'biases', zeros(1, 1, 'single'), ...
    'stride', 1, ...
    'pad', 0) ;
net.layers{end} = struct('type', 'sigmoidcrossentropyloss');

load('meanPixel.mat');
imdb.meanPixel = meanPixel;

[net,info] = cnn_train_adagrad(net, imdb, @getBatch,...
    opts.train, 'errorType', 'euclideanloss', ...
    'conserveMemory', true);
end

function [im, labels, mask] = getBatch(imdb, batch)

half_size = imdb.half_size;
meanPixel = imdb.meanPixel;
meanPixel(:,:,4) =0;

for ii = 1 : numel(batch)
    imagename = imdb.images.name{batch(ii)};
    im_ii = single(imread(imagename));
    
    labelname = imdb.images.labels{batch(ii)};
    roi = imread(labelname);
    labels_ii = zeros(size(roi, 1), size(roi, 2));
    labels_ii( roi == 50 )  = 0.25;       %shade
    labels_ii( roi == 170 ) = 0.75;       %object boundary
    labels_ii( roi == 255 ) = 1;          %foreground
    
    % resize the image to half size
    if size(im_ii, 1) > 400 || size(im_ii, 2) >400
        im_ii = imresize(im_ii, 0.5, 'nearest');
        labels_ii = imresize(labels_ii, 0.5, 'nearest');
    end
    
    grayname =imdb.images.gray_name{batch(ii)};
    
    im_ii(:,:,4) = single(imread(grayname));
    
    im_large = padarray(im_ii, [half_size, half_size], 'symmetric');
    im_ii = bsxfun(@minus, im_large, meanPixel);
    
    im(:, :, :, ii) = im_ii;
    labels(:, :, 1, ii) = labels_ii;
    labels(:, :, 2, ii) = double(imdb.mask);
end
end

function imdb = getImdb_new(video, imgDir, labelDir, grayDir)

files = [dir([imgDir '/*.jpg']); dir([imgDir '/*.png'])];
label_files = dir([labelDir '/*.png']);
gray_files = dir([grayDir '/*.png']);

names = {};
labels = {};
gray_names = {};

load(['../split/' video '.mat']);

for ii = 1:numel(train_index)
    k = train_index(ii);
    
    names{end+1} = [imgDir '/' files(k).name];
    labels{end+1} = [labelDir '/' label_files(k).name];
    gray_names{end+1} = [grayDir '/' gray_files(k).name];
    
end

im = imread(labels{1});
mask = ones(size(im,1),size(im,2));
if size(mask,1) > 400 || size(mask,2) >400
    mask = imresize(mask, 0.5, 'nearest');
end

imdb.mask = single(mask);

imdb.images.set = ones(1,numel(names));
imdb.images.name = names ;
imdb.images.gray_name = gray_names;
imdb.images.labels = labels;
end