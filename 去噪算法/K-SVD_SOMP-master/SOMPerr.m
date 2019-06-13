function A = SOMPerr(D,X,errorGoal,BETA,LL)

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
E2 = errorGoal^2*n;
% maxNumCoef = K/3;
maxNumCoef = LL;
A = sparse(K,P);
a = [];
residual = X;
indx = [];
currResNorm2 = sum(sum(residual.^2))/P;
j = 0;

while currResNorm2 >E2 && j < maxNumCoef
         
        j = j + 1;
        proj = mean(D' * residual,2) ;
%         proj = sum(proj,2);
        pos = find(abs(proj) == max(abs(proj)));
        pos = pos(1);
        indx(j) = pos;
        a = pinv(D(:,indx(1:j)))*X;
        residual = X - D(:,indx(1:j))*a;
		currResNorm2 = sum(sum(residual.^2))/P;
end
if (~isempty(indx))
       A(indx,:) = a;
end

return;