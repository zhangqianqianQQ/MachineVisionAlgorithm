clc;

if ~exist('trn_segment_saliency_data.mat', 'file')
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
    
    if ~exist(fullfile(work_dir, 'saliency'), 'dir')
        mkdir(fullfile(work_dir, 'saliency'));
    end
    
    load( './trained_classifiers/same_label_classifier_200_20_bdt.mat' );
    
    trn_sal_data_cell = cell(length(image_list), 1);
    trn_sal_lab_cell = cell(length(image_list), 1);
    
    NumImgs = length(image_list);
    for ix = 1 : NumImgs
        image_name = image_list{ix};
        mat_name = [image_name(1:end-4), '.mat'];

        image = imread(fullfile(imdir, [image_name(1:end-3) 'png']));
        gt = imread(fullfile(gt_dir, image_name));
        
        edata = load(fullfile(work_dir, 'same_label', mat_name), 'edgedata');
        sdata = load(fullfile(work_dir, 'imsegs', mat_name), 'imsegs');
        adata = load(fullfile(work_dir, 'adjlist', mat_name), 'adjlist');
        
        imsegs = sdata.imsegs;
        
        % generate supervised multiple segmentations
        same_label_likelihood = test_boosted_dt_mc( same_label_classifier, edata.edgedata );
        same_label_likelihood = 1 ./ (1+exp(ecal(1)*same_label_likelihood+ecal(2)));

        % generate multiple segmentations
        t = [5:5:35 40:10:120 150:30:600 660:60:1200 1300:100:1800];%0 : 20 : 1000;
        nSuperpixel = max( imsegs.segimage(:) );
        multi_segmentations = mexMergeAdjRegs_Felzenszwalb( adata.adjlist, same_label_likelihood, nSuperpixel, t, imsegs.npixels );
        nsegment = size(multi_segmentations, 2);
        
        sal_data_per_image_cell = cell(nsegment, 1);
        sal_lab_per_image_cell = cell(nsegment, 1);
        
        imdata = drfiGetImageData(image);
        pbgdata = drfiGetPbgFeat(imdata);
        
        for s = 1 : nsegment        
            spLabel = multi_segmentations(:, s);

            merged_imsegs = GetMergedImsegs( imsegs, spLabel );
            
            if merged_imsegs.nseg / sdata.imsegs.nseg > 0.5     % too fine
                continue;
            end
            
            spdata = drfiGetSuperpixelData(imdata, merged_imsegs);
            
            sal_data_one_scale = drfiGetRegionSaliencyFeature(merged_imsegs, spdata, imdata, pbgdata);
            sal_lab_one_scale = drfiGetSegmentSaliencyLabel(gt, merged_imsegs);
            
            assert(size(sal_data_one_scale, 1) == size(sal_lab_one_scale, 1));
            
            sal_data_per_image_cell{s} = sal_data_one_scale;
            sal_lab_per_image_cell{s} = sal_lab_one_scale;      
            
%             fprintf( '%d / %d, %d / %d\n', s, nsegment, ix, length(image_list) );
        end
        
        % cache
%         save(fullfile(work_dir, 'saliency', mat_name), 'sal_data_per_image_cell', 'sal_lab_per_image_cell' );
        
        sal_data = cell2mat(sal_data_per_image_cell);
        sal_lab = cell2mat(sal_lab_per_image_cell);
        
        trn_sal_data_cell{ix} = sal_data;
        trn_sal_lab_cell{ix} = sal_lab;
        
        fprintf( '%d / %d\n', ix, NumImgs);
    end

    trn_sal_data = cell2mat(trn_sal_data_cell);
    trn_sal_lab = cell2mat(trn_sal_lab_cell);
        
    ind = trn_sal_lab == 0;
    trn_sal_lab(ind) = [];
    trn_sal_data(ind, :) = [];
    
    ind = trn_sal_lab == -1;
    trn_sal_lab(ind) = 0;
    
    save('trn_segment_saliency_data.mat', 'trn_sal_data', 'trn_sal_lab');
else
    load('trn_segment_saliency_data.mat');
end

[trn_sal_data, trn_sal_lab] = balanceData(trn_sal_data, trn_sal_lab);

opt.importance = 0;
opt.do_trace = 1;

num_tree = 200;
mtry = 15;

model = regRF_train( trn_sal_data, trn_sal_lab, num_tree, 15, opt );
segment_saliency_regressor = compressRegModel(model);
% model = regRF_train( valid_feat, valid_lab, num_tree, mtry, opt );
% importance = model.importance;

save( './trained_classifiers/segment_saliency_regressor_200_15_rf.mat', 'segment_saliency_regressor', '-v7.3' );
% save( './trained_classifiers/importance.mat', 'model.importance' );