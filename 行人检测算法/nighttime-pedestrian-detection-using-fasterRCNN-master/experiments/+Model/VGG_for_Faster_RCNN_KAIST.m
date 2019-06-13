function model = VGG_for_Faster_RCNN_KAIST(model)

model.mean_image                                = fullfile(pwd, 'models', 'pre_trained_models', 'vgg_16layers', 'mean_image');
% VGG16 (trained with imageNet, first fully connected layer is truncated) is used as pre-trained model
model.pre_trained_net_file                      = fullfile(pwd, 'models', 'pre_trained_models', 'vgg_16layers', 'vgg16(7x3)'); 
% Stride in input image pixels at the last conv layer
model.feat_stride                               = 8;
model.muti_frame                                = 0;

%% stage 1 rpn, inited from pre-trained network
model.stage1_rpn.solver_def_file                = fullfile(pwd, 'models', 'rpn_prototxts', 'vgg_16layers_conv3_1', 'solver_60k80k.prototxt');
model.stage1_rpn.test_net_def_file              = fullfile(pwd, 'models', 'rpn_prototxts', 'vgg_16layers_conv3_1', 'test.prototxt');
model.stage1_rpn.init_net_file                  = model.pre_trained_net_file;
model.stage1_rpn.multi_frame                    = model.muti_frame;

% rpn test setting
model.stage1_rpn.nms.per_nms_topN              	= -1;
model.stage1_rpn.nms.nms_overlap_thres        	= 0.5;
model.stage1_rpn.nms.after_nms_topN           	= 500; % 2000->500 for hard negative

%% stage 1 fast rcnn, inited from pre-trained network
model.stage1_fast_rcnn.solver_def_file          = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'vgg_16layers_conv3_1', 'solver_30k40k.prototxt');
model.stage1_fast_rcnn.test_net_def_file        = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'vgg_16layers_conv3_1', 'test.prototxt');
model.stage1_fast_rcnn.init_net_file            = model.pre_trained_net_file;
model.stage1_fast_rcnn.multi_frame              = model.muti_frame;

%% stage 2 rpn, only finetune fc layers
model.stage2_rpn.solver_def_file                = fullfile(pwd, 'models', 'rpn_prototxts', 'vgg_16layers_fc6', 'solver_60k80k.prototxt');
model.stage2_rpn.test_net_def_file              = fullfile(pwd, 'models', 'rpn_prototxts', 'vgg_16layers_fc6', 'test.prototxt');
model.stage2_rpn.multi_frame                    = model.muti_frame;

% rpn test setting
model.stage2_rpn.nms.per_nms_topN             	= -1;
model.stage2_rpn.nms.nms_overlap_thres       	= 0.5;
model.stage2_rpn.nms.after_nms_topN           	= 500; % 2000->500 for hard negative

%% stage 2 fast rcnn, only finetune fc layers
model.stage2_fast_rcnn.solver_def_file          = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'vgg_16layers_fc6', 'solver_30k40k.prototxt');
model.stage2_fast_rcnn.test_net_def_file        = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'vgg_16layers_fc6', 'test.prototxt');
model.stage2_fast_rcnn.multi_frame              = model.muti_frame;

end