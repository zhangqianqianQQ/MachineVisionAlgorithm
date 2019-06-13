function [L, U] = factor(A, rho)
    [m, n] = size(A);
    if m >= n   % assuming this case is more serious in my application
       L = chol(A'*A + rho*eye(size(A,2)), 'lower');
    else
       L = chol(speye(m) + 1/rho*(A*A'), 'lower');
    end

    U = L';
end