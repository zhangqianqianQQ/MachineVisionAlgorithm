function plot_DETcurve(models, model_names,pos_path, neg_path)
% PLOT_DETCURVE function to compute de DET plot given a set of models
%
% INPUT:
% models: SVM models to test (as a row vector)
% model_names: names of the models to use it in the DET_plot legends 
%              (as cell array)
% pos/neg path: path to pos/neg images
% 
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 09-Nov-2013 22:45:23 $ 
%$ Revision : 1.04 $ 
%% FILENAME  : performance.m 

    % if paths not specified by parameters
    if nargin < 3
        pos_path = uigetdir('.\images','Select positive test image path');
        neg_path = uigetdir('.\images','Select negative test image path');

        if isa(neg_path,'double') || isa(pos_path,'double')
            cprintf('Errors','Invalid paths...\nexiting...\n\n')
            return 
        end
    end

    det_figure_handler = figure('name','DET curves');
    set(det_figure_handler,'Visible','off');
    
    det_plot_handlers = zeros(1,max(size(models)));
    
    color = ['b','r','g','y'];
    
    for m_index=1:max(size(models))
        hold on;
        model = models(m_index);
        
        % getting classification scores
        [p_scores, n_scores] = get_scores(model,pos_path,neg_path);

        % Plot scores distribution as a Histogram
        positives = max(size(p_scores));
        negatives = max(size(n_scores)); 
        scores = zeros(min(positives, negatives),2);
        for i=1:size(scores)
            scores(i,1) = p_scores(i);
            scores(i,2) = n_scores(i);
        end
        figure('name', sprintf('model %s scores distribution',model_names{m_index})); hist(scores);

        % Compute Pmiss and Pfa from experimental detection output scores
        [P_miss,P_fppw] = Compute_DET(p_scores,n_scores);

        % Plot the detection error trade-off
        figure(det_figure_handler);
        thick = 2;
        det_plot_handler = Plot_DET(P_miss,P_fppw,color(m_index)', thick);
        det_plot_handlers(m_index) = det_plot_handler;

        % Plot the optimum point for the detector
        C_miss = 1;
        C_fppw = 1;
        P_target = 0.5;

        Set_DCF(C_miss,C_fppw,P_target);
        [DCF_opt, Popt_miss, Popt_fa] = Min_DCF(P_miss,P_fppw);
        fprintf('Optimal Decision Cost Function for %s = %d\n',model_names{m_index},DCF_opt)

        Plot_DET (Popt_miss,Popt_fa,'ko');
    end
    legend(det_plot_handlers, model_names);
end




function [p_scores, n_scores] = get_scores(model,pos_path, neg_path)
    % Tests a (lib)SVM classifier from the specified images paths
    %
    % ok: number of correct classifications
    % ko: number of wrong classifications
    % positive / negative images_path: paths of the images to test
    % model: SVMmodel to use.
    %
    %$ Author: Jose Marcos Rodriguez $    
    %$ Date: 2013/11/09 $    
    %$ Revision: 1.2 $

    [positive_images, negative_images] = get_files(-1,-1,{pos_path,neg_path});
    total_pos_windows = numel(positive_images);
    total_neg_windows = numel(negative_images);
    
    
    %% Init the svm test variables
    params = get_params('det_plot_params');
    chunk_size = params.chunk_size;
    desc_size = params.desc_size;
    params = get_params('window_params');
    im_h_size = params.height;
    im_w_size = params.width;
    im_c_depth = params.color_depth;
    
    % ====================================================================
    %% Reading all POSITIVE images 
    % (64x128 images)
    % ==================================================================== 
    
    % SVM scores
    p_scores = zeros(total_pos_windows,1);
  
    i = 0;
    while i < numel(positive_images)
    
    %% window obtainment
       this_chunk = min(chunk_size,numel(positive_images)-i);
       windows = uint8(zeros(im_h_size,im_w_size,im_c_depth,this_chunk));
       hogs = zeros(this_chunk, desc_size);
       labels = ones(size(hogs,1),1);
       for l=1:this_chunk
            I = imread(positive_images(i+1).name);
            windows(:,:,:,l) = get_window(I,im_w_size,im_h_size,'center');
            hogs(l,:) = compute_HOG(windows(:,:,:,l),8,2,9);
            i = i+1;
       end
       
       % just for fixing GUI freezing due to unic thread MatLab issue
       drawnow; 

       %% prediction
       [~, ~, scores] = ...
            svmpredict(labels, hogs, model, '-b 0');
        
        p_scores(i-this_chunk+1:i,:) = scores(:,:); 
    
    end
    
    % ====================================================================
    %% Reading all NEGATIVE images 
    % (64x128 windows)
    % ====================================================================

    n_scores = zeros(total_neg_windows,1);
    
    i = 0;
    while i < numel(negative_images)
    
    %% window obtainment
       this_chunk = min(chunk_size,numel(negative_images)-i);
       windows = uint8(zeros(im_h_size,im_w_size,im_c_depth,this_chunk));
       hogs = zeros(this_chunk, desc_size);
       labels = ones(size(hogs,1),1)*(-1);
       for l=1:this_chunk
            I = imread(negative_images(i+1).name);
            windows(:,:,:,l) = get_window(I,im_w_size,im_h_size,[1,1]);
            hogs(l,:) = compute_HOG(windows(:,:,:,l),8,2,9);
            i = i+1;
       end
       
       % just for fixing GUI freezing due to unic thread MatLab issue
       drawnow; 

       %% prediction
       [~, ~, scores] = ...
            svmpredict(labels, hogs, model, '-b 0');
        
        n_scores(i-this_chunk+1:i,:) = scores(:,:); 
    
    
    end
end

