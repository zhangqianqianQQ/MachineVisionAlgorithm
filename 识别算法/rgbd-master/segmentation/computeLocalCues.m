function [bg, cga, cgb, tg, ng1, ng2, dg, z, cues] = computeLocalCues(imName, paths, I, pc, pcf, param)
	
	%% Compute the local appearance cues
	try 
		fileName = fullfile(paths.colorCues, strcat(imName, '.mat'));
		load(fileName);
	catch
		[bg, cga, cgb, tg] = computeColorCues(I, param.colorParam);
		fileName = fullfile(paths.colorCues, strcat(imName, '.mat'));
		save(fileName, 'bg', 'cga', 'cgb', 'tg');
	end
	
	%% Code to compute the depth and normal cues
	try 
		fileName = fullfile(paths.depthCues, strcat(imName, '.mat'));
		load(fileName);
	catch
		[ng1, ng2, dg, raw] = computeDepthCues(pc, pcf, param.depthParam);
		z = pcf(:,:,3)./100;
		fileName = fullfile(paths.depthCues, strcat(imName, '.mat'));
		save(fileName, 'ng1', 'ng2', 'dg', 'z');
	end
	cues = cat(4, ng1, ng2, dg, bg, cga, cgb, tg, repmat(z, [1 1 8 1]));

	%% Save only the relevant for recognition gradients
	% bgOriented
	% wBg = param.colorParam.bgWeightsRecog;
	
	wBg = [1 1 1]./3;
	BG = sum(bsxfun(@times, bg, reshape(wBg, [1 1 1 3])), 4);
	BG = min(BG./5, 1);		%Saturate at some level
	signal = BG;
	fileName = fullfile(paths.gradientsForRecognition, 'bgOriented', strcat(imName, '.mat'));
	save(fileName, 'signal');

	% bgMax
	signal = squeeze(max(bg, [], 3));
	fileName = fullfile(paths.gradientsForRecognition, 'bgMax', strcat(imName, '.mat'));
	save(fileName, 'signal');

	% zgMax
	signal1 = squeeze(max(ng1, [], 3));
	signal2 = squeeze(max(ng2, [], 3));
	signal3 = squeeze(max(dg, [], 3));
	signal = cat(3, signal1, signal2, signal3);
	fileName = fullfile(paths.gradientsForRecognition, 'zgMax', strcat(imName, '.mat'));
	save(fileName, 'signal');
end
