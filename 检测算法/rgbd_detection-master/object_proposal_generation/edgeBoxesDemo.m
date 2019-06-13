% Demo for Edge Boxes (please see readme.txt first).

addpath(genpath(pwd)); savepath;
addpath(genpath('/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/toolbox/')); savepath;



%% load pre-trained edge detection model and set opts (see edgesDemo.m)
% model=load('models/forest/modelBsds'); model=model.model;
model=load('models/forest/modelNyud2Rgbd'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%dataDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/BSR/nyud2_dataset/data/';
dataDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/BSR/vocb3do/data/';
flist=dir([dataDir '/images/train/*.png']); flist={flist.name};

cnt=0;
trainfileID = fopen('train_annot.txt','a');
testfileID = fopen('test_annot.txt','a');
trainFileName=importdata('train.txt');
testFileName=importdata('val.txt');
recall=0;
t_imgs=0;
num_prop=2000;
numel(flist)
for fidx=1:numel(flist)
	tp=0;
	tpfn=0;
	I=single(imread([dataDir 'images/train/' flist{fidx}]))/255;
	%D=single(imread([dataDir 'depth/train/' flist{fidx}]))/1e4;
	D=single(imread([dataDir 'depth/train/' flist{fidx}(1:end-4) '_abs_smooth.png']))/1e4;
	tic, bbs=edgeBoxes(I,D,model,opts); toc
	display(sprintf('img %d of %d, number of proposals: %d',fidx,numel(flist),size(bbs,1)));
	%if(size(bbs,1) > num_prop)
	%	bbs=bbs(1:num_prop,:);
	%end
	%num_prop=size(bbs,1);
	%t_imgs=numel(flist);
	%%% detect Edge Box bounding box proposals (see edgeBoxes.m)
	%I = imread('peppers.png');
	%tic, bbs=edgeBoxes(I,model,opts); toc

	%%% show evaluation results (using pre-defined or interactive boxes)
	%gt=[122 248 92 65; 193 82 71 53; 410 237 101 81; 204 160 114 95; ...
	%  9 185 86 90; 389 93 120 117; 253 103 107 57; 81 140 91 63];
	try
		display('in try')
		fName=['/home/priyanka/Desktop/VOCB3DO/VOCB3DO_Annotations/all_objects/' flist{fidx}(1:end-3) 'txt'];
		%fName=['/home/priyanka/Desktop/VOCB3DO/VOCB3DO_Annotations/all_objects/img_0013.txt'];
		fileID = fopen(fName);
		C = textscan(fileID,'%d %d %d %d %s');
		gt=cat(2,C{1},C{2},C{3},C{4});
		class_name=C{5};
		fclose(fileID);
		t_imgs=t_imgs+1;
	catch
		display('in catch')
		continue;
	end
	if(0), gt='Please select an object box.'; disp(gt); figure(1); imshow(I);
	  title(gt); [~,gt]=imRectRot('rotate',0); gt=gt.getPos(); end
	gt(:,5)=0; [gtRes,dtRes]=bbGt('evalRes',gt,double(bbs),.7);
	figure(1); bbGt('showRes',I,gtRes,dtRes(dtRes(:,6)==1,:)); pause(0.1);
	title('green=matched gt  red=missed gt  dashed-green=matched detect');
	A=bbGt('showRes',I,gtRes,dtRes(dtRes(:,6)==1,:));
		
	iname=['imgs/' flist{fidx}(1:end-4) '.png'];
	saveas(gcf,iname);
	
	% getting object bounding boxes
	%fName=replace(fName,'/home/priyanka/Desktop/VOCB3DO/VOCB3DO_Annotations/all_objects/','');
	fName=strrep(fName,'/home/priyanka/Desktop/VOCB3DO/VOCB3DO_Annotations/all_objects/','');
	
	isTrain=any(ismember(trainFileName,flist{fidx}(1:end-4)));
	isTest=any(ismember(testFileName,flist{fidx}(1:end-4)));
	if(isTrain == 1)
		depthDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/b3do/train/depth/';
		rgbDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/b3do/train/rgb/';
		writefileID=trainfileID;
	end
	if(isTest == 1)
		depthDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/b3do/test/depth/';
		rgbDir='/home/priyanka/Documents/autonomous_systems/sem-4/edgeBoxes/pdollar-edges-94260b5/b3do/test/rgb/';
		writefileID=testfileID;
	end
	
	origD=imread([dataDir 'depth/train/' flist{fidx}(1:end-4) '_abs_smooth.png']);
	for gidx=1:size(gt,1)
		cnt=cnt+1;
		tempgt = gt(gidx,:);
		[gtResT,dtResT]=bbGt('evalRes',tempgt,double(bbs),.7);
		loc = find(dtResT(:,6)==1);
		if(~isempty(loc))
			oname = class_name{gidx};
			I2 = imcrop(I,gtResT(1:4));
			D2 = imcrop(origD,gtResT(1:4));
			r_name=[oname '_1_1_' num2str(cnt) '_crop.png'];
			d_name=[oname '_1_1_' num2str(cnt) '_depthcrop.png'];
			imwrite(I2,[rgbDir '' r_name]);
			imwrite(D2,[depthDir '' d_name]);
			fprintf(writefileID,'%s %s\n',r_name,num2str(lookup(oname)));

		end
	end
	
	loc = find(dtRes(:,6)==1);	
	tp = tp + numel(loc);	
	tpfn = tpfn+size(gtRes,1);
	%display(tp);
	%display('...');
	%display(dtRes(loc,:));
	%display(tpfn);
	%display('---');
	%disp(tp);
	%disp(tpfn);
	recall=recall+(tp/tpfn);
end

display(recall);
display(recall/t_imgs);
if 0
%% run and evaluate on entire dataset (see boxesData.m and boxesEval.m)
if(~exist('boxes/VOCdevkit/','dir')), return; end
split='val'; data=boxesData('split',split);
nm='EdgeBoxes70'; opts.name=['boxes/' nm '-' split '.mat'];
edgeBoxes(data.imgs,model,opts); opts.name=[];
boxesEval('data',data,'names',nm,'thrs',.7,'show',2);
boxesEval('data',data,'names',nm,'thrs',.5:.05:1,'cnts',1000,'show',3);
end
