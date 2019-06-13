function plot_reject_curves(model,paths)
% PLOT_REJECT_CURVES Tests a (lib)SVM classifier from the specified images 
%                    paths whiel varies the threshold and performs
%                    test measures for each threshold.
%
% INPUT:
% model: SVMmodel to use
% paths: positive / negative images_path to test 
% //
% Test, window and descriptor params are read from the correspoding
% paramter files. If not found a window prompt for them.
%
%$ Author: Jose Marcos Rodriguez $    
%$ Date: 2013/11/09 $    
%$ Revision: 1.05 $

    % path stuff
    if nargin < 2
        positive_images_path = uigetdir('images','Select positive image folder');
        negative_images_path = uigetdir('images','Select negative image folder');
        
        if isa(positive_images_path,'double')  || ...
           isa(negative_images_path,'double')
            cprintf('Errors','Invalid paths...\nexiting...\n\n')
            return 
        end
        
    else
        positive_images_path = paths{1};
        negative_images_path = paths{2};
    end
    
    %% svm testing parameters
    get_test_params();
    
    %% getting images to test from the specified folders
    paths = {positive_images_path,negative_images_path};
    [positive_images, negative_images] = get_files(pos_instances,neg_instances, paths);

    
    
    
    % ====================================================================
    %% Reading all POSITIVE images & computing the descriptor 
    % (64x128 images)
    % ====================================================================

    %% Computing HOG descriptor for all images (in chunks)
    pos_probs = [];
    pos_start_time = tic;
    false_negatives = 0;
    true_positives = 0;

    i = 0;
    while i < numel(positive_images)
       
       %% window obtainment
       this_chunk = min(pos_chunk_size,numel(positive_images)-i);
       windows = uint8(zeros(height,width,depth,this_chunk));
       hogs = zeros(this_chunk, descriptor_size);
       labels = ones(size(hogs,1),1);
       for l=1:this_chunk
            I = imread(positive_images(i+1).name);
            windows(:,:,:,l) = get_window(I,width,height, 'center');
            hogs(l,:) = compute_HOG(windows(:,:,:,l),cell_size,block_size,n_bins);
            i = i+1;
       end
       
       % just for fixing GUI freezing due to unic thread MatLab issue
       drawnow; 

       %% prediction
       [predict_labels, ~, probs] = ...
            svmpredict(labels, hogs, model, '-b 1');
        
        pos_probs = [pos_probs; probs];

    end
    
    % hog extraction elapsed time
    pos_elapsed_time = toc(pos_start_time);
    fprintf('Elapsed time to classify positive images: %f seconds.\n',pos_elapsed_time);
    

    
    
    % ====================================================================
    %% Reading all NEGATIVE images & computing the descriptor 
    % Exhaustive search for hard examples
    % (space-scaled 64x128 windows)
    % ====================================================================
    
    num_neg_images = size(negative_images,1);
    fprintf('testing with %d negative images.\n', num_neg_images);
    

    %% Computing HOG descriptor for all images (in chunks)
    neg_probs = [];
    neg_start_time = tic;
    false_positives = 0;
    true_negatives = 0;

    i = 0;
    while i < numel(negative_images)
       
       %% window obtainment
       this_chunk = min(neg_chunk_size,num_neg_images-i);
       windows = uint8(zeros(height,width,depth,this_chunk));
       hogs = zeros(this_chunk, descriptor_size);
       labels = -1*ones(size(hogs,1),1);
       for l=1:this_chunk
            I = imread(negative_images(i+1).name);
            windows(:,:,:,l) = get_window(I,width,height, 'center');
            hogs(l,:) = compute_HOG(windows(:,:,:,l),cell_size,block_size,n_bins);
            i = i+1;
       end
       
       % just for fixing GUI freezing due to unic thread MatLab issue
       drawnow; 

       %% prediction
       [predict_labels, ~, probs] = ...
            svmpredict(labels, hogs, model, '-b 1');
        
        neg_probs = [neg_probs; probs];
    end
    
    % hog extraction elapsed time
    neg_elapsed_time = toc(neg_start_time);
    fprintf('Elapsed time to classify negative images: %f seconds.\n',neg_elapsed_time);


    % ====================================================================
    %% Varaying threshold to plot curves
    % ====================================================================
    fprintf('Varaying threshold to compute curves\n');
    
    th_range = 0.00:0.05:1;
    elems = numel(th_range);
    tp = zeros(1,elems);
    fn = zeros(1,elems);
    tn = zeros(1,elems);
    fp = zeros(1,elems);
    precision = zeros(1,elems);
    recall = zeros(1,elems);
    f_score = zeros(1,elems);

    % pos_probs
    % fprintf('-----------------------------------')
    % neg_probs
    % fprintf('-----------------------------------')
    % pause

    for indx=1:elems
        th = th_range(indx);

        % classifying pos instances
        for i=1:size(pos_probs,1)
            prob = pos_probs(i,1);
            if prob >= th
                tp(indx) = tp(indx) + 1;
            else
                fn(indx) = fn(indx) + 1;
            end
        end

        % classifying neg instances
        for i=1:size(neg_probs,1)
            prob = neg_probs(i,1);
            if prob < th
                tn(indx) = tn(indx) + 1;
            else
                fp(indx) = fp(indx) + 1;
            end
        end

        % measures computation
        precision(indx) = tp(indx) / (tp(indx) + fp(indx));
        recall(indx) = tp(indx) / (tp(indx) + fn(indx));
        f_score(indx) = 2*precision(indx)*recall(indx) / (precision(indx) + recall(indx));

        if th == 0.5
            fprintf('\nAt threshold = 0.5: \nprecision: %f \nrecall: %f, \nf-score: %d \n',precision(indx),recall(indx), f_score(indx));
        end
    end

    % tp = tp ./ size(pos_probs,1);
    % fp = fp ./ size(pos_probs,1);
    % tn = tn ./ size(neg_probs,1);
    % fn = fn ./ size(neg_probs,1);




    % ====================================================================
    %% Plots and measures
    % ====================================================================
    
    figure();
    title('Confusion matrix evolution as a function of the threshold (abs)');
    hold on;
    plot(th_range, tp, '-.g*');
    plot(th_range, fn, '-.r*');
    plot(th_range, tn, '--g');
    plot(th_range, fp, '--r');
    hold off;
    legend('true positives','false negatives','true negatives','false positives');


    figure();
    title('Confusion matrix evolution as a function of the threshold (rel)');
    hold on;
    plot(th_range, precision, '--r');
    plot(th_range, recall, '--g');
    plot(th_range, f_score, '--b');
    hold off;
    legend('precision','recall','fscore');
    

    opt_indx = find(f_score == max(f_score));
    opt_th = th_range(opt_indx);
    fprintf('\nOptimal threshold: %d \n\n', opt_th);

    precision = tp(opt_indx)/(tp(opt_indx)+fp(opt_indx));
    recall = tp(opt_indx)/(tp(opt_indx)+fn(opt_indx));
    fprintf('oks: %d \n',tp(opt_indx)+tn(opt_indx))
    fprintf('kos: %d \n',fp(opt_indx)+fn(opt_indx))
    fprintf('false positives: %d \n',fp(opt_indx))
    fprintf('false negatives: %d \n',fn(opt_indx))
    fprintf('true positives: %d \n',tp(opt_indx))
    fprintf('true negatives: %d \n',tn(opt_indx))
    fprintf('mis rate: %d \n',fn(opt_indx) / (tp(opt_indx) + fn(opt_indx)))
    fprintf('Precision: %d \n',precision)
    fprintf('Recall: %d \n',recall)
    fprintf('F score: %d \n',2*((precision*recall)/(precision+recall)))
    
    







    % ---------------------------------------------------------------------
    %% Aux function to obtain the test parameters
    % ---------------------------------------------------------------------
    function get_test_params()
        test_params = get_params('test_svm_params');
        pos_chunk_size = test_params.pos_chunk_size;
        neg_chunk_size = test_params.neg_chunk_size;
        scale = test_params.scale;
        stride = test_params.stride;
        threshold = test_params.threshold;
        neg_method = test_params.neg_window_method;
        safe = test_params.safe;
        neg_instances = test_params.neg_instances;
        pos_instances = test_params.pos_instances;

        w_params = get_params('window_params');
        depth = w_params.color_depth;
        width = w_params.width; 
        height = w_params.height;
        
        desc_params = get_params('desc_params');
        cell_size = desc_params.cell_size;
        block_size = desc_params.block_size;
        n_bins = desc_params.n_bins;
        desp = 1;
        n_v_cells = floor(height/cell_size);
        n_h_cells = floor(width/cell_size);
        hist_size = block_size*block_size*n_bins;
        descriptor_size = hist_size*(n_v_cells-block_size+desp)*(n_h_cells-block_size+desp);
        

        ok = 0;
        ko = 0; 
    end
    
end
     
