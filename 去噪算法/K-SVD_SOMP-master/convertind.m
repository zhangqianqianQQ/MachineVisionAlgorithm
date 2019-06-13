function [idx,idy] = convertind(ind,m,n)
    if mod(ind,m) == 0
        idx = m;idy = ind/m;
    else
        idx = mod(ind,m);idy = floor(ind/m)+1;
    end
end