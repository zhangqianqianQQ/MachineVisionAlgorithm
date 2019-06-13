%only for drawing test

f=@(x,y,z)(2*pi)^-1.5.*exp((x.^2+y.^2+z.^2)/-2).*cos(2*pi*(x))-z;
implicitmesh(f,[-3 3],200);
hold on;

xlabel('x');
ylabel('y');
zlabel('b')
shading interp;
title('指向（1,0,0）方向的Gabor小波');

figure;
fplot('(2*pi)^1.5.*exp(x.^2/-2).*cos(2*pi*x)',[-2,2]);
title('在y=0线上的响应');
xlabel('x');
ylabel('b');