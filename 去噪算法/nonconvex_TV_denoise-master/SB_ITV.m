function u = SB_ITV(g,mu)
% Split Bregman Isotropic Total Variation Denoising
%
%   u = arg min_u 1/2||u-g||_2^2 + mu*ITV(u)
%
% Refs:
%  *Goldstein and Osher, The split Bregman method for L1 regularized problems
%   SIAM Journal on Imaging Sciences 2(2) 2009
%  *Micchelli et al, Proximity algorithms for image models: denoising
%   Inverse Problems 27(4) 2011
%
% Benjamin Tr¨¦moulh¨¦ac
% University College London
% b.tremoulheac@cs.ucl.ac.uk
% April 2012
g = g(:);
n = length(g);
[B Bt BtB] = DiffOper(sqrt(n));
b = zeros(2*n,1);
d = b;
u = g;
err = 1;k = 1;
tol = 1e-3;
lambda = 1;
while err > tol
    fprintf('it. %g ',k);
    up = u;
    [u,~] = cgs(speye(n)+BtB, g-lambda*Bt*(b-d),1e-5,100); 
    Bub = B*u+b; 
    s = sqrt(Bub(1:n).^2 + Bub(n+1:end).^2);
    d = [max(s-mu/lambda,0).*Bub(1:n)./s ;
        max(s-mu/lambda,0).*Bub(n+1:end)./s ];
    b = Bub-d;
    err = norm(up-u)/norm(u);
    fprintf('err=%g \n',err);
    k = k+1;
end
fprintf('Stopped because norm(up-u)/norm(u) <= tol=%.1e\n',tol);
end

function [B Bt BtB] = DiffOper(N)
D = spdiags([-ones(N,1) ones(N,1)], [0 1], N,N+1);
D(:,1) = [];
D(1,1) = 0;
B = [ kron(speye(N),D) ; kron(D,speye(N)) ];
Bt = B';
BtB = Bt*B;
end
