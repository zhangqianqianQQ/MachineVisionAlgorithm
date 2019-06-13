function setupDataOpts(vocYear, testName, datasetDir)

global DATAopts;

% Setup VOC data
devkitroot = [datasetDir, 'VOCdevkit', '/'];
DATAopts.year = vocYear;
DATAopts.dataset = sprintf('VOC%d', DATAopts.year);
DATAopts.datadir        = [devkitroot, DATAopts.dataset, '/'];
DATAopts.resdir         = [devkitroot, 'results', '/', DATAopts.dataset '/'];
DATAopts.localdir       = [devkitroot, 'local', '/', DATAopts.dataset, '/'];
DATAopts.gStructPath    = [DATAopts.resdir, 'GStructs', '/'];
DATAopts.imgsetpath     = [DATAopts.datadir, 'ImageSets', '/', 'Main', '/', '%s.txt'];
DATAopts.imgpath        = [DATAopts.datadir, 'JPEGImages', '/', '%s.jpg'];
DATAopts.clsimgsetpath  = [DATAopts.datadir, 'ImageSets', '/', 'Main', '/', '%s_%s.txt'];
DATAopts.annopath       = [DATAopts.datadir, 'Annotations', '/', '%s.xml'];
DATAopts.annocachepath	= [DATAopts.localdir, '%s_anno.mat'];
DATAopts.classes={...
    'aeroplane'
    'bicycle'
    'bird'
    'boat'
    'bottle'
    'bus'
    'car'
    'cat'
    'chair'
    'cow'
    'diningtable'
    'dog'
    'horse'
    'motorbike'
    'person'
    'pottedplant'
    'sheep'
    'sofa'
    'train'
    'tvmonitor'};
DATAopts.nclasses = length(DATAopts.classes);
DATAopts.testset = testName;
DATAopts.minoverlap = 0.5;