%% Run classification given pretrained cnn models and model definition files.
%% Written by Ning Zhang

function results = run_classification(cnn_models, model_def)
% get data
try
  load('caches/cub2011_config.mat');
catch
  config = get_bird_data;
  save('caches/cub2011_config.mat', 'config');
end

% Extract features from train box and then train linear SVM.
try 
  load('caches/finetune_model_fc7.mat');
catch
  try
    load('caches/finetune_train_fea_fc7.mat');
  catch
    train_fea = cell(1, config.N_parts);
    for i = 1 : config.N_parts
      train_fea{i} = extract_deep_features(cnn_models{i}, model_def, ...
	  config.impathtrain, config.train_box{i});
    end
    save('caches/finetune_train_fea_fc7', 'train_fea');
  end
  TRN_fea = [];
  for i = 1 : config.N_parts
    TRN_fea = [TRN_fea train_fea{i}];
  end
  TRN_fea = scale_feature(TRN_fea);
  disp('Train linear SVM ... ...');
  lc = 1; % regularization parameter C
  option = ['-s 1 -c ' num2str(lc)];
  model = train(config.trainlabel, single(TRN_fea), option);
  save('caches/finetune_model_fc7', 'model');
end

% Extract features from detected box and then test.
try 
  load('caches/finetune_test_fea_fc7.mat');
catch
  % get detected part boxes
  detect_boxes = get_rcnn_detections(config);
  
  % test_fea{i,j} is the features for part i of method j 
  test_fea = cell(config.N_parts, config.N_methods); 
  for i = 1 : config.N_parts
    for method = 1 : 3
      % method = 1 box detection feature
      % method = 2 prior detection feature
      % method = 3 neighbor detection feature
      test_fea{i, method} = extract_deep_feature(cnn_models{i}, ... 
        model_def, config.impathtest, detect_boxes{i, method});
    end
  end
  % features for groundtruth bounding box
  test_fea_gt = cell(1, config.N_parts);
  for i = 1 : config.N_parts
    test_fea_gt{i} = extract_deep_feature(cnn_models{i}, ...
      model_def, config.impathtest, config.test_box{i});
  end
  save('caches/finetune_test_fea_fc7','test_fea', 'test_fea_gt');
end

% Test SVM model
TST_fea = [];
for i = 1 : config.N_parts
  TST_fea = [TST_fea test_fea_gt{i}];
end
TST_fea = scale_feature(TST_fea);
[~,accuracy,~] = predict(config.testlabel, single(TST_fea), model);
results.oracle_accuracy = accuracy;
fprintf('Accuracy of using oracle part boxes is %f\n', accuracy);

for method = 1 : config.N_methods 
  TST_fea = [];
  for i = 1 : config.N_parts
    TST_fea = [TST_fea test_fea{i, method}];
  end
  TST_fea = scale_feature(TST_fea);
  [~,accuracy,~] = predict(config.testlabel, single(TST_fea), model);
  results.detected_accuracy(method) = accuracy;
  fprintf('Accuracy of %s is %f\n', config.methods{method}, accuracy);
end
end

function fea = scale_feature(fea)
  ppp = 0.3;
  for i = 1:size(fea,2)
    fea(:,i) = sign(fea(:,i)).*abs(fea(:,i)).^ppp;
  end
end
