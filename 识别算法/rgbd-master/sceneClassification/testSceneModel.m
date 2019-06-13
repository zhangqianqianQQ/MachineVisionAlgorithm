function outputFileName = testSceneModel(imSet, paths, modelFileName)

	imList = getImageSet(imSet);
	dt = load(modelFileName);

	trainingParam = dt.trainingParam;

	parfor j = 1:length(imList),
		f{j} = getSceneFeatures(imList{j}, paths, trainingParam.featureParam);
	end
	F = cat(2, f{:});

	[sc2, pr2, ~] = svmMulticlassTest(dt.model, F);	
	scores = pr2;
	rawScores = sc2;

	outp.imList = imList;
	outp.scores = scores;
	outp.rawScores = rawScores;

	outputFileName = fullfile(paths.sceneOutsDir, strcat(sprintf('scene-%s_%s_%s', trainingParam.featureParam.featureStr, trainingParam.fileSuffix, imSet), '.mat'));
	%Save the classifier and the predictions...
	
	save(outputFileName, '-STRUCT', 'outp');

end
%evalRes{i} = benchmarkScene(outputFileName, mapScene, imSet{i});
