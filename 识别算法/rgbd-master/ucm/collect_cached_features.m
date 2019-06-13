function collect_cached_features(imSet, gtDir, featureDir, cacheDir)
% function collect_cached_features(imSet, gtDir, featureDir, cacheDir)


	%% Code to check if this thing exists or not...
	recompute = false;
	for o = 1:8
		try
			cacheFile = fullfile(cacheDir, sprintf('features_o%d-%s.mat',o, imSet));
			dt = load(cacheFile);
		catch
			recompute = true;
		end
	end

	if(recompute == false) return; end

	imList = getImageSet(imSet);
	D = length(imList);

	all_features  = cell(numel(D), 8);
	all_labels    = cell(numel(D), 8);
	all_ids       = cell(numel(D), 8);

	tot_feats = zeros(8, 1);
	for i = 1 : length(imList),
		%load data
		load(fullfile(featureDir, [imList{i} '.mat']), 'img_features','img_ids');
		load(fullfile(gtDir, [imList{i} '.mat']),'ucm_gto');
		for o = 1 : 8,
			all_features{i, o} =  img_features{o};
			all_ids{i, o}      =  img_ids{o};
			ucmg = ucm_gto(:, :, o);
			all_labels{i, o}   =  ucmg(img_ids{o});
			tot_feats(o)       =  tot_feats(o) + numel(img_ids{o});
		end
		fprintf('%d, ', i);
	end

	for o = 1:8
		t = tic();
		cacheFile = fullfile(cacheDir, sprintf('features_o%d-%s.mat',o, imSet));
		
		features  = zeros(tot_feats(o), 54);
		labels    = zeros(tot_feats(o), 1);
		features_2_image = zeros(tot_feats(o), 2);
		cnt = 1;
		for i = 1 : D
			nb_feat = size(all_features{i, o}, 1);
			features(cnt:cnt+nb_feat-1, :) = all_features{i, o};
			labels(cnt:cnt+nb_feat-1)      = all_labels{i, o};
			features_2_image(cnt:cnt+nb_feat-1, :) = [all_ids{i,o}, repmat(i,[numel(all_ids{i,o}),1])];
			cnt = cnt + nb_feat;
		end
		save(cacheFile, '-v7.3', 'features', 'labels', 'all_ids', 'features_2_image');
		toc(t);
	end
end
