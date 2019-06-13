function [new_model,Ureduce] = train_svm_PCA(model_name, paths)
% TRAIN_SVM_PCA Train an SVM classifier with the specified images.
%           Performing a cross-validation to find the best params.
%
% Asumming pedestrian label as 1.0 and not pedestrian as -1.0
% (Code using libsvm)
%
% INPUT:
% Paths: positive / negative images_path: paths of the images to train
% model_name: name for saving the SVM model
%
% OUTPUT: libSVM model and reduced singular vector matrix.
%
%$ Author Jose Marcos Rodriguez $    
%$ Date: 2014/03/11 $    
%$ Revision: 1.2 $


    %% path stuff
    if nargin < 2
        model_save_path = uigetdir('.models','Select model save folder');
        positive_images_path = uigetdir('.images','Select positive image folder');
        negative_images_path = uigetdir('.images','Select negative image folder');
        
        if isa(model_save_path,'double')  || ...
           isa(positive_images_path,'double')  || ...
           isa(negative_images_path,'double')
            cprintf('Errors','Invalid paths...\nexiting...\n\n')
            return 
        end
        
    else
        model_save_path = paths{1};
        positive_images_path = paths{2};
        negative_images_path = paths{3};
    end

    %% train matrix and labels
    params = get_params('train_svm_params');
    pos = params.num_positive_instances;
    negs = params.num_negative_instances;
    
    [positive_images,negative_images] = ...
        get_files(pos, negs,{positive_images_path,negative_images_path});
    [labels, train_matrix]= get_feature_matrix(positive_images,negative_images);
    
    
    %% PCA reduction of the feature matrix
    [train_matrix, Ureduce] = PCA_reduction(train_matrix, 0.95);

    
    % =====================================================================
    %% SVM STUFF
    % Crosss validation (k-fold crossval)
    % =====================================================================
    
    train_params = get_params('train_svm_params');  
    kernel_type = train_params.kernel;
    cost_range = train_params.cost_range;
    gamma_range = train_params.gamma_range; 
    
    svm_params = ...
        cross_validate(kernel_type,cost_range,gamma_range,...
                       train_matrix, labels, ...
                       [model_save_path,filesep,model_name]);

    
    % just for fixing GUI freezing due to unic thread MatLab issue
    drawnow; 
       
    % =====================================================================
    %% SVM trainning
    % =====================================================================
    
    svm_start = tic;
    cprintf('Comments', 'beggining svm train...\n')
    new_model.(model_name) = svmtrain(labels, train_matrix, svm_params);
    svm_elapsed = toc(svm_start);
    fprintf('SVM training done in: %f seconds.\n',svm_elapsed);
    
    fprintf(['Saving model in ',model_save_path, model_name, '.mat','\n']);
    save([model_save_path,filesep,model_name, '.mat'], '-struct','new_model',model_name);
    
    fprintf(['Saving Reduced Singular Vectors matrix in ',model_save_path, model_name, '_reduced_SVs.mat','\n']);
    save([model_save_path,filesep,model_name, '_reduced_SVs.mat'], 'Ureduce');


end