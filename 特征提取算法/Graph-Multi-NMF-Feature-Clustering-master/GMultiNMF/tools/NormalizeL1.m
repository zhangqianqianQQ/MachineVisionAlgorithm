function fea = NormalizeL1(fea,row)
if ~exist('row','var')
    row = 1;
end

if row
    nSmp = size(fea,1);
    feaNorm = max(1e-14,full(sum(abs(fea),2)));
    fea = diag(feaNorm.^-1)*fea;
else
    nSmp = size(fea,2);
    feaNorm = max(1e-14,full(sum(abs(fea),1)));
    fea = fea*diag(feaNorm.^-1);
end
   

end