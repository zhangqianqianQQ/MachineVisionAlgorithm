% calculate error between an ellipse and a point
% expected input form : ellipse = [x0 y0 A B alpha], point = [x y]
function error = calcEllipseCost(ellipse, point) 

% Initial setting
x = point(2);   y = point(1);
x0 = ellipse(1);    y0 = ellipse(2);
a = ellipse(4);     b = ellipse(3);
alpha = ellipse(5);
Q = [cos(alpha), sin(alpha); -sin(alpha), cos(alpha)];  % inverse of rotation matrix

% E(x',y') = abs(x'^2/a^2 + y'^2/b^2 - 1)
v = Q*[x-x0;y-y0];
v(1) = v(1)/a;
v(2) = v(2)/b;
error = abs(1-v'*v);

end