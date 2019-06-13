function openPool(s)
	if s > 0
		while true
			try
		  		matlabpool('open', s);
		  		break;
			catch e
				prettyexception(e);
				fprintf('Ugg! Something bad happened. Trying again in 10 seconds...\n');
				pause(10);
			end
	  	end
	end
end
