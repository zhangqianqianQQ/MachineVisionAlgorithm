function [X,helix_tangent]=helix(n)
dim=3;
if nargin<1
n=100;
end
a=1;c=4;
t=linspace(0,c*pi,n);
t=c*pi*rand(1,n);
%t=t./4;
% x=3*cos(t);
% y=3*sin(t);
x=a*cos(t);
y=a*sin(t);

z=t./4;
figure;
X=[x;y;z];
%X=[z;x;y];

plot3(x,y,z,'r.');
xlabel('x');
ylabel('y');
zlabel('z');


helix_tangent=[-a*sin(t)./((sqrt(a.^2+c.^2)));a*cos(t)./(sqrt(a.^2+c.^2));ones(1,n)*(c./(sqrt(a.^2+c.^2)))];
for i=1:size(helix_tangent,2)
    helix_tangent(:,i)=helix_tangent(:,i)./norm(helix_tangent(:,i));
end
