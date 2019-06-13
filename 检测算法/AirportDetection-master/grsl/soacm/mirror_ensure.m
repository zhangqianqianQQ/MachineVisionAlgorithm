function B = mirror_ensure(A)
    [m,n] = size(A);
    if (m<3 || n<3) 
        error('either the number of rows or columns is smaller than 3');
    end
    yi = 2:m-1;
    xi = 2:n-1;
    B = A;
    B([1 m],[1 n]) = B([3 m-2],[3 n-2]);  % mirror corners
    B([1 m],xi) = B([3 m-2],xi);          % mirror left and right boundary  seem error
    B(yi,[1 n]) = B(yi,[3 n-2]);          % mirror top and bottom boundary
end
