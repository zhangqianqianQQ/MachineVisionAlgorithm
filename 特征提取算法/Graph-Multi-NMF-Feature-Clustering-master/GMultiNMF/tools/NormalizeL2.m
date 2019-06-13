function fea = NormalizeL2(fea,row)
if ~exist('row','var')
    row = 1;
end

if row
    nSmp = size(fea,1);
    feaNorm = max(1e-14,full(sum((fea.^2))));
    fea = diag(feaNorm.^-0.5)*fea;
else
    nSmp = size(fea,2);
    feaNorm = max(1e-14,full(sum((fea.^2))));
    fea = fea*diag(feaNorm.^-0.5);
end
   

end