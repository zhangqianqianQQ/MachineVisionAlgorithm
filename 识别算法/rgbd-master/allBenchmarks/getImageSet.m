function [imName, im] = getImageSet(imSet, fileName)
% function im = getImageSet(imSet, fileName)
	if(nargin < 2)
		fName = 'nyusplits';
	end

	c = benchmarkPaths(0);
	outFileName = sprintf('%s/metadata/%s.mat',c.benchmarkDataDir, fName);
	dt = load(outFileName);
	dt.all = union(dt.trainval, dt.test);
	a = regexp(imSet, '_', 'split');
	if(strcmp(a{1}, 'img'))
		im = imNameToNum(imSet);
	else
		try
			eval(sprintf('im = dt.%s;', a{1}));
			if(length(a) == 4)
				eval(sprintf('im = im(%s:%s:%s);', a{2}, a{3}, a{4}));
			end
		catch
		
		end
	end
	
	for i = 1:length(im)
		imName{i} = sprintf('img_%04d', im(i));
	end
end
