function computeUCMFeatures(imSet, paths, forTraining)
	ucmRangeFile = fullfile(sprintf('featureRange-all.mat'));
	dt = load(ucmRangeFile);

	imList = getImageSet(imSet);

	%% Parameters for the local cues
	depthParam = struct('qzc', 2.9e-5, ...
		'sigmaSpace', 1.40*[1 2 3 4], 'rr', 5*[1 2 3 4], ...
		'sigmaDisparity', [3 3 3 3], 'nori', 8, 'savgolFactor', 1.2);
	colorParam = []; %struct('bgWeightsRecog', [0.135 0.134 0.151]);

	param.depthParam = depthParam;
	param.colorParam = colorParam;

	% Make directories..
	dirName = {'bgOriented', 'bgMax', 'zgMax'};
	for i = 1:length(dirName),
		dName = fullfile(paths.gradientsForRecognition, dirName{i});
		if(~exist(dName, 'dir'))
			mkdir(dName);
		end
	end

	parfor i = 1:length(imList),
		tt = tic();
		sPb2 = []; thr = [];
		imName = imList{i};
		fileName = fullfile(paths.ucmFDir, sprintf('%s.mat', imName));
		try
			dt1 = load(fileName); 
			img_features = dt1.img_features; thr = dt1.thr; img_ids = dt1.img_ids; sPb2 = dt1.sPb2; ucm2 = dt1.ucm2;
		catch e
			prettyexception(e);
			fprintf('UCM features not found for image %s.\n', imName);
			
			I = getColorImage(imName);
			pc = getPointCloud(imName);
			pcf = getFilledPointCloud(imName);

			try
				[bg, cga, cgb, tg, ng1, ng2, dg, z, cues] = computeLocalCues(imName, paths, I, pc, pcf, param);
				[img_features, img_ids, sPb2, thr, ucm2] = compute_image_features(cues, dt); %This is not the final UCM yet.
				parsave(fileName, 'img_features', img_features, 'thr', thr, 'img_ids', img_ids, 'sPb2', sPb2, 'ucm2', ucm2);
			catch ee
				prettyexception(ee);
				fprintf('Something went wrong while computing UCM cues for image %s.\n', imName);
			end
		end
	
		if(forTraining)
			% Compute the ground truth to use for the boundary candidates..
			gtOutFile = fullfile(paths.ucmGTDir, sprintf('%s.mat', imName))
			try
				dt2 = load(gtOutFile);
			catch
				fprintf('UCM ground truth not found for image %s.\n', imName);
				% Compute the ground truth for these images
				groundTruth = getGroundTruth(imName, 'bsdsStruct'); 
				try
					ucm_gto = transferGroundTruth(groundTruth, sPb2, thr);
					parsave(gtOutFile, 'ucm_gto', ucm_gto);
				catch e
					fprintf('Something went wrong while computing ground truth for image %s.\n', imName);
				end
			end
		end
	end
end
