function [labels, train_matrix] = get_feature_matrix(positive_images, negative_images)
% GET_FEATURE_MATRIX computes the descriptor matrix for all input images 
% 
% OUTPUTS:
%       labels: column matrix with 1 in positives images and -1 in negatives
%       train_matrix: descriptor/feature matrix. 
%                       num. Rows = num. instances, 
%                       num. columns = feature dimension

%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 25-Dec-2013 21:26:49 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_feature_matrix.m 

    %% Init the svm training matrix
    desc_params = get_params('desc_params');
    cell_size = desc_params.cell_size;
    block_size = desc_params.block_size;
    n_bins = desc_params.n_bins;
    w_params = get_params('window_params');
    width = w_params.width;
    height = w_params.height;
    
    num_pos_images = numel(positive_images);
    num_neg_images = numel(negative_images);
    total_images = num_pos_images + num_neg_images;
    labels = zeros(total_images,1);

    desp = 1;
    n_v_cells = floor(height/cell_size);
    n_h_cells = floor(width/cell_size);
    hist_size = block_size*block_size*n_bins;
    descriptor_size = hist_size*(n_v_cells-block_size+desp)*(n_h_cells-block_size+desp);
    train_matrix = zeros(total_images,descriptor_size);


    
    % =====================================================================
    %% Reading all POSITIVE images & computing the descriptor 
    % (64x128 images)
    % =====================================================================
    pos_start_time = tic;
    for i=1:num_pos_images
       I = imread(positive_images(i).name);
       train_matrix(i,:) = compute_HOG(get_window(I,width,height,'center'),cell_size,block_size,n_bins);
       labels(i) = 1.0;
    end

    % (positive) hog extraction elapsed time
    pos_elapsed_time = toc(pos_start_time);
    fprintf('Elapsed time to extract positive image... HOG''s: %f seconds.\n',pos_elapsed_time);


    % =====================================================================
    %% Reading all NEGATIVE images & computing the descriptor 
    % (random 64x128 window)
    % =====================================================================
    neg_start_time = tic;
    index = num_pos_images;
    for i=1:num_neg_images
       I = imread(negative_images(i).name);
       index = index+1;
       train_matrix(index,:) = compute_HOG(get_window(I,width,height,'center'),cell_size,block_size,n_bins);
       labels(index) = -1.0;
   end

    % (negative) hog extraction elapsed time
    neg_elapsed_time = toc(neg_start_time);
    fprintf('Elapsed time to extract negative image HOG''s: %f seconds.\n',neg_elapsed_time);

    fprintf('Training matrix info:\n');
    whos('train_matrix')
    
