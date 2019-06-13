function wrapperComputeFeatures2(typ, cSet)
	paths = getPaths();
	train1 = 'train';
	train2 = 'val';

	numClass = 40;
	task = 'entryLevel';
	classMapping = 'classMapping40';
	classifierType = 'svm-categorySpecific';

	imSet = {train1, train2}; useVal = 0;
	trainingParam.fileSuffix = sprintf('tr-%s_val-%s_useVal-%d', imSet{1}, imSet{2}, useVal);

	%% Train the category specific features here

	featureParam = getAblationParameters(typ);
	trainingParam.featureParam = featureParam;

	gtParam = struct('spFraction', 0.8, 'spArea', 500, 'classMapping', classMapping, 'numClass', numClass);
	trainingParam.gtParam = gtParam;

	classifierParam = getClassifierParam(classifierType, struct('useVal', useVal));
	trainingParam.classifierParam = classifierParam;
	trainingParam.classifierFileName = sprintf('%s_%s_%s', classifierType, task, trainingParam.featureParam.featureCacheName);

	trainingParam.useCache = true;


	%% Make the directory for storing the individual category files..
	mkdir(fullfile(paths.modelDir, trainingParam.featureParam.featureCacheName));
	for i = numClass:-1:1, %1:numClass,
		trainCategorySpecificModel(imSet, paths, trainingParam, i);
	end


	%% Collect these SVMs!
	fileSuffix = trainingParam.fileSuffix; 
	for i = 1:numClass,
		% Call a function that trains the SVMs for category i.
		modelFile = fullfile(paths.modelDir, trainingParam.featureParam.featureCacheName, strcat(sprintf('%s_%02d', trainingParam.classifierFileName, i), '.mat')); 
		dt = load(modelFile);
		s.models(i) = dt.model;
		s.ap(i) = dt.ap;
		s.param = dt.param;
	end
	modelFile = fullfile(paths.modelDir, strcat(sprintf('%s', trainingParam.classifierFileName), '.mat')); 
	save(modelFile, '-STRUCT', 's');

	%% Generate category specific features, using the collected SVMs
	modelFile = fullfile(paths.modelDir, strcat(sprintf('%s', trainingParam.classifierFileName), '.mat')); 
	dt = load(modelFile);
	models = dt.models;
	
	imList = getImageSet(cSet);
	mkdir(fullfile(paths.featuresDir, trainingParam.featureParam.featureCacheName));

	parfor i = 1:length(imList),
		categorySpecificFeatures(imList{i}, paths, dt.param, models);
	end
end
