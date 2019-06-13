% In order to run the scripts that are included in this file you will need 
% a GPU with at least 6 Gbytes of memory.
% 
%***************** TRAIN THE MULTI-REGION CNN MODEL **********************
% Train each region adaptation module of the multi-region CNN recognition
% model on the union of PASCAL VOC 2007 train+val and VOC2012 train+val
% datasets using both the selective search and the edge box proposals and
% flipped versions of the images. Then it trains class-specific linear svms
% on top of the features that the Multi-Region CNN model yields.

% pre-cache the activation maps of PASCAL images that will be used for
% training
script_extract_vgg16_conv_features('trainval', '2007', 'gpu_id',1,'use_flips', true);
script_extract_vgg16_conv_features('trainval', '2012', 'gpu_id',1,'use_flips', true);

% 1) train the original candidate box region adaptation module (Firure 3.a  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0010_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',0,'scale_outer',1.0);
% 2) train the left half region adaptation module (Firure 3.b  of technical report)
script_train_net_bbox_rec_pascal('vgg_RHalf1_voc2012_2007_EB_ZP','gpu_id', 1, 'half_bbox',1);
% 3) train the left half region adaptation module (Firure 3.c  of technical report)
script_train_net_bbox_rec_pascal('vgg_RHalf2_voc2012_2007_EB_ZP','gpu_id', 1, 'half_bbox',2);
% 4) train the left half region adaptation module (Firure 3.d  of technical report)
script_train_net_bbox_rec_pascal('vgg_RHalf3_voc2012_2007_EB_ZP','gpu_id', 1, 'half_bbox',3);
% 5) train the left half region adaptation module (Firure 3.e  of technical report)
script_train_net_bbox_rec_pascal('vgg_RHalf4_voc2012_2007_EB_ZP','gpu_id', 1, 'half_bbox',4);
% 6)  train the left central region adaptation module (Firure 3.f  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0005_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',0.0,'scale_outer',0.5);
% 7)  train the left central region adaptation module (Firure 3.g  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0308_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',0.3,'scale_outer',0.8);
% 8)  train the left border region adaptation module (Firure 3.h  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0510_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',0.5,'scale_outer',1.0);
% 9)  train the left border region adaptation module (Firure 3.i  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0815_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',0.8,'scale_outer',1.5);
% 10) train the left contextual region adaptation module (Firure 3.j  of technical report)
script_train_net_bbox_rec_pascal('vgg_R1018_voc2012_2007_EB_ZP','gpu_id', 1, 'scale_inner',1.0,'scale_outer',1.8);

% assemble the region adaptation modules of the multi-region CNN recognition model
script_create_MRCNN_VOC2007_2012();
% train class-specific linear svm with hard negative mining on top of the
% candidate box representations that the multi-region cnn model yields.
script_train_linear_svms_of_model('MRCNN_VOC2007_2012','gpu_id',1);
%**************************************************************************

%**** TRAIN THE SEMANTIC SEGMENTATION AWARE REGION ADAPTATION MODULE ******

% pre-cache the semantic segmentation aware activation maps of PASCAL 
% images that will be used for training semantic segmentation aware region
% adaptation module.
script_extract_sem_seg_aware_features('trainval', '2007', 'gpu_id',1);
script_extract_sem_seg_aware_features('trainval', '2012', 'gpu_id',1);

% train the region adaptation module for the semantic segmentation aware
% CNN features
script_train_net_bbox_rec_sem_seg_aware_pascal(...
    'vgg_RSemSegAware_voc2012_2007_EB_ZP','gpu_id',1,...
    'scale_inner',0.0,'scale_outer',1.5);

% assemble the region adaptation modules of the multi-region with the
% semantic segmentation aware features CNN recognition model
script_create_MRCNN_SCNN_VOC2007_2012();

% train class-specific linear svm with hard negative mining on top of the
% candidate box representations that the multi-region cnn model yields.
script_train_linear_svms_of_model('MRCNN_SEMANTIC_FEATURES_VOC2007_2012','gpu_id',1);
%**************************************************************************

%************ TRAIN THE CNN-BASED BOUNDING BOX REGRESSION MODEL ***********

% pre-cache the activation maps of PASCAL images that will be used for
% training
% script_extract_vgg16_conv_features('trainval', '2007', 'gpu_id',1,'use_flips', true);
% script_extract_vgg16_conv_features('trainval', '2012', 'gpu_id',1,'use_flips', true);

% train the CNN-based bounding box regression model
script_train_net_bbox_reg_pascal('vgg_bbox_regression_R0013_voc2012_2007',...
    'scale_inner',0.0,'scale_outer',1.3,'gpu_id',1);
%**************************************************************************

%********************* TRAIN THE BASELINE MODEL ***************************
% pre-cache the activation maps of PASCAL images that will be used for
% training
script_extract_vgg16_conv_features('trainval', '2007', 'gpu_id',1,'use_flips', true);
script_extract_vgg16_conv_features('trainval', '2012', 'gpu_id',1,'use_flips', true);

% 1) train the original candidate box region adaptation module (Firure 3.a  of technical report)
script_train_net_bbox_rec_pascal('vgg_R0010_voc2012_2007_EB_ZP',...
     'gpu_id', 1, 'scale_inner',0,'scale_outer',1.0);

% train class-specific linear svm with hard negative mining on top of the
% candidate box representations that the baseline* model yields.
script_train_linear_svms_of_model('vgg_R0010_voc2012_2007_EB_ZP','gpu_id',1);
%**************************************************************************

%****************** TEST THE DETECTION MODELS ON PASCAL *******************
% To test the multi-region recognition cnn model with the iterative 
% localization scheme on voc 2007 test set:
% 1) pre-cache the activation maps
script_extract_vgg16_conv_features('test', '2007', 'gpu_id',1);
% 2) run the detection pipeline
script_test_object_detection_iter_loc('MRCNN_VOC2007_2012',...
    'vgg_bbox_regression_R0013_voc2012_2007', 'gpu_id', 1, ...
    'image_set_test', 'test', 'voc_year_test','2007');

% To test the multi-region with the semantic segmentation aware features 
% cnn recognition model with the iterative localization scheme on voc 2007
% test set:
% 1) pre-cache the activation maps
script_extract_vgg16_conv_features('test', '2007', 'gpu_id',1);
script_extract_sem_seg_aware_features('test', '2007', 'gpu_id',1);
% 2) run the detection pipeline
script_test_object_detection_iter_loc('MRCNN_SEMANTIC_FEATURES_VOC2007_2012',...
    'vgg_bbox_regression_R0013_voc2012_2007', 'gpu_id', 1, ...
    'image_set_test', 'test', 'voc_year_test','2007');


% To test the basel*e recognition cnn model with the iterative 
% localization scheme on voc 2007 test set:
% 1) pre-cache the activation maps
script_extract_vgg16_conv_features('test', '2007', 'gpu_id',1);
% 2) run the detection pipeline
script_test_object_detection_iter_loc('vgg_R0010_voc2012_2007_EB_ZP',...
    'vgg_bbox_regression_R0013_voc2012_2007', 'gpu_id', 1, ...
    'image_set_test', 'test', 'voc_year_test','2007');

%**************************************************************************