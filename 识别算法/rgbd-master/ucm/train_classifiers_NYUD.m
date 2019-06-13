function train_classifiers_NYUD(imSet, cacheDir, modelDir, O)

if(~exist('O', 'var'))
	O = 1:8;
end

KERNEL_TYPE = 'KINTERS';
W1 = 1;
C = 1;
B = 1;
vl_feat_N = 3;
solver = 0;

for o = O, %1:1:3,
    tic;
   
    out_file = fullfile(modelDir,sprintf('model_o%d-%s.mat',o, imSet));
    
    %load features
    fprintf('\n-----------------------------\n Orientation Channel: %d\n\n',o);
    
    train_featFile = fullfile(cacheDir, sprintf('features_o%d-%s.mat',o, imSet));
    train_data = load(train_featFile, 'features', 'labels');
    training_instance_matrix = train_data.features;
    training_label_vector = train_data.labels;
    clear train_data
    
    fprintf('TRAINSET:  %07d positives - %07d negatives - %07d 0 labels! \n', sum(training_label_vector==1), sum(training_label_vector==-1), sum(training_label_vector == 0));
	fprintf('Added code for removing the labels which are 0.\n');
   	ind = training_label_vector ~= 0; 
    model_svm = svm_do_train(training_label_vector(ind), training_instance_matrix(ind, :), KERNEL_TYPE, W1, C, B, vl_feat_N, solver);

    save(out_file, 'model_svm');
    
    fprintf('\nModel trained in %d s.\n',toc);
end


%%
function model_svm = svm_do_train(train_labels, train_features, KERNEL_TYPE, W1, C, B, vlfeat_N, solver)


%scale features
mx=max(train_features);
mn=min(train_features);
mx2=repmat(mx,size(train_features,1),1);
mn2=repmat(mn,size(train_features,1),1);
train_features = (train_features-mn2)./((mx2-mn2) + (mx2==mn2));

% encode and train
train_features = vl_homkermap(train_features', vlfeat_N, KERNEL_TYPE);%0.9.14
train_features = sparse(double(train_features));
model_svm = train(train_labels, train_features, sprintf('-B %f -c %f -s %d -q -w1 %f',B, C, solver, W1),'col');

model_svm.mx = mx;
model_svm.mn = mn;
model_svm.KERNEL_TYPE = KERNEL_TYPE;
model_svm.vlfeat_N = vlfeat_N;



