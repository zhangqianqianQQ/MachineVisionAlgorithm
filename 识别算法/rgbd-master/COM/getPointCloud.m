function [pc, x3, y3, z3] = getPointCloud(imName)
	paths = getPaths();
	dt = load(fullfile(paths.pcDir, strcat(imName, '.mat'))); 
	x3 = dt.x3;
	y3 = dt.y3;
	z3 = dt.z3;
	pc(:,:,1) = x3;
	pc(:,:,2) = y3;
	pc(:,:,3) = z3;
end
