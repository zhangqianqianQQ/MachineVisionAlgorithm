function A = SOMPerr_L(D,X,sparse_L,BETA)

[n,P]=size(X);
[n,K]=size(D);
%%%%%%%%%%%%%%%guiyihua
BETA_matrix1=repmat(BETA,[1 P]);
BETA_matrix2=repmat(BETA,[1 K]);
X_scale=X.*BETA_matrix1;
D_scale=D.*BETA_matrix2;
X=X_scale;
D=D_scale;

%%%%%%%%%%%%%%%%%%%%


A = sparse(K,P);
a = [];
residual = X;
  indx=zeros(sparse_L,1);

j = 0;

for i=1:sparse_L
         j=j+1;
    
        proj = mean(D' * residual,2) ;
%         proj = sum(proj,2);
        pos = find(abs(proj) == max(abs(proj)));
        pos = pos(1);
        indx(j) = pos;
        a = pinv(D(:,indx(1:j)))*X;
        residual = X - D(:,indx(1:j))*a;
		
end
if (~isempty(indx))
       A(indx,:) = a;
end

return;