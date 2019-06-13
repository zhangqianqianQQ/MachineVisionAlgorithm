function paths = getPaths(doMkdir)
	%% Data dir
	paths.dataDir = fullfile('/work3/', 'sgupta', 'cvpr13Release', 'data');
		paths.pcDir = fullfile(paths.dataDir, 'pointCloud');
		paths.colorImageDir = fullfile(paths.dataDir, 'colorImage');

	%% Cache dir
	paths.cacheDir = fullfile('/work3', 'sgupta', 'cvpr13Release', 'cachedir');

	RUNNAME = 'release';
	paths.runDir = fullfile(paths.cacheDir, RUNNAME);

	paths.cacheDir = fullfile(paths.runDir, 'cache');
		paths.gradientsForRecognition = fullfile(paths.cacheDir, 'gradientsRecog');
		paths.colorCues = fullfile(paths.cacheDir, 'colorCues');
		paths.depthCues = fullfile(paths.cacheDir, 'depthCues');
		paths.featuresDir = fullfile(paths.cacheDir, 'features');
		paths.mapDir = fullfile(paths.cacheDir, 'map');
		paths.featureCache = fullfile(paths.cacheDir, 'featureCache');
		paths.outsDir = fullfile(paths.cacheDir, 'outs');
		paths.sceneOutsDir = fullfile(paths.cacheDir, 'sceneOuts');
			paths.ucmFDir = fullfile(paths.cacheDir, 'ucmFeatures', 'features');
			paths.ucmFCacheDir = fullfile(paths.cacheDir, 'ucmFeatures', 'cache');
			paths.ucmGTDir = fullfile(paths.cacheDir, 'ucmFeatures', 'ucm_gto');

	paths.modelDir = fullfile(paths.runDir, 'model');
		paths.categroySpecificModels = fullfile(paths.modelDir, 'categorySpecific');
		paths.ucmModels = fullfile(paths.modelDir, 'ucm');
	
	paths.outDir = fullfile(paths.runDir, 'output');
		paths.ssOutDir = fullfile(paths.outDir, 'semanticSegmentation');
		paths.amodalDir = fullfile(paths.outDir, 'amodal');
		paths.ucmDir = fullfile(paths.outDir, 'ucm');

	%% Path for the image stack library ..
	pathstr = fileparts(mfilename('fullpath'));
		paths.siftLib = fullfile(pathstr, '..', 'external', 'colorDescriptor');
		paths.imageStackLib = fullfile(pathstr, '..', 'external', 'ImageStack');

	if(exist('doMkdir', 'var') && doMkdir)
		f = fieldnames(paths);
		for i = 1:length(f)
			d = paths.(f{i});
			if(~exist(d, 'dir'))
				mkdir(d);
			end
		end
	end
end
