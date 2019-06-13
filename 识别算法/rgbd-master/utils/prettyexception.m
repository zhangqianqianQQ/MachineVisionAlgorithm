% Pretty-print exception and stack trace.
% Copyright 2008-2009 Levente Hunyadi

function prettyexception(me)
	validateattributes(me, {'MException'}, {'scalar'});
	fprintf(2, '%s [%s]\n', me.message, me.identifier);
	fprintf('Stack trace:\t\t');
	for k = 1 : numel(me.stack)
		sf = me.stack(k);
		fprintf('%d - %s, ', sf.line, sf.name);
	end
end
