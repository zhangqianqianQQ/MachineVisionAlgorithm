% Script to test INSIDEPOLY

n = 3e2; % number of points
m = 5; % number of vertices

xv = zeros(m,1);
yv = zeros(m,1);

fprintf('Use the mouse and enter %d points of the polygonal\n', m);

figure;
axis equal
axis([0 1 0 1]);
hold on
k = 1;
while k<=m
    [xv(k) yv(k)] = ginput(1);
    if k>1
        plot(xv(k+[-1 0]),yv(k+[-1 0]),'-r');
    else
        plot(xv(1),yv(1),'.r');
    end
    axis([0 1 0 1]);
    k = k+1;
end
plot(xv([end 1]),yv([end 1]),'-r');

x = rand(n,1);
y = rand(n,1);

% xv = [-1 -1 1 1];
% yv = [-1 1 1 -1];
% x=linspace(-2,2,33);
% y=linspace(-2,2,33);
% [x y]=meshgrid(x,y);

in = insidepoly(x, y, xv, yv);

plot(xv([1:end 1]),yv([1:end 1]),'-r');
linestyle={'b.' 'ro'};
hold on
for k=1:numel(x)
    plot(x(k),y(k),linestyle{in(k)+1});
end
drawnow;

%% benchmark
%t = benchinpoly(xv, yv, 100);

