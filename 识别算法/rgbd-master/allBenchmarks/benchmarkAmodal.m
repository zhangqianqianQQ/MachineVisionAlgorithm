function evalRes = benchmarkAmodal(amodalDir, modelname, imSet, param)
	imList = getImageSet(imSet);
	c = benchmarkPaths(false);

	%% 
	% param.ind is the ind from the affinity cluster matrix to use... 
	ind = param.ind;

	%% Create the directory.
	bDir = fullfile(c.amodalTmpDir, sprintf('amodal-%s_%s', modelname, imSet), sprintf('%d', ind));
	inDir = fullfile(bDir, 'output');
	outDir = fullfile(bDir, 'benchmarks'); 
	if(exist(bDir, 'dir'))
		fprintf('%s already exists, deleting it!!\n', bDir);
		rmdir(bDir, 's');
	end
	mkdir(bDir);
	mkdir(inDir);
	mkdir(outDir);

	nsegs = zeros(length(imList), 1);
	%Copy the amodal completions to that directory..
	parfor i = 1:length(imList),
		imName = imList{i};
		dt = load(fullfile(amodalDir, strcat(imName, '.mat')), 'clusters', 'superpixels');
		segs1 = uint16(dt.superpixels);
	
		clusterI = dt.clusters(:,ind); 
		amodal = clusterI(dt.superpixels);
		new_reg = (accumarray(dt.clusters(:,ind),1) > 1);

		segs2 = uint16(cmunique(amodal.*new_reg(amodal)));
		nsegs(i) = max(segs1(:)) + max(segs2(:));
		segs2 = uint16(cmunique(amodal)+1);
		
		fprintf('.');
		outFileName = fullfile(inDir, strcat(imName, '.mat'));
		parsave(outFileName, 'segs', {segs1, segs2});
	end
	fprintf('\n');

	% Run the evaluatons..
	gtDir = c.benchmarkGtDir; 

	for i = 1:length(imList),
		imName = imList{i};
		evFile4 = fullfile(outDir, strcat(imName, '_ev4.txt'));
		if exist(evFile4, 'file') continue; end
		inFile = fullfile(inDir, strcat(imName, '.mat'));
		gtFile = fullfile(gtDir, strcat(imName, '.mat'));
		evFile2 = fullfile(outDir, strcat(imName, '_ev2.txt'));
		evFile3 = fullfile(outDir, strcat(imName, '_ev3.txt'));
		evaluation_reg_image(inFile, gtFile, evFile2, evFile3, evFile4, 2);
	end

	% %Collect thre results and return them
	evalDir = outDir;
	collect_eval_reg(evalDir);
	if exist(fullfile(evalDir,'eval_cover.txt'),'file'),
		evalRes = dlmread(fullfile(evalDir,'eval_cover.txt'));
		fprintf('Region\n');
		fprintf('GT covering: ODS = %1.2f [th = %1.2f]. OIS = %1.2f. Best = %1.2f\n',evalRes(2),evalRes(1),evalRes(3:4));
		er{1} = evalRes;
		evalRes = dlmread(fullfile(evalDir,'eval_RI_VOI.txt'));
		fprintf('Rand Index: ODS = %1.2f [th = %1.2f]. OIS = %1.2f.\n',evalRes(2),evalRes(1),evalRes(3));
		fprintf('Var. Info.: ODS = %1.2f [th = %1.2f]. OIS = %1.2f.\n',evalRes(5),evalRes(4),evalRes(6));
		er{2} = evalRes;
	end

	evalRes.imSet = imSet;
	evalRes.bDir = bDir;
	evalRes.metrics1 = er{1};
	evalRes.metrics2 = er{2};
	evalRes.nsegs = nsegs;

	fileName = fullfile(sprintf('%s-eval-%s-%d.mat', amodalDir, imSet, ind));
	fprintf('\nSaving the benchmarking results in %s.\n', fileName);
	save(fileName, '-STRUCT', 'evalRes');
end
