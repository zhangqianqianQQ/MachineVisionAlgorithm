function scores = getSceneProb(outp, imList)
% Find the output corresponding to the images in 
	dt = load(outp);
	[there, loc] = ismember(imList, dt.imList);
	assert(all(there) == true, sprintf('Did not find output for all images in imList in the mat file, %s', outp));
	scores = dt.scores(:, loc);
end
