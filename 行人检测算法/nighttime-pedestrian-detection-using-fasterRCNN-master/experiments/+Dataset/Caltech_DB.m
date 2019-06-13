function dataset = Caltech_DB(img_path,dataset)

pLoad={'lbls',{'person'},'ilbls',{'people','person?','cyclist'},'squarify',{3,.41}};
pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ]; % reasonable setting (height>50)

rmpath(genpath('./external/toolbox(kaist)'));
addpath(genpath('./external/toolbox(caltech)'));
dataset.imdb_train(2)    = imdb_from_caltech (img_path, 'train');
dataset.roidb_train(2)   = roidb_from_caltech(img_path, dataset.imdb_train(2), pLoad);
rmpath(genpath('./external/toolbox(caltech)'));