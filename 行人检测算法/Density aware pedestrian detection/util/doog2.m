function G=doog2(sig,r,th,N);

no_pts=N;  

[x,y]=meshgrid(-(N/2)+1/2:(N/2)-1/2,-(N/2)+1/2:(N/2)-1/2);

phi=pi*th/180;
sigy=sig;
sigx=r*sig;
R=[cos(phi) -sin(phi); sin(phi) cos(phi)];
C=R*diag([sigx,sigy])*R';

X=[x(:) y(:)];

Gb=gaussian(X,[0 0]',C);
Gb=reshape(Gb,N,N);

m=R*[0 sig]';
Ga=gaussian(X,m,C);
Ga=reshape(Ga,N,N);
Gc=rot90(Ga,2);

a=-1;
b=2;
c=-1;

G = a*Ga + b*Gb + c*Gc;

