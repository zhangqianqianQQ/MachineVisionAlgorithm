function S = SimplexPr(X)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% SimplexPr
% Written by Wei Liu (wliu@ee.columbia.edu)
% X(CXN): input data matrix, C: dimension, N: # samples
% S: the projected matrix of X onto C-dimensional simplex  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 [C,N] = size(X);
 [T1,T2] = sort(X,1,'descend');
 clear T2;
 S = X;
 
 for i = 1:N
     kk = 0;
     t = T1(:,i);
     for j = 1:C
         tep = t(j)-(sum(t(1:j))-1)/j;
         if tep <= 0
            kk = j-1;
            break;
         end
     end
 
     if kk == 0
        kk = C;
     end
     theta = (sum(t(1:kk))-1)/kk;
     S(:,i) = max(X(:,i)-theta,0);
     clear t;
 end
 
 clear T1;

