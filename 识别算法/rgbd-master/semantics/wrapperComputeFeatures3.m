function wrapperComputeFeatures3(imSet, outputFileName)
	imList = getImageSet(imSet);

	paths = getPaths();

	dt = load(outputFileName);

	[ind loc] = ismember(imList, dt.imList);
	features = dt.rawScores(:, loc);

	dirName = fullfile(paths.featuresDir, 'scene');
	if(~exist(dirName, 'file')) mkdir(dirName); end

	% Write out individual files like the generic features so that it is consistent with those while reading in features.
	for i = 1:length(imList),
		fileName = fullfile(paths.featuresDir, 'generic', strcat(imList{i}, '.mat'));
		dt = load(fileName);
		nSP = size(dt.features{1}, 2);
		dt.features{1} = repmat(features(:, i), [1 nSP]);
		for j = 2:length(dt.features),
			dt.features{j} = zeros(0, nSP);
		end

		fileName = fullfile(paths.featuresDir, 'scene', strcat(imList{i}, '.mat'));
		save(fileName, '-STRUCT', 'dt'); 
		% save(fileName, 'clusters', 'superpixels', 'sp2reg', 'features');
	end
end
