function B = mirror_shrink(A)
    [m,n] = size(A);
    yi = 2:m-1;
    xi = 2:n-1;
    B = A(yi,xi);
end

