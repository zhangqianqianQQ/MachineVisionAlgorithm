function B = mirror_expand(A)
    [row,col,channel] = size(A);
    yi = 2:row+1;
    xi = 2:col+1;
    B = zeros(row+2,col+2,channel);
    B(yi,xi,:) = A;
    B([1 row+2],[1 col+2],:) = B([3 row],[3 col],:);  % mirror corners
    B([1 row+2],xi,:) = B([3 row],xi,:);          % mirror left and right boundary
    B(yi,[1 col+2],:) = B(yi,[3 col],:);          % mirror top and bottom boundary
end

