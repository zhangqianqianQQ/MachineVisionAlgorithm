function [sphere_normal]=sphere(n)
if nargin<1
    n=1000;
end
% u=linspace(0,2*pi-1000,n);
% v=linspace(0,pi,n);
u=2*pi*rand(1,n);
v=pi*rand(1,n);
a=1;b=1;c=1;
x=a.*cos(u).*sin(v);
y=b.*sin(u).*sin(v);
z=c.*cos(v);
X=[x;y;z];
X=2*X;

figure;
plot3(X(1,:),X(2,:),X(3,:),'r.');
axis equal;

sphere_normal=[2*x;2*y;2*z];
for i=1:size(sphere_normal,2)
    sphere_normal(:,i)=sphere_normal(:,i)./norm(sphere_normal(:,i));
end
size(X)

