function segDeepM

% Train and test segDeepM 
% using VGG16

year = '2010';

% -------------------- CONFIG --------------------
net_file     = './data/caffe_nets/VGG_voc_2010_train_i100k';
cache_name   = 'v1_VGG_voc_2010_train_i100k';

crop_mode    = 'warp';
crop_padding = 16;
layer        = 15;
k_folds      = 0;

VOCdevkit = sprintf('./datasets/VOCdevkit%s',year);
% ------------------------------------------------

current = pwd;
cd (VOCdevkit);
addpath('VOCcode')
VOCinit;

cd (current);

addpath([VOCdevkit '/VOCcode']);
VOCopts.year = year;
% ------------------------------------------------
trainset = 'train';
testset = 'val';
id = 'segDeepM';

% ------------------------------------------------
% Configuring parameters
config.cnn_load =  sprintf('cachedir/rcnn_model_cnn_%s.mat',year);
config.pos_save_file = sprintf('./cachedir/gt_pos_layer_5_cache_%s.mat', 'segDeepM');
config.roidbfunc = @roidb_from_voc;

% Segmentation features
config.seg.use = 1;
config.seg.segFeatPivot = 4096;
config.seg.maskPath = 'segDeepM/cpmc_masks/' ;
config.seg.maxSegUsed = 3;
config.seg.numSegClasses = 20;
config.seg.lambda = 7;
config.seg.numPyra = 3;
config.seg.featLength = config.seg.numSegClasses + 3 + 2 * config.seg.numPyra^2;
config.seg.saveFeat = 1;
if strcmp(trainset,'train')
    config.seg.potentialPath = sprintf('segDeepM/cpmc_potentials_train_val_%s/',year);
else
    config.seg.potentialPath = sprintf('segDeepM/cpmc_potentials_trainval_test_%s/',year);
end
config.seg.segSaveDir = sprintf('segDeepM/cpmc_cache/cpmc_feat_cache_%s/',id);

% Context network
config.ctx.use = 1;
config.seg.segFeatPivot = config.seg.segFeatPivot + 4096 * config.ctx.use;
config.ctx.cnn_load = sprintf('cachedir/rcnn_model_ctx_%s.mat',year);
config.ctx.cache_name = [cache_name, '_ctx'];
config.ctx.net_file   = [net_file,  '_ctx'];

% ------------------------------------------------
imdb_train = imdb_from_voc(VOCdevkit, trainset, year);
imdb_test = imdb_from_voc(VOCdevkit, testset, year);

fprintf('The id for this experiment is:%s\n',id);
keyboard;

try
    load(sprintf('cachedir/segDeepM_%s_%s_bkp.mat',year,id),'rcnn_model')
catch
    [rcnn_model] = ...
        segDeepMtrain(imdb_train, config, ...
        'layer',        layer, ...
        'k_folds',      k_folds, ...
        'cache_name',   cache_name, ...
        'net_file',     net_file, ...
        'crop_mode',    crop_mode, ...
        'crop_padding', crop_padding, ...
        'id', 			id,...
        'config',       config);
    
    save(sprintf('cachedir/segDeepM_%s_%s_bkp.mat',year,id),'rcnn_model')
end

res_test = segDeepMtest(rcnn_model, imdb_test, id);

segDeepMwrite(testset,VOCopts,id);

