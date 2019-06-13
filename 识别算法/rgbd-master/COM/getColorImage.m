function I = getColorImage(imName)
	paths = getPaths();
	I = imread(fullfile(paths.colorImageDir, strcat(imName, '.png')));
end
