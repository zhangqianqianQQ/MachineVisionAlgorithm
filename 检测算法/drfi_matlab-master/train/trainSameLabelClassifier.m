clc;
% addpath(genpath('../'));

if ~exist('trn_same_label_data.mat', 'file')    
    % training folder
    base_dir = 'D:\LearningSaliency\Data';
    imdir = fullfile(base_dir, 'MSRA');
    % imdir = '../../Data/MSRA';
    %image_list = dir(fullfile(imdir, '*.jpg'));
    %image_list(201:end) = [];
    % image_list = fGetStrList('../../Data/train.txt');
    image_list = fGetStrList(fullfile(base_dir, 'train.txt'));
    % image_list = image_list(1:200); %randsample(length(image_list), 200)

    work_dir = '../../WorkingData/MSRA/';
    gt_dir = fullfile(base_dir, 'MSRA_gt');
    % gt_dir = '../../Data/MSRA';
    
    if ~exist(fullfile(work_dir, 'imsegs'), 'dir')
        mkdir(fullfile(work_dir, 'imsegs'));
    end
    
    if ~exist(fullfile(work_dir, 'same_label'), 'dir')
        mkdir(fullfile(work_dir, 'same_label'));
    end
    
    if ~exist(fullfile(work_dir, 'adjlist'), 'dir')
        mkdir(fullfile(work_dir, 'adjlist'));
    end
    
    NumImgs = length(image_list);
    
    trn_edata_cell = cell(NumImgs, 1);
    trn_elab_cell = cell(NumImgs, 1);
    imgData = cell(NumImgs, 1);    

    parfor ix = 1 : NumImgs
        image_name = image_list{ix};
        mat_name = [image_name(1:end-4), '.mat'];

        image = imread(fullfile(imdir, [image_name(1:end-3) 'png']));
        gt = imread(fullfile(gt_dir, image_name));

        % computing features
        imsegs = im2superpixels(image, 'pedro');
        imdata = drfiGetImageData(image);
        spdata = drfiGetSuperpixelData(imdata, imsegs);
        pbgdata = drfiGetPbgFeat(imdata);
        [edgedata, imdata] = drfiGetSameLabelFeat(imsegs, spdata, pbgdata, imdata);
        edgelab = drfiGetSuperpixelIsSameLabel(gt, imdata);
        adjlist = imdata.adjlist;

        trn_edata_cell{ix} = edgedata;
        trn_elab_cell{ix} = edgelab;

        imgData{ix}.mat_name = mat_name;
        imgData{ix}.imsegs = imsegs;
        imgData{ix}.edgedata = edgedata;
        imgData{ix}.edgelab = edgelab;
        imgData{ix}.adjlist = adjlist;
        
        fprintf( '%d / %d\n', ix, NumImgs);
    end
    
    % cache
    for ix = 1:NumImgs        
        mat_name = imgData{ix}.mat_name;
        imsegs = imgData{ix}.imsegs;
        edgedata = imgData{ix}.edgedata;
        edgelab = imgData{ix}.edgelab;
        adjlist = imgData{ix}.adjlist;
        save(fullfile(work_dir, 'imsegs', mat_name), 'imsegs');
        save(fullfile(work_dir, 'same_label', mat_name), 'edgedata', 'edgelab');
        save(fullfile(work_dir, 'adjlist', mat_name), 'adjlist');        
    end    
    

    % train the same label classifier
    trn_edata = cell2mat(trn_edata_cell);
    trn_elab = cell2mat(trn_elab_cell);
    
    save( 'trn_same_label_data.mat', 'trn_edata', 'trn_elab' );
else
    load( 'trn_same_label_data.mat' );
end

[trn_edata, trn_elab] = randomize(trn_edata, trn_elab);

ind = ceil(length(trn_elab) * 0.8);
val_edata = trn_edata(ind : end, :);
val_elab = trn_elab(ind : end);
trn_edata(ind : end, :) = [];
trn_elab(ind : end) = [];


clf_type = 'bdt';
if ~exist('trained_classifiers', 'dir')
    mkdir('trained_classifiers');
end

if strcmp(clf_type, 'bdt')
    same_label_classifier = train_boosted_dt_2c(trn_edata, [], trn_elab, 200, 20);
    
    % calibration
    ecal = calibrateBdtClassifier(val_edata, same_label_classifier, val_elab, 1);
    ecal = ecal{1};
    
    save( './trained_classifiers/same_label_classifier_200_20_bdt.mat', 'same_label_classifier', 'ecal' );
elseif strcmp(clf_type, 'rf')
    opt.importance = 1;
    regressor = regRF_train( feat, lab, 200, 12, opt );
    same_label_classifier = compressRegModel( regressor );
    save( './trained_classifiers/same_label_clf_200_12_rf.mat', 'same_label_classifier' );
else
    error( 'Not supported classifier.' );
end

