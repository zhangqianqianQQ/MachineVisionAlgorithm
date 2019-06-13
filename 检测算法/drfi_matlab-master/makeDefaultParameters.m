function para = makeDefaultParameters()
    % number of segmentations
    % the more number of segmentations, the better performance and slower
    % speed
    para.num_segmentation = 15;
    
    % trained segment (region) saliency regressor, saliency fusion weight
    % model = load( './model/model_MSRA_48s_trn_valid_full_93d_regressor_weight.mat' );   
    model = load( './model/drfiModelMatlab.mat' );   
    
    [sw ind] = sort( model.w, 'descend' );
    w = sw(1 : para.num_segmentation );
    w = w / sum(w);
    
    para.w = w;
    para.ind = ind(1 : para.num_segmentation);
    
    para.seg_para = model.para(para.ind,:);
    
%     newModel = load( './model/saliency_model_cpp.mat');
    para.segment_saliency_regressor = model.segment_saliency_regressor; 
    
    % saveModel('Model.mat', para);
end

% 	int _N; // Number of segmentation
% 	vecD _w; // weights with dimension: N
% 	Mat _segPara1d; // Segmentation parameters: [Nx3]
% 	int _NumN; // nrNodes: Number of nodes (41565)
% 	int _NumT; // number of Tree (200)
% 	// int Matrix of size [NumN x NumT]
% 	Mat _lDau1i, _rDau1i, _mBest1i;
% 	// char matrix of size [NumN x NumT]
% 	Mat _nodeStatus1c;
% 	// double matrix of size [NumN x NumT]
% 	Mat _upper1d, _avNode1d;
% 	vecI _ndTree; //[NumT]
% 	Mat _mlFilters15d; // [19 x 19 x 15] 

function saveModel(fileName, para)
   N = para.num_segmentation;
   sr = para.segment_saliency_regressor;
   NumN = sr.nrnodes;   
   NumT = sr.ntree;
   w = para.w;   
   segPara = para.seg_para;
   lDau = sr.lDau;
   rDau = sr.rDau;
   mBest = sr.mbest;
   nodeStatus = sr.nodestatus;
   upper = sr.upper;
   avNode = sr.avnode;
   mlFilters = makeLMfilters;
   ndTree = sr.ndtree;
   save(fileName, 'N', 'NumN', 'NumT', 'w', 'segPara', 'lDau', 'rDau', 'mBest', 'nodeStatus', 'upper', 'avNode', 'mlFilters', 'ndTree');
end