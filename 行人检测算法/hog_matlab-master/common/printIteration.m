function  printIteration(iter)
%PRINTITERATION Prints current iteration at the end of a line.
%   
    if (iter == 1)
        fprintf('%5d', iter);
        if exist('OCTAVE_VERSION') fflush(stdout); end;
    else
        fprintf('\b\b\b\b\b%5d', iter);
        if exist('OCTAVE_VERSION') fflush(stdout); end;
    end

end