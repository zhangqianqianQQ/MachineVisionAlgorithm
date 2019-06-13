function regular_training_ms(video)

opts.dataDir = 'net/traffic_Simple' ;
opts.expDir = ['net/' video] ;


opts.train.batchSize = 5 ;
opts.train.numEpochs = 20;
opts.train.continue = false ;
opts.train.useGpu = true ;
opts.train.learningRate    = 1e-3;
opts.train.expDir = opts.expDir ;

scales = [1, 0.75, 0.5];


%opts = vl_argparse(opts, varargin) ;

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

imgDir = ['../SBMIDataset/' video '/input'];
labelDir = ['../SBMIDataset/' video '/groundtruth'];
imdb = getImdb(video,imgDir,labelDir);

imdb.half_size = 15;

%%%%%%Yi%%%%%% redefined the net
load('net');

net.layers{end-1} = struct('type', 'conv', ...
    'filters', 0.1*randn(1,1,64,1, 'single'), ...
    'biases', zeros(1, 1, 'single'), ...
    'stride', 1, ...
    'pad', 0) ;
net.layers{end} = struct('type', 'sigmoidcrossentropyloss');

load('meanPixel.mat');
imdb.meanPixel = meanPixel;
imdb.scales = scales;

[net,info] = cnn_train_adagrad_ms(net, imdb, @getBatch,...
    opts.train,'errorType','euclideanloss',...
    'conserveMemory', true);

end

function [im, labels] = getBatch(imdb, batch)
% --------------------------------------------------------------------

half_size = imdb.half_size;
meanPixel = imdb.meanPixel;

for ii = 1:numel(batch)
    
    imagename = imdb.images.name{batch(ii)};
    im_ii = single(imread(imagename));
    labelname = imdb.images.labels{batch(ii)};
    roi = imread(labelname);
    labels_ii = zeros(size(roi, 1), size(roi, 2));
    labels_ii( roi == 50 )  = 0.25;       %shade
    labels_ii( roi == 170 ) = 0.75;       %object boundary
    labels_ii( roi == 255 ) = 1;          %foreground
    
    % resize the image to half size
    if size(im_ii,1) > 400 || size(im_ii,2) >400
        im_ii = imresize(im_ii, 0.5, 'nearest');
        labels_ii = imresize(labels_ii, 0.5, 'nearest');
    end
    
    im(:,:,:,ii) = im_ii;
    labels(:,:,1,ii) = labels_ii;
end
end

function imdb = getImdb(video, imgDir, labelDir)

files = [dir([imgDir '/*.png']); dir([imgDir '/*.jpg'])];
label_files = dir([labelDir '/*.png']);
names = {};labels = {};

load(['../split/' video '.mat']);

for ii = 1:numel(train_index)
    names{end+1} = [imgDir '/' files(train_index(ii)).name];
    labels{end+1} = [labelDir '/' label_files(train_index(ii)).name];
end

im = imread(labels{1});
mask = ones(size(im,1),size(im,2));
if size(mask,1) > 400 || size(mask,2) >400
    mask = imresize(mask, 0.5, 'nearest');
end

imdb.mask = single(mask);

imdb.images.set = ones(1,numel(names));
imdb.images.name = names ;
imdb.images.labels = labels;
end