function [img_features, img_ids, sPb2, thr, ucm2] = compute_image_features(cues, featureRange)
% function [img_features, img_ids, sPb2, thr] = compute_image_features(cues, featureRange)

	% feature options
	thr = 0.18;
	nthr_ori = 50;

	%permutation of orientation channels between Saurabh and ucm
	chan_perm = [5, 6, 7, 8, 1, 2, 3, 4];

	%load data
	if(isscalar(cues))
		cues = getFeaturesPabloV7(cues);
	end

	minCues = reshape(featureRange.minCues, [1 1 1 length(featureRange.minCues)]);
	maxCues = reshape(featureRange.maxCues, [1 1 1 length(featureRange.maxCues)]);

	cues = bsxfun(@rdivide, bsxfun(@minus, cues, minCues), (maxCues-minCues));
	bg1 = cues(:,:,:,13);

	cues(:,:,:,13) = (cues(:,:,:,14)+cues(:,:,:,15))/2;  	%OJO
	mean_grad = mean(cues(:,:,:,1:24),4);
	cues(:,:,:,13) = bg1;

	depth = cues(:,:,1,25);
	depth = min(1,max(0,1-depth));

	[ ~, ~, ws_wt2] = contours2ucm_RGBD(mean_grad);
	[sPb2, sPb_thin ] = spectralPb_RGBD(ws_wt2);
	[ ~, ucm2 ] = contours2ucm_RGBD(sPb2); 					%OJO

	ucm_o1 = ucm2channels(ucm2, thr, nthr_ori);

	img_features = cell(8,1);
	img_ids =cell(8,1);


	for o=1:8,
		
		bw = (ucm_o1(:,:,o) > thr);
		pixel_ids = find(bw);
		
		%extract features on orientation channel
		feats_ch = zeros(numel(pixel_ids), 54);
		for f = 1:24,
			cue2 = squeeze(cues(:, :, chan_perm(o), f));
			feats_ch(:, f) = cue2(pixel_ids);
		end
		
		% UCM and sPb strength
		ucmo = ucm_o1(:,:,o);
		feats_ch(:, 25) = ucmo(pixel_ids);
		feats_ch(:, 26) = sPb_thin(pixel_ids);
		
		% contour length
		lbl = bwlabel(bw);
		R = regionprops(lbl, 'Area'); contour_length = [R.Area];
		feats_ch(:, 27) = contour_length(lbl(pixel_ids));
		
		%replicate weighting by depth
		feats_ch(:,28:54) = feats_ch(:,1:27).*repmat(depth(pixel_ids),[1,27]);
		
		
		img_features{o} = feats_ch;
		img_ids{o} = pixel_ids;	
	end
end
