function model_svm = load_train_svm(sz1,sz2)
%The final model take size of 1*7524 as input, return 1 if positive, 2 if
%negative
close all
posim='.\cropped_pedestrian\images\pos\';
negim='.\cropped_pedestrian\images\neg\';
fprintf('start loading data\n')
pos_img_list=dir([posim,'*.jpg']);
neg_img_list=dir([negim,'*.jpg']);
for a=1:length(pos_img_list)
    fprintf('Loading positive image %d\n',a);
    temp=imresize(imread([posim pos_img_list(a).name]),[sz1 sz2]);
    [temp,~]=extractHOGFeatures(temp);
%     temp = hog_hiker(temp,0);
    temp = double(temp);
    temp = [temp(:)',2];
    posimg(a,:)=temp;
end
for a=1:length(neg_img_list)
    fprintf('Loading negative image %d\n',a);
    temp=imresize(imread([negim neg_img_list(a).name]),[sz1 sz2]);
    [temp,~]=extractHOGFeatures(temp);
%     temp = hog_hiker(temp,0);
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

model_svm = svm_train(500, false, train_data, sz1, sz2);
% save model to "model_svm.mat" at the same time
end

function model_svm = svm_train(num_of_train, TEST_FLAG, train_data, sz1, sz2)
% addpath('SavedData');
% load('proj_train_data_hog6633.mat');
X=train_data(:,1:(end-1));
y=train_data(:,end);
y(y==2)=-1;
rng(0);
tol=0.01;
grid_sigma = 2.^(0:5);
grid_C = 2.^(6:11);
K=zeros(num_of_train,num_of_train);
R=zeros(5,1);
Rcv=zeros(6,6);
y5=y(1:num_of_train);

%% Train
fprintf('Training SVM...\n')
fold_5 = floor(num_of_train/5);
for s=1:length(grid_sigma)
    for i=1:num_of_train
        for j=1:num_of_train
            K(i,j)=1/(1+(norm(X(i,:)-X(j,:)))^2/(grid_sigma(s))^2);
            if isnan(K(i,j))
                keyboard()
            end
        end
    end
    for C=1:length(grid_C)
        fprintf('s: %d, C:%d\n', s, C);
        for k=1:5
            Kk=K;
            Kk((1+(k-1)*fold_5):k*fold_5,:)=[];
            Kk(:,(1+(k-1)*fold_5):k*fold_5)=[];
            Kxxi=K((1+(k-1)*fold_5):k*fold_5,:);
            Kxxi(:,(1+(k-1)*fold_5):k*fold_5)=[];
            yk=y5;
            yk((1+(k-1)*fold_5):k*fold_5)=[];
            [alpha,bias] = smo(Kk, yk', grid_C(C), tol);
            for m=1:fold_5
                f(m,1)=sign((alpha.*Kxxi(m,:))*yk+bias);
            end
            R(k)=sum(abs(y((1+(k-1)*fold_5):k*fold_5)-f))/(2*fold_5);
        end
        Rcv(s,C)=mean(R);
    end
end

Rcv
[sn,Cn]=find(Rcv==min(Rcv(:)))
sigmax=grid_sigma(sn(1))
Cx=grid_C(Cn(1))
CVE_estimate=Rcv(sn(1),Cn(1))
X_train=X;
model_svm = struct('X_train', X_train(1:num_of_train, :), 'sigmax', sigmax,...
    'y5', y5, 'Cx', Cx, 'tol', tol, 'num_of_train', num_of_train, 'sz1', sz1, 'sz2', sz2);
save('model_svm.mat', 'model_svm');
%% Test
if TEST_FLAG
    all=size(y,1);
    assert(all>num_of_train);
    
    for i=1:all
        for j=1:num_of_train
            K(i,j)=1/(1+(norm(X(i,:)-X(j,:)))^2/(sigmax)^2);
        end
    end
    
    Kk=K(1:num_of_train,1:num_of_train);
    [alpha,bias] = smo(Kk, y5', Cx, tol);
    Kxxi=K((num_of_train+1):all,:);
    for m=1:(all-num_of_train)
        fx(m,1)=sign((alpha.*Kxxi(m,:))*y5+bias);
    end
    Test_err=sum(abs(y((num_of_train+1):all)-fx))/(2*(all-num_of_train))
    number_of_sv=nnz(alpha)
end
end