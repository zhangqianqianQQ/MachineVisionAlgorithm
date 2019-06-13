function W=constructW(dist,nearnumber)
    [~, idx] = sort(dist, 2); 
    nSmp=size(dist,1);
    W=zeros(nSmp,nSmp);
    for i = 1 : nSmp
        W(i,idx(i,2:nearnumber+1)) = 1;         
    end
    W=sparse(W);
end