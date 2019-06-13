function f = getSceneFeatures(imName, paths, param)
	%First get the ground truth labels for the scenes.
	for i = 1:length(param.labelInDir),
		p.labelInDir = param.labelInDir{i};
		p.labelFieldName = param.labelFieldName{i};
		p.numObjectClass = param.numObjectClass;
		f{i} = helper(imName, paths, p);
	end
	f = cat(1,f{:});
end


function f = helper(imName, paths, param)
	if(~exist('param','var'))
		param.labelInDir = '';
	end
	i = 1;
	switch(param.labelInDir),
		case 'colorSift',
			typ = param.labelInDir;
			%Getting the histogram of sift features
			inFileName = fullfile(paths.mapDir, typ, strcat(imName, '.mat'));
			dt = load(inFileName);
			segmentation = dt.map;
			score = ones(size(segmentation));
			vq = segmentation;
			f(:,i) = getPHog(vq, score, dt.dimensions);

		case 'gTexton',
			typ = param.labelInDir;
			%Getting a histogram of the gtextons.
			inFileName = fullfile(paths.mapDir, typ, strcat(imName, '.mat'));
			dt = load(inFileName);
			segmentation = dt.map;
			score = ones(size(segmentation));
			vq = segmentation;
			f(:,i) = getPHog(vq, score, dt.dimensions);

		otherwise,
			%inFileName = fullfile(paths.outsDir, param.labelInDir, strcat(imName, '.mat'));
			inFileName = fullfile(param.labelInDir, strcat(imName, '.mat'));
			dt = load(inFileName);
			eval(sprintf('dtscores = dt.%s;', param.labelFieldName));
			[score vq] = max(dtscores,[],1);
			score = score(dt.superpixels);
			vq = vq(dt.superpixels);
			g = [];
			for j = 1:param.numObjectClass,
				sc = dtscores(j,:);
				[gr g(j,:)] = getPHog(ones(size(dt.superpixels)), sc(dt.superpixels), 1);
			end
			g = bsxfun(@times, g, 1./sum(g,1));
			f(:,i) = g(:);
	end
end
