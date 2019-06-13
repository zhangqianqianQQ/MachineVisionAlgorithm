% Uniform on a Moebius'string
function [data] = mobius_rotate(N)
 r = 3; R = 10;
%r = 5; R = 15;
%np = 100; nr = 20;
%N = 2000;
 

xi = rand(N,1);
eta = rand(N,1);
rho = (1-2*xi)*r;
theta = pi*eta;
%for k=1:10
theta = pi*eta+rho./R.*cos(theta);
%end
x = (R+rho.*sin(theta)).*cos(2*theta);
y = (R+rho.*sin(theta)).*sin(2*theta);
z = rho.*cos(theta); 
x_r=x+8;
y_r=y+8;
z_r=z;


% figure;
% plot3(x,y,z,'b.')
% hold on 
% plot3(x_r,y_r,z_r,'r.')
% axis('equal');
X1=[x';y';z'];
X2=[x_r';y_r';z_r'];
X_P=[X1,X2];
data=X_P;
