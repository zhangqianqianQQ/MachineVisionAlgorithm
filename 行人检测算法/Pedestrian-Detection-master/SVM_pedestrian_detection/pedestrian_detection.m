function pedestrian_detection(START_OVER, filename)
%% Set START_OVER to false to load existing model
%%  set to true to train new model, but only when you have the training data
%% Set filename to the name of image you want to perform pedestrian detection
%% Sample call:
%% pedestrian_detection(false, 'soccor.JPG');
%% all images are in 'testimgs' folder
%% image from USC Pedestrian Detection Test Set
%% http://iris.usc.edu/Vision-Users/OldUsers/bowu/DatasetWebpage/dataset.html

addpath('testimgs');
im = imread(filename);

sz1=76;
sz2=48;

if START_OVER
    model_svm = load_train_svm(sz1,sz2);
else
    load('model_svm.mat');
    sz1 = model_svm.sz1;
    sz2 = model_svm.sz2;
end

figure()
subplot(1,2,1);
[windows, lb_ub] = getped(im,sz1,sz2);
title('After segmentation')
for i = 1:length(windows)
    resized_img=windows{i};
    %     test_feature(i,:)=extractHOGFeatures(resized_img, 'CellSize', CellSize, 'BlockSize', BlockSize);
    test_feature(i,:)=extractHOGFeatures(resized_img);
end

fx = svm_predict(test_feature, model_svm);
%% -1 means pedestrian

pedestrians = find(fx == -1);
subplot(1,2,2)
imshow(im)
title('After SVM classification')
for i = 1 : length(pedestrians)
    %     figure()
    %     imshow(windows{pedestrians(i)});
    rectangle('Position', lb_ub(pedestrians(i),:), 'EdgeColor', 'g');
end
end

function [windows, lb_ub] = getped( im,sz1,sz2)
%top most function
imb = segment(im);
chop = chopp(imb,sz1,sz2);
cens = purge(chop);
%   windows = remark(im, cens, sz1, sz2 ,1, model, SVM_FLAG);
[windows, lb_ub] = remark(im, cens, sz1, sz2 ,1);
end

function [windows, lb_ub] = remark( im, cens, sz1, sz2, r)
%im -- colored img
%cordi -- window coordinates
windows = cell(1, size(cens, 1));
[h, w, ~] = size(im);
imshow(im)
hold on
plot(cens(:,1), cens(:,2), 'gd')
lb_ub = [];

for i = 1 : size(cens,1)
    ptx = cens(i, 1);
    pty = cens(i, 2);
    
    lb = max(ptx-(sz2/2)*r, 1);    %x cordinate
    ub = max(pty-(sz1/2)*r, 1);    %y cordinate
    %rectangle('Position', [lb ub 30 60], 'EdgeColor', 'g');
    lb_ub(i,1:4) = [lb ub sz2*r sz1*r];
    rectangle('Position', lb_ub(i,:), 'EdgeColor', 'g');
    
    rb = min(w, lb+sz2*r-1);
    db = min(h, ub+sz1*r-1);
    win = im(ub:db, lb:rb, :);
    if (~isempty(win))
        winx = imresize(win, [sz1, sz2]);
        windows{i} = winx;
    end
end
end