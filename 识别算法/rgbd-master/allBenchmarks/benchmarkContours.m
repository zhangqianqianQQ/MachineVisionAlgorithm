function [evalResContours, evalResRegions] = benchmarkContours(ucmDir, modelname, imSet, param)
%	param.maxDist, param.thinpb, param.nthresh
	imList = getImageSet(imSet);
	c = benchmarkPaths();

	%% Create the directory.
	bDir = fullfile(c.contoursTmpDir, sprintf('ucm-%s_%s', modelname, imSet));
	if(~exist(bDir, 'dir'))
		mkdir(bDir);
	end
	fprintf('Benchmarking contours in %s directory. Writing evaluation files in %s.\n', ucmDir, bDir);

	% Run the evaluatons..
	inDir = ucmDir;
	outDir = bDir;
	gtDir = c.benchmarkGtDir; 

	parfor i = 1:length(imList),
		imName = imList{i};
		inFile = fullfile(inDir, strcat(imName, '.mat'));
		gtFile = fullfile(gtDir, strcat(imName, '.mat'));
    	
		evFile4 = fullfile(outDir, strcat(imName, '_ev4.txt'));
		evFile1 = fullfile(outDir, strcat(imName,'_ev1.txt'));
		evFile2 = fullfile(outDir, strcat(imName, '_ev2.txt'));
		evFile3 = fullfile(outDir, strcat(imName, '_ev3.txt'));

		try 
			if isempty(dir(evFile1)), 
				evaluation_bdry_image(inFile, gtFile, evFile1, param.nthresh, param.maxDist, param.thinpb);
			end	
			if isempty(dir(evFile4)), 
				evaluation_reg_image(inFile, gtFile, evFile2, evFile3, evFile4, param.nthresh);
			end
		catch e
			prettyexception(e);
			fprintf('Something went wrong in the evaluation of %s\n.', imName);
		end
	end

	% %Collect the results of contour benchmarking and return them
	evalDir = outDir;
	[bestF, bestP, bestR, bestT, F_max, P_max, R_max, Area_PR] = collect_eval_bdry(outDir);
	out = dlmread(fullfile(outDir,'eval_bdry_thr.txt'));
	thresh = out(:,1);
	R = out(:,2);
	P = out(:,3);
	F = out(:,4); 
	
	evalResContours = struct('bestF', bestF, 'bestP', bestP, 'bestR', bestR', 'bestT', bestT, ...
		'F_max', F_max, 'P_max', P_max, 'R_max', R_max', 'Area_PR', Area_PR,...
		'thresh', thresh, 'F', F, 'P', P, 'R', R);
	evalResContours.imSet = imSet;
	evalResContours.ucmDir = ucmDir;
	evalResContours.bDir = bDir;
	evalResContours.imList = imList;

	% Collect the region benchmarks...
	collect_eval_reg(outDir);
    coverage = dlmread(fullfile(outDir,'eval_cover.txt'));
	ods = coverage(2);
	ois = coverage(3);
	bestC = coverage(4);
    randVI = dlmread(fullfile(outDir,'eval_RI_VOI.txt'));
	randIods = randVI(2);
	randIois = randVI(3);
	varIods = randVI(5);
	varIois = randVI(6);

	evalResRegions = struct('ods', ods, 'ois', ois, 'bestC', bestC, ...
		'randIods', randIods, 'randIois', randIois, 'varIods', varIods, 'varIois', varIois);
	
	%% Also save the results in there as a mat.
	fileName = strcat(bDir, '.mat');
	fileName = fullfile(sprintf('%s-eval-%s.mat', ucmDir, imSet));
	fprintf('\nSaving the benchmarking results in %s.\n', fileName);
	save(fileName, 'evalResContours', 'evalResRegions');
end
