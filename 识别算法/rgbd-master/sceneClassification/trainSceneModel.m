function [modelFile, model] = trainSceneModel(imSet, paths, typ, classMapping, sceneMapping, objectDir), 

	train = imSet{1};
	val = imSet{2};

	pt = getMetadata(sceneMapping);
	numScene = length(pt.sceneName);
	sceneName = pt.sceneName;
	
	pt = getMetadata(classMapping);
	numObjectClass = length(pt.className);
	
	imSet = {train, val}; useVal = 1;
	imList{1} = getImageSet(imSet{1});
	imList{2} = getImageSet(imSet{2});
	trainingParam.fileSuffix = sprintf('tr-%s_val-%s_useVal-%d', imSet{1}, imSet{2}, useVal);

	trainingParam.featureParam = getSceneParams(typ, struct('dirName', objectDir, 'numObjectClass', numObjectClass));

	trainingParam.classifierParam = getClassifierParam('svm-scene', struct('useVal', useVal, 'numClass', numScene));
	trainingParam.gtParam = struct('sceneMapping', sceneMapping);

	% Load the features.
	for i = 1:2,
		clear f;
		parfor j = 1:length(imList{i}),
			f{j} = getSceneFeatures(imList{i}{j}, paths, trainingParam.featureParam);
		end
		F{i} = cat(2, f{:});
		gt{i} = getGroundTruth(imList{i}, 'scene', '', sceneMapping);
	end

	for i = 1:2,
		X{i} = F{i};
		Y{i} = gt{i};
		W{i} = ones(size(Y{i}));
	end
	
	svmParam = trainingParam.classifierParam;

	model = svmMulticlassTrain(X, Y, W, svmParam);
	modelFile = fullfile(paths.modelDir, strcat(sprintf('scene-%s_%s', trainingParam.featureParam.featureStr, trainingParam.fileSuffix), '.mat'))

	% Write the scene model!
	save(modelFile, 'model', 'trainingParam', 'F', 'gt');
end
