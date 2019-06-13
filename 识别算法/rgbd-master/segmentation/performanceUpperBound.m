function [ucmThresh, meanNSP, evalRes] = performanceUpperBound(nSP, imSet, paths)
	classMapping = 'classMapping40';
	gtParam = struct('classMapping', classMapping, 'numClass', 40);
	bParam = struct('thresh', 0, 'threshPR', [], 'threshIU', [], 'infoFile', classMapping, 'ignoreBck', true);

	imList = getImageSet(imSet);
	for i = 1:length(nSP),
		[ucmThresh(i), meanNSP(i)] = computeSPThreshold('train', nSP(i));
		ucmThresh(i) = round(ucmThresh(i)*100)./100;
		
		% Write out the output isng the ground truth
		outputDir = fullfile(paths.outsDir, strcat(sprintf('%s_%02d', 'upperBound', round(ucmThresh(i)*100))));
		if(~exist(outputDir)) mkdir(outputDir); end

		parfor j = 1:length(imList),
			fileName = fullfile(outputDir, strcat(imList{j}, '.mat'));
			
			% Load the superpixels
			[superpixels, ~, nSPi] = getSuperpixels(imList{j}, ucmThresh(i));

			% Load the ground truth
			gtLabel = getGroundTruth(imList{j}, 'segmentation', gtParam.classMapping);
			spHist = cell2mat(accumarray(superpixels(:), gtLabel(:), [], @(x){linIt(histc(x,0:gtParam.numClass))})');
			spHist = bsxfun(@times, spHist, 1./(1+sum(spHist,1)));
			spHist = spHist(2:end,:);
			[maxVal, maxInd] = max(spHist, [], 1);

			%Write it out
			scores = zeros(gtParam.numClass, nSPi);
			scores(sub2ind(size(scores), maxInd, 1:nSPi)) = 1;

			parsave(fileName, 'superpixels', superpixels, 'scores', scores);
		end

		% Benchmark it
		evalRes(i) = benchmarkSSInternal(outputDir, imSet, bParam);
	end
end
