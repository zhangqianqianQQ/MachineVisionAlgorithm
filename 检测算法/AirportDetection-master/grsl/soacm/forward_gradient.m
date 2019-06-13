function [dy,dx] = forward_gradient(f)
    [row,col] = size(f);
    dx = zeros(row,col);
    dy = zeros(row,col);

    a = f(2:row,:) - f(1:row-1,:);
    dx(1:row-1,:) = a;
    b = f(:,2:col)-f(:,1:col-1);
    dy(:,1:col-1) = b;
end
