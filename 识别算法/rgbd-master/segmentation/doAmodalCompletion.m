function [superpixels, clusters, Z] = doAmodalCompletion(imName, paths, ucm2, pc, amodalParam)
	ucmThresh = amodalParam.ucmThresh;
	thresh = amodalParam.thresh;

	superpixels = bwlabel(ucm2 < amodalParam.ucmThresh);
	superpixels = superpixels(2:2:end, 2:2:end);
	[clusters, Z] = amodalCompletion(superpixels, pc, thresh);

	fileName = fullfile(paths.amodalDir, strcat(imName, '.mat'));
	save(fileName, 'ucmThresh', 'superpixels', 'thresh', 'clusters', 'Z');
end
