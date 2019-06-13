function [x,y] = snakeinit(II,delta)
%------In this function, I implemented Canny Operator to initialze initial
%contour line for Active Contour Model----------------

 BW = edge(II,'canny',0.6,0.3);

hold on;
x = [];
y = [];
z =0;
[n,m] = size(BW);
for q = 5:1:n-5
    for p = 5:1:m-5
        if(BW(q,p) == 1)
            z = z+1;
            x(z,1)=p;
            y(z,1)=q;
        end
    end
end
plot(x,y,'b.');

xx = [];
yy = [];
number1 = 0;
for i = 1:z
    if(x(i,1) == min(x(:)))
        number1 = number1 + 1;
        xx(number1,1) = min(x(:))-3;
        yy(number1,1) = y(i,1);
    end
end

for i = 1:z
    if(y(i,1) == max(y(:)))
        number1 = number1 + 1;
        yy(number1,1) = max(y(:))+3;
        xx(number1,1) = x(i,1);
    end
end

number2 = 0;
for i = 1:z
    if(x(i,1) == max(x(:)))
        number2 = number2 + 1;
        number1 = number1 + 1;
    end
end
%number1 = number1+1;
for i = 1:z
   if(x(i,1) == max(x(:)))
        number1 = number1 - 1;
        yy(number1,1) = y(i,1);
        xx(number1,1) = max(x(:))+3;
    end
end
number1 = number1+ number2;

number2 = 0;
for i = 1:z
    if(y(i,1) == min(y(:)))
        number2 = number2 + 1;
        number1 = number1 + 1;
    end
end
%number1 = number1 + 1;
for i = 1:z
   if(y(i,1) == min(y(:)))
        number1 = number1 - 1;
        xx(number1,1) = x(i,1);
        yy(number1,1) = min(y(:))-3;
    end
end

x = [xx;xx(1,1)];
y = [yy;yy(1,1)];
plot(x, y, '-');
hold off
% sampling and record number to N

z=size(x);
x = [x;x(1,1)];
y = [y;y(1,1)];
t = 1:z+1;
ts = [1:delta:z+1]';
xi = interp1(t,x,ts);
yi = interp1(t,y,ts);
n = length(xi);
x = xi(1:z-1);
y = yi(1:z-1);