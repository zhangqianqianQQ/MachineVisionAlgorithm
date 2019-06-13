function [dy,dx] = backward_gradient(f)
    [row,col] = size(f);
    dx = zeros(row,col);
    dy = zeros(row,col);
    dx(2:row,:) = f(2:row,:) - f(1:row-1,:);
    dy(:,2:col) = f(:,2:col) - f(:,1:col-1);
end