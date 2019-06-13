function p=gaussian(x,m,C);


d=length(m);

if size(x,1)~=d
   x=x';
end
N=size(x,2);

detC = det(C);
if rcond(C)<eps
%   fprintf(1,'Covariance matrix close to singular. (gaussian.m)\n');
   p = zeros(N,1);
else
   m=m(:);
   M=m*ones(1,N);
   denom=(2*pi)^(d/2)*sqrt(abs(detC));
   mahal=sum(((x-M)'*inv(C)).*(x-M)',2);   % Chris Bregler's trick
   numer=exp(-0.5*mahal);
   p=numer/denom;
end

