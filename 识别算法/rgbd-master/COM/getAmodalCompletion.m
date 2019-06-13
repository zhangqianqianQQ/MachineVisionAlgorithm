function [clusters, superpixels, thresh, ucmThresh] = getAmodalCompletion(imName)
	paths = getPaths();
	dt = load(fullfile(paths.amodalDir, strcat(imName, '.mat')));
	clusters = dt.clusters;
	thresh = dt.thresh;
	ucmThresh = dt.ucmThresh;
	superpixels = dt.superpixels;
end
