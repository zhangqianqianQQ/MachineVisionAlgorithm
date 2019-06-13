function statistics = test_svm(model,paths)
% TEST_SVM Tests a (lib)SVM classifier from the specified images paths
%
% INPUT:
% model: SVMmodel to use
% threshold: positive confidence threshold 
% paths: positive / negative images_path to test
% //
% windows, descriptor and test parameter configuration is read from their
% corresponding paramteter files. If not found a window prompts for them.
%
% OUTPUT:
% statistics: ok, ko, false_pos, false_neg, true_pos, true_neg
%             fppw and miss_rate metrics
%
%$ Author: Jose Marcos Rodriguez $    
%$ Date: 2013/11/09 $    
%$ Revision: 1.05 $

    %% svm testing parameters
    get_test_params();

    % path stuff
    if nargin < 2
        positive_images_path = uigetdir('images','Select positive image folder');
        negative_images_path = uigetdir('images','Select negative image folder');
        if safe
          images_path = uigetdir('images','Select base image path');
        end

        if isa(positive_images_path,'double')  || ...
           isa(negative_images_path,'double')
            cprintf('Errors','Invalid paths...\nexiting...\n\n')
            return 
        end
        
    else
        positive_images_path = paths{1};
        negative_images_path = paths{2};
        if safe
          images_path = paths{3};
        end
    end
  
    
    %% getting images to test from the specified folders
    paths = {positive_images_path,negative_images_path};
    [positive_images, negative_images] = get_files(pos_instances,neg_instances, paths);

    
    
    
    % ====================================================================
    %% Reading all POSITIVE images & computing the descriptor 
    % (64x128 images)
    % ====================================================================

    %% Computing HOG descriptor for all images (in chunks)
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
        
        %% counting and copying
        for l=1:size(predict_labels)
            predict_label = predict_labels(l);
            
            if probs(l,1) >= 0.1
                ok = ok + 1;
                true_positives = true_positives + 1;
            else
                ko = ko + 1;
                false_negatives = false_negatives + 1;

                % saving hard image for further retrain
                if safe
                    [~, name, ext] = fileparts(positive_images(i).name);
                    saving_path = [images_path,'/hard_examples/false_neg/',...
                                   name,...
                                   '_n_wind_',num2str(l), ext];
                               
                   % writting image 
                   imwrite(windows(:,:,:,l), saving_path); 
               end
            end  
        end
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
    if strcmp(neg_method, 'pyramid')
        num_neg_windows = ...
            get_negative_windows_count(negative_images);
    elseif strcmp(neg_method, 'windows')
        num_neg_windows = num_neg_images*neg_chunk_size;
    end
    fprintf('testing with %d negative images and %d negative windows\n', num_neg_images,num_neg_windows);
    

    %% Computing HOG descriptor for all images (in chunks)
    neg_start_time = tic;
    false_positives = 0;
    true_negatives = 0;

    i = 0;
    while i < numel(negative_images)
       
       %% window obtaintion
       % All pyramid HOGS
       if strcmp(neg_method, 'pyramid')
            I = imread(negative_images(i+1).name);
            
            %% temporal
            [h,w,~] = size(I);
            if max(h,w) >= 160
               ratio = max(96/w,160/h);
               I = imresize(I,ratio); 
            end
            %% fin temporal
            [hogs, windows, wxl] = get_pyramid_hogs(I, descriptor_size, scale, stride);
            labels = ones(size(hogs,1),1).*(-1);
            i = i+1;
           
       % random window HOG
       elseif strcmp(neg_method,'windows')
           this_chunk = min(neg_chunk_size, numel(negative_images)-i);
           windows = uint8(zeros(height,width,depth,this_chunk));
           hogs = zeros(this_chunk, descriptor_size);
           labels = ones(size(hogs,1),1).*(-1);
           
           for l=1:this_chunk
                I = imread(negative_images(i+1).name);
                windows(:,:,:,l) = get_window(I,width,height, 'center');
                hogs(l,:) = compute_HOG(windows(:,:,:,l),cell_size,block_size,n_bins);
                i = i+1;
           end
       end
       
       % just for fixing GUI freezing due to unic thread MatLab issue
       drawnow; 
       
       %% prediction
       [predict_labels, ~, probs] = ...
            svmpredict(labels, hogs, model, '-b 1');

       %% updating statistics
       for l=1:size(predict_labels)
           predict_label = predict_labels(l);
		   
           if probs(l,1) < 0.1
               ok = ok + 1;
               true_negatives = true_negatives + 1;
           else
               ko = ko + 1;
               false_positives = false_positives + 1;

               if safe
                   % saving hard image for further retrain
                   [~, name, ext] = fileparts(negative_images(i).name);

                   if strcmp(neg_method, 'pyramid')
                       [level, num_image] = get_window_indices(wxl, l);
                       saving_path = [images_path,'/hard_examples/false_pos/',...
                                      name,...
                                      '_l',num2str(level),...
                                      '_w',num2str(num_image),ext];
                   else
                        saving_path = [images_path,'/hard_examples/false_pos/',...
                                       name,...
                                       '_n_wind_',num2str(l), ext];
                   end
                  % writting image 
                  imwrite(windows(:,:,:,l), saving_path); 
               end
           end  
       end
    end
    
    % hog extraction elapsed time
    neg_elapsed_time = toc(neg_start_time);
    fprintf('Elapsed time to classify negative images: %f seconds.\n',neg_elapsed_time);
    
    

    %% Printing gloabl results
    precision = true_positives/(true_positives+false_positives);
    recall = true_positives/(true_positives+false_negatives);
    
    fprintf('oks: %d \n',ok)
    fprintf('kos: %d \n',ko)
    fprintf('false positives: %d \n',false_positives)
    fprintf('false negatives: %d \n',false_negatives)
    fprintf('true positives: %d \n',true_positives)
    fprintf('true negatives: %d \n',true_negatives)
    fprintf('mis rate: %d \n',false_negatives / (true_positives + false_negatives))
    fprintf('fppw: %d \n',false_positives / (ok + ko))
    fprintf('Precision: %d \n',precision)
    fprintf('Recall: %d \n',recall)
    fprintf('F score: %d \n',2*((precision*recall)/(precision+recall)))
    
    % preparing values to return
    statistics = containers.Map;
    statistics('oks') = ok;
    statistics('kos') = ok;
    statistics('fp') = false_positives;
    statistics('tp') = true_positives;
    statistics('fn') = false_negatives;
    statistics('tn') = true_negatives;
    statistics('miss_rate') = false_negatives / (true_positives + false_negatives);
    statistics('fppw') = false_positives / (ok + ko);
    statistics('precision') = precision;
    statistics('recall') = recall;
    statistics('fscore') = 2*((precision*recall)/(precision+recall));
    
    
    
    
    
    
    
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
     


%% Aux function to know how many windows we'll have...
function count = get_negative_windows_count(negative_images)
     % computing number of levels in the pyramid
     count = 0;
     for i=1:numel(negative_images)
        I = imread(negative_images(i).name);
        %% temporal
        [h,w,~] = size(I);
        if max(h,w) >= 160
           ratio = max(96/w,160/h);
           I = imresize(I,ratio); 
        end
        %% fin temporal
        [~, windows] = get_pyramid_dimensions(I);
        count = count + windows;
     end
end




%% Aux function to know how the windows indices...
function [level, num_window] = get_window_indices(wxl, w_linear_index)
    accum_windows = 0;
    for i=1:size(wxl,2)
        accum_windows = accum_windows + wxl(i);
        if w_linear_index <= accum_windows
           level = i;
           num_window = accum_windows - w_linear_index;
           break 
        end
    end

end

