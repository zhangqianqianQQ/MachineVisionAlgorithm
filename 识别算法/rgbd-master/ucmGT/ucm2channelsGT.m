function ucm_o1 = ucm2channelsGT(ucm2, thr, nthr_ori, angSpan)
	if nargout<4, angSpan = 1; end
		
	ucm = resample_ucm2_orient_new(ucm2,thr,nthr_ori); 
	ucm_o1 = quantize_ucm_or(ucm, 8, angSpan);
end

function ucm = resample_ucm2_orient_new(ucm2, min_thr, nthresh)
	thresh = linspace(min_thr, max(ucm2(:)), nthresh)';

	[tx2, ty2] = size(ucm2);
	img_sz(1) = (tx2-1)/2; img_sz(2) = (ty2-1)/2;

	ucm.strength = zeros([tx2, ty2]);
	ucm.orient = zeros(img_sz);
	old = true([tx2,ty2]);
	for t = nthresh:-1:1,
		bw = (ucm2 <= thresh(t));
		if isequal(bw,old), continue; end
		labels2 = bwlabel(bw);
		seg = labels2(2:2:end, 2:2:end);
		bdry = seg2bdry(seg);
		ucm.strength = max(ucm.strength, thresh(t)*bdry);
		
		[seg_ori] = get_segmentation_orientation(bdry(3:2:end,3:2:end));
		ucm.orient = max(ucm.orient,(ucm.orient==0).*seg_ori);
		old = bw;
	end
end

function [seg_ori] = get_segmentation_orientation(seg_bw)

	contours = fit_contour(double(seg_bw));
	angles = zeros(numel(contours.edge_x_coords), 1);

	for e = 1 : numel(contours.edge_x_coords)
		if contours.is_completion(e), continue; end
		v1 = contours.vertices(contours.edges(e, 1), :);
		v2 = contours.vertices(contours.edges(e, 2), :);

		if v1(2) == v2(2),
			ang = pi/2;
		else
			ang = -atan((v2(1)-v1(1)) / (v2(2)-v1(2))); 
		end
		if ang >0,
			angles(e) = ang;
		else
			angles(e) = pi+ang;
		end
	end

	seg_ori = zeros(size(seg_bw));
	for e = 1 : numel(contours.edge_x_coords)
		if contours.is_completion(e), continue; end
		for p = 1 : numel(contours.edge_x_coords{e}),
			seg_ori(contours.edge_x_coords{e}(p), contours.edge_y_coords{e}(p)) = angles(e);
		end
	end
end
