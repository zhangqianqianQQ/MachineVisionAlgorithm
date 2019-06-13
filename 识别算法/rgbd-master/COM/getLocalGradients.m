function [zgMax, bgMax, bgOriented] = getLocalGradients(imName)
	paths = getPaths();
	typ = {'bgOriented', 'bgMax', 'zgMax'};
	for t = 1:3, 
		fileName = fullfile(paths.gradientsForRecognition, typ{t}, strcat(imName, '.mat'));
		dt = load(fileName);
		eval(sprintf('%s = dt.signal;', typ{t}));
	end
	ng1 = zgMax(:,:,[1:4 4]);
	ng2 = zgMax(:,:,[5:8 8]);
	dg = zgMax(:,:,[9:12 12]);
	zgMax = cat(3, ng1, ng2, dg);
end
