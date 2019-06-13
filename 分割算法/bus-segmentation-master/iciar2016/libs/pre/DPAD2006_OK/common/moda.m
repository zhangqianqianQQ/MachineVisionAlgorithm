function m=moda(u,N)
% MODA   Mode of a distribution
%
%    m=MODE(u,N) calculates the mode of the set of data "u" using the histogram.
%    To avoid outliers, for the calculation are only taken into account those
%    values in [mean-2sigma, mean+2sigma];
%
%    INPUT:
%
%	- u (set of data)
%       - N: Number of points for the histogram. If N=0 then 5000 points are
%            considered
%
%   Author: Santiago Aja Fernandez
%   LOCAL STATISTICS TOOLBOX 
%
%   Modified: Feb 01 2008
%
u=double(u);
if N==0
	N=5000;
end
M1=mean(u(:));
V1=std(u(:));
C2=u( (u(:)>=(M1-2*V1)) & (u(:)<=(M1+2*V1)) ) ;
%C2=u;
[h,x]=hist(C2,N);
[M,M2]=max(h);
m=x(M2);
%
