
clear all
close all
clc
% number of classes
k = 16;
%----- Demo parameters  (fore more details see [1]) ----------------------
% number of Monte Carlo runs
MCruns = 10;
%--------------------------------------------------------------------------

%----- LORSAL Algorithm parameters ----------------------------------------
% sparsity parameter
lambda = 0.001;
% LORSAL parameter
beta = 0.0001;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% total initial training sample
n_train = 1043;
% number of initial traing samples per class
train_perclass = floor(n_train/k);
% monte carlo runs
MMiter = MCruns;

% ground truth image
load AVIRIS_Indiana_16class
% AVIRIS Indian Pines data set
load imgreal;
im = img;
sz = size(im);
clear img;


im = ToVector(im);
im = im';
im([104:108 150:163 220],:) =[];
sz(3) = size(im,1);
%nomalize the image
im = im./repmat(sqrt(sum(im.^2)),sz(3),1);
trainall = trainall';
%classification accuracy
LORSAL_classification_CA=[];
SMLR_SpTV_CA = [];
% start Monte Carlo runs
fprintf('\nStarting Monte Carlo runs \n\n');
%traning samples chosen type
%Choose_Type = 'Random';
Choose_Type = 'Fixed';
for iter = 1:MMiter
    fprintf('MC run %d \n', iter);
    tStart = tic;
    % randomly select the initial training set from the ground truth image
    switch Choose_Type
        case 'Random'
            indexes = train_test_random_new(trainall(2,:),train_perclass,n_train);
        case 'Fixed'
            indexes = train_test_random_newvector(trainall(2,:),[6 144 84 24 50 75 3 49 2 97 247 62 22 130 38 10]);
    end
    train1 = trainall(:,indexes);
    test1 = trainall;
    test1(:,indexes) = [];
    
    
    train = im(:,train1(1,:));
    test = im(:,test1(1,:));
    y = train1(2,:);
    % reindex to natural indeces
    x = train;
    % space dimension
    sigma = 0.8;
    [d,n] =size(x);
    % build |x_i-x_j| matrix
    nx = sum(x.^2);
    [X,Y] = meshgrid(nx);
    dist=X+Y-2*x'*x;
    scale = mean(dist(:));
    % build design matrix (kernel)
    K=exp(-dist/2/scale/sigma^2);
    % set first line to one
    K = [ones(1,n); K];
    % learn the regressors
    [w,L] = LORSAL(K,y,lambda,beta);
    p = splitimage2(im,x,w,scale,sigma);
    t_LORSAL(iter) = toc(tStart);
    % constrained least squares l2-TV (nonisotropic)
    lambda_TV = 2;
    Traning_logic_matrix = zeros(k,n_train);
    for i = 1:n_train
        Traning_logic_matrix(y(i),i)=1;
    end
    Training_Info.Traning_logic_matrix=Traning_logic_matrix;
    Training_Info.index = train1(1,:);
    [p_tv,res] = SAL_SpTV_new(p,Training_Info,'MU',0.05,...
        'LAMBDA_TV', lambda_TV, 'TV_TYPE','niso',...
        'IM_SIZE',[145,145],'AL_ITERS',200,  'VERBOSE','no');
    t_SpATV(iter) = toc(tStart);
    tStart2 = tic;
    %% classification results
    %-------------------------------------------
    %LORSAL classification
    [maxp,class] = max(p);
    %SMLR_SpTV classification
    [maxp,class1] = max(p_tv);
    %%%-- LORSAL classification accuracy
    OA_LORSAL_AL(iter)     =  sum(class(test1(1,:))==test1(2,:))/length(test1(2,:))
    [a.OA,a.kappa,a.AA,a.CA] = calcError( test1(2,:)-1, class(test1(1,:))-1, 1: k);
    LORSAL_classification_OA(iter) = a.OA;
    LORSAL_classification_AA(iter) = a.AA;
    LORSAL_classification_kappa(iter) = a.kappa;
    LORSAL_classification_CA = [LORSAL_classification_CA a.CA];
    % SMLR_SpTV classification accuracy
    OA_SMLR_SpTV(iter) = sum(class1(test1(1,:))==test1(2,:))/length(test1(2,:))
    [a.OA,a.kappa,a.AA,a.CA] = calcError( test1(2,:)-1, class1(test1(1,:))-1, 1: k);
    SMLR_SpTV_OA(iter)=a.OA;
    SMLR_SpTV_AA(iter)=a.AA;
    SMLR_SpTV_kappa(iter)=a.kappa;
    SMLR_SpTV_CA = [SMLR_SpTV_CA a.CA];
end
%%-----------------------------------------------------------------------%
% evaluation of the algorithm performance
%-------------------------------------------------------------------------%
% compute the mean OAs over MMiter MC runs
mean_classification_OA = mean(LORSAL_classification_OA.*100)
STD_classification_OA = std(LORSAL_classification_OA.*100)
mean_classification_AA = mean(LORSAL_classification_AA.*100)
STD_classification_AA = std(LORSAL_classification_AA.*100)
mean_classification_kappa = mean(LORSAL_classification_kappa)
STD_classification_kappa = std(LORSAL_classification_kappa)
mean_classification_CA = mean(LORSAL_classification_CA,2);


mean_classification_TV_OA = mean(SMLR_SpTV_OA.*100)
STD_classification_TV_OA = std(SMLR_SpTV_OA.*100)
mean_classification_TV_AA = mean(SMLR_SpTV_AA.*100)
STD_classification_TV_AA = std(SMLR_SpTV_AA.*100)
mean_classification_TV_kappa = mean(SMLR_SpTV_kappa)
STD_classification_TV_kappa = std(SMLR_SpTV_kappa)
mean_classification_TV_CA = mean(SMLR_SpTV_CA,2)

%% show the results in graphics
showfigure = 0;
if showfigure
    %--------------------------figure 1 :groundtruth----------------------
    figure;
    true_im = zeros(sz(1),sz(2));
    true_im(trainall(1,:)) = trainall(2,:);
    imshow(true_im',[],'border','tight','InitialMagnification','fit')
    set (gcf,'Position',[700,700,350,350])
    colormap('default');
    axis image;
    axis off;
    %-----------------------figure 2: LORSAL classification----------
    figure
    class_im = zeros(sz(1),sz(2));
    class_im(trainall(1,:)) = class(trainall(1,:));
    imshow(class_im',[],'border','tight','InitialMagnification','fit')
    set (gcf,'Position',[700,700,350,350])
    colormap('default');
    axis image;
    axis off;
    fprintf('Figure 2: the OA of LORSAL classification is %4.2f%%\n',mean_classification_OA(end));
    %------------------figure 3: SMLR_SpTV segmentation---------
    figure;
    seg_TV = zeros(sz(1),sz(2));
    seg_TV(trainall(1,:)) = class1(trainall(1,:));
    imshow(seg_TV',[],'border','tight','InitialMagnification','fit')
    set (gcf,'Position',[700,700,350,350])
    colormap('default');
    axis image;
    axis off;
    fprintf('Figure 3: the OA of SMLR_SpTV segmentation is %4.2f%%\n',mean_classification_TV_OA(end));
end