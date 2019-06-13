function [ucm2, ucm] = loadUCM(imName)
	paths = getPaths();
	fileName = fullfile(paths.ucmDir, strcat(imName, '.png'));

	if(exist(fileName, 'file'))
		ucm2 = imread(fileName);
		ucm = ucm2(3:2:end, 3:2:end);
	else
		fileName = fullfile(paths.ucmDir, strcat(imName, '.mat'));
		dt = load(fileName);
		ucm2 = dt.ucm2;
		ucm = ucm2(3:2:end, 3:2:end);
	end

end
