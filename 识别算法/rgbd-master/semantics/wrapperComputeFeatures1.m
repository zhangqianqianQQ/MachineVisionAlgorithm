function wrapperComputeFeatures1(imSet, ucmThresh)
	%% Assume that you have the ucms in the directory ucm, the amodal completions in the directory amodal
	imList = getImageSet(imSet);

	paths = getPaths();

	%Make Directories...
	dirName = {'generic', 'gTexton', 'colorSift'};
	for i = 1:length(dirName)
		dName = fullfile(paths.featuresDir, dirName{i});
		if(~exist(dName, 'dir'))
			mkdir(dName);
		end
	end
	dirName = {'colorSift', 'gTexton'};
	for i = 1:length(dirName)
		dName = fullfile(paths.mapDir, dirName{i});
		if(~exist(dName, 'dir'))
			mkdir(dName);
		end
	end

	%% Computing all features here
	yDirParam.angleThresh = [45 15];
	yDirParam.iter = [5 5];
	yDirParam.y0 = [0 1 0]';

	spParam.ucmThresh = ucmThresh; % = 34/255;

	normalParam.patchSize = [3 10];  

	genericParam.fName = @genericFeatures;

	gTextonMapParam.nbins = 30;
	gTextonMapParam.yMinMean = -130;
	gTextonMapParam.yMinOutlier = -90;
	gTextonMapParam.dimensions = 900;
	gTextonMapParam.typ = 'gTexton';

	gTextonBOWParam.dimensions = 900;
	gTextonBOWParam.fName = @bowFeatures;

	% Load the dictionary
	dt = load('codebook_opp_s1.2_K1000_2000.mat');
	vocab = dt.vocab; 
	siftMapParam.dimensions = size(vocab, 2); 
	siftMapParam.siftParam = struct('ds_sampling', 1, 'scales', 1.2, 'descriptor', 'opponentsift');
	siftMapParam.typ = 'colorSift';

	siftBOWParam.fName = @bowFeatures;
	siftBOWParam.dimensions = siftMapParam.dimensions;

	parfor i = 1:length(imList),
		% Load the point cloud
		tt = tic();
		I = getColorImage(imList{i});
		pc = getPointCloud(imList{i});
		[superpixels, ucm, nSP, spArea] = getSuperpixels(imList{i}, spParam.ucmThresh);
		[clusters] = getAmodalCompletion(imList{i});
		
		% Load the zg gradients
		[zgMax, bgMax, bgOriented] = getLocalGradients(imList{i});


		% Compute the normals for this image
		[N1 b1] = computeNormals(pc(:,:,1), pc(:,:,2), pc(:,:,3), superpixels, normalParam.patchSize(1));
		[N2 b2] = computeNormals(pc(:,:,1), pc(:,:,2), pc(:,:,3), superpixels, normalParam.patchSize(2));

		% Compute the direction of gravity
		yDir = getYDir(N2, yDirParam);

		% Compute generic features
		genericData = struct('pc', pc, 'clusters', clusters, 'superpixels', superpixels,...
			'normals', N1, 'yDir', yDir, 'zgMax', zgMax, 'bgOriented', bgOriented, 'bgMax', bgMax);
		% Compute Features also saves the features in the cache directory.
		[f, sp2reg] = computeFeatures(imList{i}, paths, 'generic', genericParam, genericData);

		% Compute sift map and features
		siftData = struct('I', I, 'vocab', vocab);
		[map dimensions] = computeMap(imList{i}, paths, siftMapParam, siftData);
		
		siftData = struct('map', map, 'clusters', clusters, 'superpixels', superpixels);
		[f, sp2reg] = computeFeatures(imList{i}, paths, 'colorSift', siftBOWParam, siftData);

		%  % Compute geocentric texton maps and features
		gTextonData = struct('pc', pc, 'N', N1, 'yDir', yDir);
		[map, dimensions] = computeMap(imList{i}, paths, gTextonMapParam, gTextonData);
		
		gTextonData = struct('map', map, 'clusters', clusters, 'superpixels', superpixels);
		[f, sp2reg] = computeFeatures(imList{i}, paths, 'gTexton', gTextonBOWParam, gTextonData);

		fprintf('Time taken: %0.4g seconds.\n',toc(tt));
	end
end
