function dt = getMetadata(fileName)
	c = benchmarkPaths(0);
	dt = load(sprintf('%s/metadata/%s.mat', c.benchmarkDataDir, fileName));
end
