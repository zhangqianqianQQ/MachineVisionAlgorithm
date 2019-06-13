function param = getSceneParams(typ, data)
	param.numObjectClass = data.numObjectClass;
	switch(typ)
		case 'colorSift',
			param.labelInDir = {'colorSift'};
			param.featureStr = 'colorSift';
			param.labelFieldName = {''};

		case 'gTexton',
			param.labelInDir = {'gTexton'};
			param.featureStr = 'gTexton';
			param.labelFieldName = {''};

		case 'gTextonSift',
			param.labelInDir = {'gTexton', 'colorSift'};
			param.featureStr = 'gTextonSift';
			param.labelFieldName = {'',''};

		case 'objScores',
			param.labelInDir = {data.dirName};
			param.featureStr = sprintf('objScores');
			% param.featureStr = sprintf('objScores-%s', data.dirName);
			param.labelFieldName = {'scores'};

		case 'objRawScores',
			param.labelInDir = {data.dirName};
			param.featureStr = sprintf('objRawScores-%s', data.dirName);
			param.labelFieldName = {'rawScores'};

		case 'all',
			param.labelInDir = {'gTexton', 'colorSift', data.dirName};
			param.featureStr = sprintf('gTextonSiftObj-%s', data.dirName);
			param.labelFieldName = {'','','scores'};
	end
end
