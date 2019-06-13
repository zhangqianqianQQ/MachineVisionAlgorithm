function ucm_gto = transferGroundTruth(groundTruth, sPb2, thr)

	%inDir = '/work5/arbelaez/saurabh/RELEASE/data/groundTruth_NYUD/';
	%D = dir(fullfile(inDir,'*.mat'));

	rad = 8;

	str= strel(fspecial('disk', rad));

	gt=double(groundTruth{1}.Boundaries);

	%[ucm2.strength, ucm2.orient] = resample_ucm2_orient(tmp.ucm2);
	%ucm_o1 = quantize_ucm_or(ucm2, 8, 1);

	[~, ucm2] = contours2ucm_RGBD(sPb2); %OJO
	[tx2,ty2]=size(ucm2);
	
	ucm_o1 = ucm2channelsGT(ucm2, thr+0.02, 100, 1);
	[gt2.orient] = get_segmentation_orientation(gt);
	gt2.strength = zeros([tx2,ty2]); 
	gt2.strength(3:2:end,3:2:end)=gt;
	gt_o3 = quantize_ucm_or(gt2, 8, 3);
	ucm_gto = zeros(size(ucm_o1));

	for o=1:8,
		gtp = ((ucm_o1(:,:,o)>thr) & imdilate(gt_o3(:,:,o), str));
		gtn = ((ucm_o1(:,:,o)>thr) & ~gtp);
		ucm_gto(:,:,o) = gtp - gtn;
	end

	%save(outFile,'ucm_gto');
	
	%keyboard;
	%ucm_gt = max(ucm_gto==1,[],3)-max(ucm_gto==-1,[],3);figure;imshow(ucm_gt,[]);colormap(jet) ;
	%figure;imshow(ucm_gt==1);drawnow;
	%keyboard
end
