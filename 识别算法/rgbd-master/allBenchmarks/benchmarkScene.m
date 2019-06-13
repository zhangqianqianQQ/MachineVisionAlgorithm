function evalRes = benchmarkScene(outp, infoFile, imSet)
% function evalRes = benchmarkScene(outp, infoFile, imSet)
% Takes in as input the 
%	imSet to benchmark on,
%	infoFile to define what scene ground truth to use
%	outp is afile which contains 
%		scores - the output as a matrix [num scenes x num images] and 
%		imList the list of images for which the score has the scores.

	imList = getImageSet(imSet);
	
	pt = getMetadata(infoFile);
	gtScene = getGroundTruth(imList, 'scene', '', infoFile, '');
	sceneName = pt.sceneName;

	%Get the scores for benchmarking..!
	scores = getSceneProb(outp, imList);
	[classwiseAP classwiseAcc conf count] = calcAPMultiClass(gtScene, scores);
	accuracies = diag(count)./(sum(count,1)' + sum(count,2) - diag(count));
	freq = sum(count, 2);
	fwavacc = freq'*accuracies/sum(freq); 
	overallAcc = sum(diag(count))./sum(count(:));
	avacc = mean(accuracies);
	caltechAccuracy = mean(diag(conf));
	
	evalRes = struct('freq', freq, 'imSet', imSet, 'infoFile', infoFile, ...
		'accuracies', accuracies, 'fwavacc', fwavacc, 'overallAcc', overallAcc, ...
		'avacc' ,avacc, 'classwiseAP', classwiseAP, 'caltechAccuracy', caltechAccuracy, ...
		'outp', outp, 'conf', conf, 'count', count);
	evalRes.imList = imList;
	evalRes.sceneName = sceneName;	

	% Write this in a file somewhere?
	[f1, f2, f3] = fileparts(outp);
	fileName = fullfile(f1, sprintf('%s-%s-results.mat', f2, imSet));
	fprintf('\nSaving the benchmarking results in %s.\n', fileName);
	save(fileName, '-STRUCT', 'evalRes');
end
