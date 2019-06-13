function model = VGG16_for_RPN_opt_VGG16_for_RCNN_pcn(model)
% VGG 16layers (only finetuned from conv3_1)

model.mean_image                                = fullfile(pwd, 'models', 'pre_trained_models', 'VGG16', 'mean_image');
model.pre_trained_net_file                      = fullfile(pwd, 'models', 'pre_trained_models', 'VGG16', 'vgg16.caffemodel');
% Stride in input image pixels at the last conv layer
model.feat_stride                               = 16;

%% rpn, inited from pre-trained network
model.rpn.solver_def_file                = fullfile(pwd, 'models', 'rpn_prototxts', 'VGG16', 'solver_opt_50k70k.prototxt');
model.rpn.test_net_def_file              = fullfile(pwd, 'models', 'rpn_prototxts', 'VGG16', 'test_opt.prototxt');
model.rpn.init_net_file                  = model.pre_trained_net_file;

% rpn test setting
model.rpn.nms.per_nms_topN               = 6000;
model.rpn.nms.nms_overlap_thres       	= 0.7;
model.rpn.nms.after_nms_topN         	= 1000;

%% rcnn, is trained by muilti-stage
% stage1: inited from pre-trained network
model.fast_rcnn.stage1.solver_def_file          = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'solver_40k50k_stage1.prototxt');
model.fast_rcnn.stage1.test_net_def_file        = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'test_stage1.prototxt');
model.fast_rcnn.stage1.init_net_file            = model.pre_trained_net_file;

% stage2: inited from pcn stage1 network
model.fast_rcnn.stage2.solver_def_file          = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'solver_40k50k_stage2.prototxt');
model.fast_rcnn.stage2.test_net_def_file        = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'test_stage2.prototxt');
model.fast_rcnn.stage2.init_net_file            = fullfile(pwd, 'output', 'fast_rcnn_cachedir', '%s', '%s', 'final');

% stage3: inited from pcn stage2 network
model.fast_rcnn.stage3.solver_def_file          = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'solver_40k50k_stage3.prototxt');
model.fast_rcnn.stage3.test_net_def_file        = fullfile(pwd, 'models', 'pcn_prototxts', 'VGG16', 'test_stage3.prototxt');
model.fast_rcnn.stage3.init_net_file            = fullfile(pwd, 'output', 'fast_rcnn_cachedir', '%s', '%s', 'final');

end