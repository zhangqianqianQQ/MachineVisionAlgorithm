function trainUCMModel(O, paths)
	%% Train the SVMs 
	modelDir = paths.ucmModels;
	cacheDir = paths.ucmFCacheDir;
	train_classifiers_NYUD(imSet, cacheDir, modelDir, O);
end
