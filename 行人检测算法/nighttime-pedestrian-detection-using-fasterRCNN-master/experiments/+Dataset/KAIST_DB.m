function dataset = KAIST_DB(img_path)

pLoad={'lbls',{'person'},'ilbls',{'people','person?','cyclist'}};
train_gt_filter = [pLoad, 'hRng',[55 inf], 'vType', {'none'} ];
test_gt_filter =  [pLoad, 'hRng',[55 inf], 'vType',{{'none','partial'}},'xRng',[5 635],'yRng',[5 475]];

addpath(genpath('./external/toolbox(kaist)'));
dataset.imdb_train    = imdb_from_kaist2 (img_path, 'train');
dataset.roidb_train   = roidb_from_kaist2(img_path, dataset.imdb_train, train_gt_filter);
dataset.imdb_test     = imdb_from_kaist2 (img_path, 'test');
dataset.roidb_test    = roidb_from_kaist2(img_path, dataset.imdb_test, test_gt_filter);