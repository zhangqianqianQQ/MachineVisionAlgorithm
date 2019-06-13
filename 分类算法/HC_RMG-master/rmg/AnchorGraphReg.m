function F = AnchorGraphReg(Z, rL, ground, label_index, gamma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% AnchorGraphReg 
% Written by Wei Liu (wliu@ee.columbia.edu)
% Modified by Feng Gao  2017/04/08
% Z(nXm): regression weight matrix
% rL(mXm): reduced graph Laplacian 
% ground(1Xn): [1 1 1 2 2 2] discrete groundtruth class labels 
% label_index(1Xln):  given index of labeled data
% gamma: regularization parameter, set to 0.001-1
% F(nXC): soft label scores on raw data
% A(mXC): soft label scores on anchors
% err: classification error rate on unlabeled data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n,m] = size(Z);
ln = length(label_index);
C = max(ground);

Yl = zeros(ln,C);
for i = 1:C
    ind = find(ground(label_index) == i);
    Yl(ind',i) = 1;
    clear ind;
end

Zl = Z(label_index',:);
LM = Zl'*Zl+gamma*rL; 
clear rL; 
RM = Zl'*Yl;  
clear Yl;
clear Zl;
A = (LM+1e-6*eye(m))\RM; 
clear LM;
clear RM;

F = Z*A; 
clear Z;



