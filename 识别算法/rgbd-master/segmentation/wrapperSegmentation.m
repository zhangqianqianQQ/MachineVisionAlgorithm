paths = getPaths();

%% Create the file for storing the bottom-up segmentation results..
allResultsFileName = fullfile(paths.outDir, 'allBUSResults.mat');
if(~exist(allResultsFileName, 'file'))
	save(allResultsFileName, 'allResultsFileName');
end

f = struct('computeLocalCues', true, 'collectFeatures', true, 'trainSVMs', true, 'computeUCM', true, ...
'benchmarkContours', true, 'computePUB', true, 'computeThreshold', true, 'doAmodalCompletion', true, 'benchmarkAmodal', true);

%% Compute the local cues for computing the UCM
if(f.computeLocalCues)
	computeUCMFeatures('trainval', paths, true);
	computeUCMFeatures('test', paths, false);
	fprintf('Computed all local boundary cues DONE\n');
end

%% Train the model on trainva
trainSet = 'trainval';

%% Collect features in a mat file
if(f.collectFeatures)
	gtDir = paths.ucmGTDir;
	featureDir = paths.ucmFDir;
	cacheDir = paths.ucmFCacheDir;
	collect_cached_features(trainSet, gtDir, featureDir, cacheDir);
	fprintf('Collecting features for training the boundary detector DONE!\n');
end

%% Train the model here, takes about 50GB memory and about 3 hours!!
if(f.trainSVMs)
	modelDir = paths.ucmModels;
	for o = 1:8,
		train_classifiers_NYUD(trainSet, cacheDir, modelDir, o);
	end
	fprintf('Trained the boundary detector\n');
end

%% Compute and save the UCM using the trained models here
if(f.computeUCM)
	featuresToUcm(trainSet, paths, 'train');
	featuresToUcm(trainSet, paths, 'val');
	featuresToUcm(trainSet, paths, 'test');
	fprintf('Computed UCMs\n');
end

%% Benchmark the UCMs
if(f.benchmarkContours)
	ucmDir = paths.ucmDir;
	imSet = 'test';
	modelname = 'release';
	contourBenchmarkParam = struct('nthresh', 99, 'maxDist', 0.011, 'thinpb', true);
	[evalResContours, evalResRegions] = benchmarkContours(ucmDir, modelname, imSet, contourBenchmarkParam);
	save(allResultsFileName, '-append', 'evalResContours', 'evalResRegions');
end

%% Compute the upper bound on performance for different number of superpixels
if(f.computePUB)
	pub.nSP = [50 75 100 125 150 175 200 225];
	[pub.ucmThresh, pub.meanNSP, pub.evalRes] = performanceUpperBound(pub.nSP, 'val', paths);
	save(allResultsFileName, '-append', 'pub');
end

%% Compute the threshold which gives ~150 superpixels
if(f.computeThreshold)
	[th.ucmThresh, th.meanNSP, th.evalRes] = performanceUpperBound(150, 'val', paths);
	fprintf('UCM thresh found to be, %0.2f\n', th.ucmThresh);
	save(allResultsFileName, '-append', 'th');
end

%% Do amodal completion, parameters for the amodal completion
if(f.doAmodalCompletion)
	load(allResultsFileName, 'th');
	amodalParam = struct('thresh', [-1 26], 'ucmThresh', th.ucmThresh);
	imList = getImageSet('all');
	parfor i = 1:length(imList),
		% Do amodal completion with them and save them.
		imName = imList{i};
		ucm2 = getUCM(imName);
		pc = getPointCloud(imName);
		doAmodalCompletion(imName, paths, ucm2, pc, amodalParam);
	end
end

%% Benchmark the amodal completion
if(f.benchmarkAmodal)
	modelname = 'release';
	amodalDir = paths.amodalDir;
	imSet = 'test';
	evalResAmodal1 = benchmarkAmodal(amodalDir, modelname, imSet, struct('ind', 1));
	evalResAmodal2 = benchmarkAmodal(amodalDir, modelname, imSet, struct('ind', 2));
	save(allResultsFileName, '-append', 'evalResAmodal1', 'evalResAmodal2');
end
