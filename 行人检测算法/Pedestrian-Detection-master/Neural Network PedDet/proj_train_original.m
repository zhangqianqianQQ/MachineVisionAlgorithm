function [model] = proj_train_original(sz1,sz2,loss_thresh)
%The final model take size of 1*7524 as input, return 1 if positive, 2 if
%negative
close all
posim='.\cropped_pedestrian\images\pos\';
negim='.\cropped_pedestrian\images\neg\';
fprintf('start loading data\n')
pos_img_list=dir([posim,'*.jpg']);
neg_img_list=dir([negim,'*.jpg']);
for a=1:length(pos_img_list)
    temp=imresize(imread([posim pos_img_list(a).name]),[sz1 sz2]);
    [temp,~]=extractHOGFeatures(temp);
    %temp = hog_hiker(temp,0);
    temp = double(temp);
    temp = [temp(:)',2];
    posimg(a,:)=temp;
end
for a=1:length(neg_img_list)
    temp=imresize(imread([negim neg_img_list(a).name]),[sz1 sz2]);
    [temp,~]=extractHOGFeatures(temp);
    %temp = hog_hiker(temp,0);
    temp = double(temp);
    temp = [temp(:)',1];
    negimg(a,:)=temp; 
end

batch_idx_1=randperm(length(neg_img_list),300);
batch_idx_2=randperm(length(pos_img_list),300);
test_data_temp=cat(1,negimg(batch_idx_1,:),posimg(batch_idx_2,:));
%random change the order
test_idx=randperm(600,600);
test_data=test_data_temp(test_idx,:);
batch_idx_1=randperm(length(neg_img_list),500);
batch_idx_2=randperm(length(pos_img_list),1500);
train_data_temp=cat(1,negimg(batch_idx_1,:),posimg(batch_idx_2,:));
%random change the order
train_idx=randperm(2000,2000);
train_data=train_data_temp(train_idx,:);

fprintf('loading data end.\n')
save proj_test_data 'test_data'
save proj_train_data 'train_data'
fprintf('save data end, named as "proj_test_data" and "proj_train_data"\n')
%the test_data is n*7525(including the last column as label, positive is 1, negative is 2)
%test_data=cat(1,test_data,train_data);
train_label=train_data(:,end);
train_data(:,end)=[];
test_label=test_data(:,end);
test_data(:,end)=[];
a=zeros([size(train_data,2) 1 1 size(train_data,1)]);
b=zeros([size(test_data,2) 1 1 size(test_data,1)]);
for i=1:size(train_data,1)
    a(:,:,:,i)=train_data(i,:)';
end
for i=1:size(test_data,1)
    b(:,:,:,i)=test_data(i,:)';
end
train_data=a;
test_data=b;
%% train the network
lr=0.005;%try different 
wd=0.0005;
bs=200;
save_file='proj_model.mat';
addpath layers
params = struct('learning_rate',lr,'weight_decay',wd,...
                'batch_size',bs,'save_file',save_file);
%% construct neural netword
num_labels = 2;
stride = 2;
sz=size(train_data);
layers = [
        init_layer('flatten',struct('num_dims',4))
        init_layer('linear',struct('num_in',sz(1),'num_out',2))
        %init_layer('flatten',struct('num_dims',2))
        %init_layer('linear',struct('num_in',50,'num_out',20))
        %init_layer('flatten',struct('num_dims',2))
        %init_layer('linear',struct('num_in',20,'num_out',2))
        init_layer('softmax',[])];
%% train and compute test accuracy 
model=init_model(layers,[sz(1),sz(2),sz(3)],num_labels,true);
tic
[model, loss, accuracy,test_loss, test_accuracy ] = train(model,train_data,train_label,params,loss_thresh);
toc
fprintf('model saved as "proj_model"\n')
%% The final model take size of 1*7524 as input, return 1 if positive, 2 if
% negative
[output,~]=inference(model,test_data);
[~,result]=max(output,[],1);
result=result(:);
finalaccuracy=sum(result==test_label)/length(test_label);
fprintf('our final test accuracy is %f !!!\n',finalaccuracy);