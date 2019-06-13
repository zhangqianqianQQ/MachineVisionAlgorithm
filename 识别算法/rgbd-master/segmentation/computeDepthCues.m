function [ng1, ng2, dg, raw] = computeDepthCues(pc, pcf, depthParam)

	numScales = length(depthParam.sigmaSpace);
	
	% Compute the gradients here	
	for i = 1:numScales,
		t = tic; 
		[raw.dg{i} raw.ng{i} raw.sng{i}] = depthCuesHelper(pc, pcf, depthParam.rr(i), depthParam.sigmaSpace(i), depthParam.qzc, depthParam.nori, depthParam.sigmaDisparity(i));
		toc(t);
	end

	% Do the cue smoothing
	for i = 1:numScales,
		ng1{i} = raw.ng{i}; 
		ng1{i}(raw.sng{i} == 1) = 0;
		
		ng2{i} = raw.ng{i}; 
		ng2{i}(raw.sng{i} == -1)= 0;

		%%%%%%%%%%   Fix for the channels orientations ....
		ng1{i} = ng1{i}(:,:,mod(9-[1:8],8)+1);
		ng2{i} = ng2{i}(:,:,mod(9-[1:8],8)+1);
		dg{i} = raw.dg{i}(:,:,mod(9-[1:8],8)+1);
		%%%%%%%%%   End for the fix for channel orientations...
	end

	sng1 = applySG(ng1, depthParam.rr*depthParam.savgolFactor);
	sng2 = applySG(ng2, depthParam.rr*depthParam.savgolFactor);
	sdg = applySG(dg, depthParam.rr*depthParam.savgolFactor);
	
	%NG convex
	ng1 = cat(4,sng1{:});

	%NG concave
	ng2 = cat(4,sng2{:});

	%DG
	dg = cat(4,sdg{:})./100;
end
