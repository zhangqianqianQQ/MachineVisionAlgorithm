function L=constructL(label)
nSmp=size(label,1);
W=label*label';
W=NormalizeL1(W,1);
DCol = full(sum(W,2));
D = spdiags(DCol,0,nSmp,nSmp);
L = D - W;
D_mhalf = spdiags(DCol.^-.5,0,nSmp,nSmp) ;
L = D_mhalf*L*D_mhalf;
end