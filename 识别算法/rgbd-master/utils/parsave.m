function parsave(fileName, varargin)
	assert(mod(length(varargin), 2) == 0, 'Improper number of arguments...');
	for i = 1:length(varargin)/2,
		varName = varargin{2*i-1};
		varVal = varargin{2*i};
		assert(isstr(varName), 'Variable name not string');
		eval(sprintf('dt.%s = varVal;', varName));
	end
	save(fileName, '-STRUCT', 'dt');
end
