clc;

if ~exist('./trained_classifiers/seg_para.mat', 'file')
    sigma = [0.8 : 0.1 : 1.0];
    k = [200, 300, 500];
    min_size = [150 200 300];
    
    [ss kk] = meshgrid( sigma, k );
    seg_para = zeros( length(sigma) * length(k) * length(min_size), 3 );
    
    ind = 1;
    for ix = 1 : length(ss(:))
        for jx = 1 : length(min_size)
            seg_para(ind, :) = [ss(ix) kk(ix) min_size(jx)];
            ind = ind + 1;
        end
    end 
    
    save( './trained_classifiers/seg_para.mat', 'seg_para' );
end

load( './trained_classifiers/seg_para.mat', 'seg_para' );

if ~exist('./trained_classifiers/fusion_weight.mat', 'file')
    % training folder
    base_dir = 'D:\LearningSaliency\Data';
    imdir = fullfile(base_dir, 'MSRA');
    % imdir = '../../Data/MSRA';
    %image_list = dir(fullfile(imdir, '*.jpg'));
    %image_list(201:end) = [];
    % image_list = fGetStrList('../../Data/train.txt');
    image_list = fGetStrList(fullfile(base_dir, 'train.txt'));
    % image_list = image_list(1:50); %randsample(length(image_list), 200)

    work_dir = '../../WorkingData/MSRA/';
    gt_dir = fullfile(base_dir, 'MSRA_gt');
    % gt_dir = '../../Data/MSRA';
    trn_dir = fullfile(work_dir, 'fusion');
    
    if ~exist(trn_dir, 'dir')
        mkdir(trn_dir);
    end
    
    regressor = load( 'trained_classifiers\segment_saliency_regressor_200_15_rf.mat' );
    segment_saliency_regessor = regressor.segment_saliency_regressor;
    
    for s = 1 : size(seg_para, 1)    
        sigma = seg_para(s, 1);
        k = seg_para(s, 2);
        min_size = seg_para(s, 3);
        
        if ~exist(fullfile(trn_dir, num2str(s)), 'dir')
            mkdir(fullfile(trn_dir, num2str(s)));
        end
        
        for ix = 1 : length(image_list)
            image_name = image_list{ix};
            image_name = [image_name(1:end-3), 'png'];
            image = imread(fullfile(imdir, image_name));
            
            smap = drfiGetSaliencyMapSingleLevel(image, segment_saliency_regessor, sigma, k, min_size);
            
            imwrite(smap, fullfile(trn_dir, num2str(s), image_name));
        end
        
        fprintf( 'segmentation: %d / %d\n', s, size(seg_para, 1) );
    end
    
    w = drfiLearnSaliencyFusionWeight(trn_dir, gt_dir, size(seg_para, 1), true);
    save( './trained_classifiers/fusiong_weight.mat', 'w' );
end