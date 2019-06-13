% Demo for RGBD Structured Edge Detector (please see readme.txt first).

addpath(genpath(pwd)); savepath;
addpath(genpath('/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/toolbox/')); savepath;

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelNyud2Rgbd';     % model name
opts.nPos=2.5e5; opts.nNeg=2.5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory
opts.fracFtrs=1/8;                % sample fewer ftrs since using depth
%opts.bsdsDir='BSR/BSDS500/data/';    % specify use of NYU data
opts.bsdsDir='BSR/nyud2_dataset/data/';    % specify use of NYU data
opts.rgbd=2;                      % specify use of rgb+d images

%% train edge detector (~50m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% evaluate edge detector on NYUD (see edgesEval.m)
if(0), edgesEval( model, 'show',1, 'name','', 'maxDist',.011 ); end

%% detect edge and visualize results
iDir=[opts.bsdsDir 'images/train/']; dDir=[opts.bsdsDir 'depth/train/'];
%id=dir(fullfile(iDir,'*.png')); id={id.name}; id=id{1};
%I=single(imread(fullfile(iDir,id)))/255;
%D=single(imread(fullfile(dDir,id)))/1e4;
display(dDir);
id=dir(fullfile(dDir,'img0026.png')); id={id.name}; id=id{1};
%I=single(imread(fullfile(iDir,[id(1:end-3) 'jpg'])))/255;
I=single(imread(fullfile(iDir,[id(1:end-3) 'png'])))/255;
D=single(imread(fullfile(dDir,id)))/1e4;
tic, E=edgesDetect(cat(3,I,D),model); toc
figure(1); im(I); figure(2); im(1-E);
imwrite((1-E),'tempbndr.png','png'); 
