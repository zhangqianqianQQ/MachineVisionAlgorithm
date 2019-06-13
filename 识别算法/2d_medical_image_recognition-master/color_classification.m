
setup ;
close all;
% -------------------------------------------------------------------------
% Prepare the data
% -------------------------------------------------------------------------
imdb = my_extract_patches_color(100, 0.8);

% Take the average image out
imageMean = mean(imdb.images.data(:)) ;
imdb.images.data = imdb.images.data - imageMean ;

% -------------------------------------------------------------------------
% Visualize some of the data
% -------------------------------------------------------------------------

figure('Name','Epithelial patches') ; clf ; colormap gray ;
subplot(1,2,1) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==1 & imdb.images.set==1));
axis image off ;
title('training patches for ''epithelial''');
subplot(1,2,2) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==1 & imdb.images.set==2));
axis image off ;
title('validation patches for ''epithelial''');

figure('Name','Fibroblast patches') ; clf ; colormap gray ;
subplot(1,2,1) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==2 & imdb.images.set==1));
axis image off ;
title('training patches for ''fibroblast''');
subplot(1,2,2) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==2 & imdb.images.set==2));
axis image off ;
title('validation patches for ''fibroblast''');

figure('Name','Inflammatory patches') ; clf ; colormap gray ;
subplot(1,2,1) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==3 & imdb.images.set==1));
axis image off ;
title('training patches for ''inflammatory''');
subplot(1,2,2) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==3 & imdb.images.set==2));
axis image off ;
title('validation patches for ''inflammatory''');

figure('Name','Others patches') ; clf ; colormap gray ;
subplot(1,2,1) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==4 & imdb.images.set==1));
axis image off ;
title('training patches for ''others''');
subplot(1,2,2) ;
vl_imarraysc(imdb.images.data(:,:, :, imdb.images.label==4 & imdb.images.set==2));
axis image off ;
title('validation patches for ''others''');

% -------------------------------------------------------------------------
% Initialize a CNN architecture
% -------------------------------------------------------------------------

net = color_my_initialize_CNN() ;

% -------------------------------------------------------------------------
% Train and evaluate the CNN
% -------------------------------------------------------------------------

trainOpts.batchSize = 100 ;
trainOpts.numEpochs = 15 ;
trainOpts.continue = true ;
trainOpts.gpus = [] ;
trainOpts.learningRate = 0.001 ;
trainOpts.expDir = 'data/color-classification-experiment/' ;

% Call training function in MatConvNet
[net,info] = cnn_train(net, imdb, @getBatch, trainOpts) ;

% Save the result for later use
net.layers(end) = [] ;
net.imageMean = imageMean ;
save('data/color-classification-experiment/cnn.mat', '-struct', 'net') ;

% -------------------------------------------------------------------------
% Visualize the learned filters
% -------------------------------------------------------------------------
figure(2) ; clf ; colormap gray ;
vl_imarraysc(squeeze(net.layers{1}.weights{1}),'spacing',2)
axis equal ; title('filters in the first layer') ;

% -------------------------------------------------------------------------
% Apply the model
% -------------------------------------------------------------------------
% 
% Load the CNN learned before
net = load('data/color-classification-experiment/cnn.mat') ;

im = imdb.images.data(:,:,:, imdb.images.label==4);
im = im(:, :, :, 500);

res = vl_simplenn(net, im) ;

imagesc(squeeze(res(end).x)') ;


% -------------------------------------------------------------------------
% Calculate F1 score
% -------------------------------------------------------------------------
tp = zeros(1, 4);
total_true = zeros(1, 4);
total_predicted = zeros(1, 4);

for i=1:4
    total_true(1,i) = sum(imdb.images.label==i);
end

im = imdb.images.data(:,:, :, :);
amount_image = size(imdb.images.id, 2);
for i=1:amount_image
    res = vl_simplenn(net, im(:, :, :, i));
    [~,curr_label] = max(squeeze(res(end).x));
    if curr_label == imdb.images.label(1, i)
        tp(1, imdb.images.label(1, i)) = tp(1, imdb.images.label(1, i)) +1;
    end
    total_predicted(1, curr_label) = total_predicted(1, curr_label) + 1;
end

recall = tp./total_predicted;
precision = tp./total_true;

recall_avg = mean(recall);
precision_avg = mean(precision);

f1_score = 2*((precision_avg * recall_avg)/(precision_avg + recall_avg));
% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
% --------------------------------------------------------------------
im = imdb.images.data(:,:, :, batch) ;
labels = imdb.images.label(1,batch) ;
end




