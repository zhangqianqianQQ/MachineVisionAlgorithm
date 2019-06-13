function out = jointBilateral(refI, I, sigma1, sigma2)
	paths = getPaths();
	assert(isa(refI, 'double'))
	assert(isa(I, 'double'));

	% Generate two filenames
	r = randsample(100000, 3, false);
	pid = getPID();
	for i = 1:3,
		%f{i} = fullfile('/tmp', sprintf('sgupta-imageStack-%07d-%06d.tmp', pid, r(i)));
		f{i} = fullfile('/dev/shm', sprintf('sgupta-imageStack-%07d-%06d.tmp', pid, r(i)));
	end

	isWrite(refI, f{1});
	isWrite(I, f{2});

	% Run Joint Bilateral Filtering
	binName = paths.imageStackLib;
	str = sprintf('%s -load %s -load %s -jointbilateral %2.6f %2.6f -save %s double  > /dev/null', binName, f{1}, f{2}, sigma1, sigma2, f{3});
	a = system(str);
	if(a ~= 0)
		% For some reason the bilateral filtering library crashes on some inputs!!
		maxRefI = prctile(linIt(refI(:,:,4)), 98);
		refI(:,:,4) = min(refI(:,:,4), maxRefI);
		out = jointBilateral(refI, I, sigma1, sigma2);
	else
		% Read back the results
		out = isRead(f{3});
	end

	%Remove these files?
	for i = 1:3,
		str = sprintf('rm %s &', f{i});
		system(str);
	end
end
