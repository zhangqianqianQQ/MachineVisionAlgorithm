function V = mttkrp(X,U,n,vers)
%MTTKRP Matricized tensor times Khatri-Rao product for tensor.
%
%   V = MTTKRP(X,U,n) efficiently calculates the matrix product of the
%   n-mode matricization of X with the Khatri-Rao product of all
%   entries in U, a cell array of matrices, except the nth.  How to
%   most efficiently do this computation depends on the type of tensor
%   involved.
%
%   NOTE: Updated to use BSXFUN per work of Phan Anh Huy. See Anh Huy Phan,
%   Petr Tichavský, Andrzej Cichocki, On Fast Computation of Gradients for
%   CANDECOMP/PARAFAC Algorithms, arXiv:1204.1586, 2012.
%
%   See also TENSOR, TENMAT, KHATRIRAO
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt

% Multiple versions supported...
if ~exist('vers','var')
    vers = 1;
end

N = ndims(X);
if (N < 2)
    error('MTTKRP is invalid for tensors with fewer than 2 dimensions');
end

if (length(U) ~= N)
    error('Cell array is the wrong length');
end

if n == 1
    R = size(U{2},2);
else
    R = size(U{1},2);
end

for i = 1:N
   if i == n, continue; end
   if (size(U{i},1) ~= size(X,i)) || (size(U{i},2) ~= R)
       error('Entry %d of cell array is wrong size', i);
   end
end

%% Computation

if vers == 0 % Old version of the code
    Xn = permute(X,[n 1:n-1,n+1:N]);
    Xn = reshape(Xn.data, size(X,n), []);
    Z = khatrirao(U{[1:n-1,n+1:N]},'r');
    V = Xn*Z;
    return;
end

szl = prod(size(X,1:n-1)); %#ok<*PSIZE>
szr = prod(size(X,n+1:N));
szn = size(X,n);

if n == 1
    Ur = khatrirao(U{2:N},'r');
    Y = reshape(X.data,szn,szr);
    V =  Y * Ur;
elseif n == N
    Ul = khatrirao(U{1:N-1},'r');
    Y = reshape(X.data,szl,szn);
    V = Y' * Ul;
else
    Ul = khatrirao(U{n+1:N},'r');
    Ur = reshape(khatrirao(U{1:n-1},'r'), szl, 1, R);
    Y = reshape(X.data,[],szr);
    Y = Y * Ul;
    Y = reshape(Y,szl,szn,R);
    if vers == 2
        V = bsxfun(@times,Ur,Y);
        V = reshape(sum(V,1),szn,R);
    else % default (vers == 1)
        V = zeros(szn,R);
        for r =1:R
            V(:,r) = Y(:,:,r)'*Ur(:,:,r);
        end
    end
end

