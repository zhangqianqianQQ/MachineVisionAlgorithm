function [outdata outlab] = randomize(indata, inlab)
    nsample = length(inlab);
    ind = randperm( nsample );
    
    outdata = indata(ind, :);
    outlab = inlab(ind);
end