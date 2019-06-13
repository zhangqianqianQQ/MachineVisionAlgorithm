function [pc, x3, y3, z3] = getFilledPointCloud(imName)
	paths = getPaths();
	dt = load(fullfile(paths.pcDir, strcat(imName, '.mat')));
	x3 = fillHoles(dt.x3);
	y3 = fillHoles(dt.y3);
	z3 = fillHoles(dt.z3);
	pc(:,:,1) = x3;
	pc(:,:,2) = y3;
	pc(:,:,3) = z3;
end
