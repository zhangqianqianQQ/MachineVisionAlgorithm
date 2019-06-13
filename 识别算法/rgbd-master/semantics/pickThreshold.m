function pickThreshold(imList, paths, modelFileName)
	dt = load(modelFileName);
	param = dt.param;
	
	featureParam = param.featureParam;
	gtParam = param.gtParam;
	classifierParam = param.classifierParam;

	outputDir = fullfile(paths.modelDir, strcat(sprintf('%s_%s', param.classifierFileName, param.fileSuffix), '.mat'));
	
	benchmarkParam.ignoreBck = true;
	evalResIgnoreBck = benchmarkSS(outp, benchmarkParam.infoFile, imSet{2}, benchmarkParam);
	[~, ind] = max(evalResIgnoreBck.detailsIU.fwavacc);
	threshIgnoreBck = benchmarkParam.threshIU(ind);
	fprintf('Thresh found for max IU %0.2f.\n', thresh);
	
	resultFileName = sprintf('%s_%s_results.mat', res_dir, imSet{2});
	save(resultFileName, 'evalRes', 'evalResIgnoreBck',  '-v7.3'); 
end
