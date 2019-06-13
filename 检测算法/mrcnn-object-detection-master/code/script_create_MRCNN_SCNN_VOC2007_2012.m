function script_create_MRCNN_SCNN_VOC2007_2012

models_dir             = fullfile(pwd, 'models-exps');
net_def_file_directory = fullfile(pwd, 'model-defs');

% create the model directory
model_dir_dst          = fullfile(models_dir, 'MRCNN_SEMANTIC_FEATURES_VOC2007_2012');
mkdir_if_missing(model_dir_dst);

% path to the model mat file
model_mat_file  = fullfile(model_dir_dst, 'detection_model_svm.mat');

% path to the model caffe definition file
model_net_def_file = fullfile(model_dir_dst, 'deploy_svm.prototxt');
% source path to the model caffe definition file
model_net_def_file_scr = fullfile(net_def_file_directory, 'MRCNN_Semantic_Features_model_svm.prototxt');

assert(exist(model_net_def_file_scr,'file')>0);
copyfile(model_net_def_file_scr,model_net_def_file);
assert(exist(model_net_def_file,'file')>0);

region_dir_src              = {}; 
net_weigths_file_region_dst = {};
pooler_regions              = {};

% set the source directory of the region adaptation modules
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R0010_voc2012_2007_EB_ZP');  % region  1
region_dir_src{end+1} = fullfile(models_dir, 'vgg_RHalf1_voc2012_2007_EB_ZP'); % region  2
region_dir_src{end+1} = fullfile(models_dir, 'vgg_RHalf2_voc2012_2007_EB_ZP'); % region  3
region_dir_src{end+1} = fullfile(models_dir, 'vgg_RHalf3_voc2012_2007_EB_ZP'); % region  4
region_dir_src{end+1} = fullfile(models_dir, 'vgg_RHalf4_voc2012_2007_EB_ZP'); % region  5
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R0005_voc2012_2007_EB_ZP');  % region  6  
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R0308_voc2012_2007_EB_ZP');  % region  7
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R0510_voc2012_2007_EB_ZP');  % region  8
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R0815_voc2012_2007_EB_ZP');  % region  9
region_dir_src{end+1} = fullfile(models_dir, 'vgg_R1018_voc2012_2007_EB_ZP');  % region 10
% region 11: Semantic Segmentation Aware Features Region
region_dir_src{end+1} = fullfile(models_dir, 'vgg_RSemSegAware_voc2012_2007_EB_ZP');  
num_regions = length(region_dir_src);

for r = 1:num_regions
    [~, region_name] = fileparts(region_dir_src{r});
    region_model_mat_file = fullfile(region_dir_src{r}, 'detection_model_softmax.mat');
    assert(exist(region_model_mat_file,'file')>0);
    
    ld = load(region_model_mat_file, 'model'); model_this = ld.model; clear ld;
    pooler_regions{r} = model_this.pooler;
    
    net_weigths_file_region_dst{r} = fullfile(model_dir_dst,sprintf('%s.caffemodel', region_name));

    if (r == num_regions) % Semantic Segmentation Aware Features Region
        layers_region_src_this = {'fc1'};
        net_def_file_region_dst_this1 = fullfile(net_def_file_directory, 'auxiliary_def_files',...
            sprintf('Semantic_segmentation_aware_net_pascal_train_test_stream%d.prototxt',r));        
    else
        layers_region_src_this = {'fc6','fc7'};
       net_def_file_region_dst_this1 = fullfile(net_def_file_directory, 'auxiliary_def_files',...
            sprintf('VGG_ILSVRC_16_layers_pascal_train_test_stream%d.prototxt',r));
    end
    
 
    assert(exist(net_def_file_region_dst_this1, 'file')>0)
    
    caffe.set_mode_cpu();
    curr_dir = pwd;
    cd(region_dir_src{r});
    net_region_src         = caffe_load_model(model_this.net_def_file, model_this.net_weights_file);
    cd(curr_dir);
    net_region_dst         = caffe.Net(net_def_file_region_dst_this1, 'test');
    layers_region_dst_this = strcat(layers_region_src_this, sprintf('_s%d',r));
    layers_region_dst_this
    net_region_dst = caffe_copy_weights_from_net2net( net_region_dst, net_region_src, layers_region_dst_this, layers_region_src_this);
    net_region_dst.save(net_weigths_file_region_dst{r});
    caffe.reset_all();
end

% merge region types
pooler = pooler_regions{1};
for r = 1:num_regions
    fprintf('Region #%d - pooler: \n', r);
    disp(pooler_regions{r})
    pooler(r) = pooler_regions{r};
end
pooler(end).feat_id = 2;

% convert paths from absolute to relative to the model directory
[a,b,c] = fileparts(model_net_def_file);
model_net_def_file = ['./',b,c];
for i = 1:length(net_weigths_file_region_dst)
    [a,b,c] = fileparts(net_weigths_file_region_dst{i});
    net_weigths_file_region_dst{i} = ['./',b,c];    
end

% prepare and save the model structure of the multi-region cnn model

feat_blob_name   = {'fc_feat'}; % name of the output blob of the last hidden layer of the model
model_feat_cache = {'VGG_ILSVRC_16_layers', 'Semantic_Segmentation_Aware_Feats'}; % code-name of the activation maps that the VGG16 convolutional layers produce

model                  = struct;
model.net_def_file     = model_net_def_file;
model.net_weights_file = net_weigths_file_region_dst;
model.pooler           = pooler;
model.feat_blob_name   = feat_blob_name;
model.feat_cache       = model_feat_cache;
model.score_out_blob   = 'pascal_svm';
model.svm_layer_name   = 'pascal_svm';

VOCopts = initVOCOpts( '', '2007');
model.classes = VOCopts.classes;
fprintf('model:\n')
disp(model);
save(model_mat_file, 'model', '-v7.3');

end