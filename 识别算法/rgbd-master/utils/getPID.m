function t = getPID()
	t = feature('GetPid');
	while (~isnumeric(t))
		t = feature('GetPid');
	end
end
