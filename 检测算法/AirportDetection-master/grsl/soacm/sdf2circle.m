function f = sdf2circle(row,col,ci,cj,radius)
% compute the signed distance to a circle
% input: 
%    row: number of rows
%    col: number of columns
%    ic,jc: center of the circle
%    r: radius of the circle
% output: 
%    f: signed distance to the circle

    [X,Y] = meshgrid(1:col, 1:row);
    f = sqrt((X-cj).^2+(Y-ci).^2) - radius;
end