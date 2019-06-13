function [Z, rL] = AnchorGraph(TrainData, Anchor, s, flag, cn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% AnchorGraph
% Written by Wei Liu (wliu@ee.columbia.edu)
% TrainData(dXn): input data matrix, d: dimension, n: # samples
% Anchor(dXm): anchor matrix, m: # anchors 
% s: # of closest anchors, usually set to 2-10 
% flag: 0 gives a Gaussian kernel-defined Z and 1 gives a LAE-optimized Z
% cn: # of iterations for LAE, usually set to 5-20; if flag=0, input 'cn' any value
% Z(nXm): output anchor-to-data regression weight matrix 
% rL(mXm): reduced graph Laplacian matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d,m] = size(Anchor);
n = size(TrainData,2);
Z = zeros(n,m);

Dis = sqdist(TrainData,Anchor);
val = zeros(n,s);
pos = val;
for i = 1:s
    [val(:,i),pos(:,i)] = min(Dis,[],2);
    tep = (pos(:,i)-1)*n+[1:n]';
    Dis(tep) = 1e60;
end
clear Dis;
clear tep;
ind = (pos-1)*n+repmat([1:n]',1,s);

if flag == 0
   %% kernel-defined weights
    %% adaptive kernel width I used in ICML'10
    % val = val./repmat(val(:,s),1,s);  
    % val = exp(-val);
    %% unified kernel width that could be better
    sigma = mean(val(:,s).^0.5);
    val = exp(-val/(1/1*sigma^2));
    
    val = repmat(sum(val,2).^-1,1,s).*val;  
else
   %% LAE-optimized weights 
    for i = 1:n
        x = TrainData(:,i); 
        x = x/norm(x,2);
        U = Anchor(:,pos(i,:));  
        U = U*diag(sum(U.^2).^-0.5);
        val(i,:) = LAE(x,U,cn);
    end
    clear x;
    clear U;
end

Z([ind]) = [val];
Z = sparse(Z);
clear val;
clear pos;
clear ind;
clear TrainData;
clear Anchor;

T = Z'*Z;
rL = T-T*diag(sum(Z).^-1)*T;
clear T;

