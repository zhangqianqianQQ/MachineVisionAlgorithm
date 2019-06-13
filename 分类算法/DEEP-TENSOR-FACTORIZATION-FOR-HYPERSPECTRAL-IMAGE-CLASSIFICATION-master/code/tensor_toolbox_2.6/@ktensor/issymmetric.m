function [tf,diffs] = issymmetric(X)
%ISSYMMETRIC Verify that a ktensor X is symmetric in all modes.
%
%   TF = ISSYMMETRIC(X) returns true if X is exactly symmetric for every
%   permutation.
%
%   [TF,DIFFS] = ISSYMMETRIC(X) also returns the matrix of the norm of the
%   differences between the normalized factor matrices.
%
%   See also SYMMETRIZE.
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

%T. Kolda, June 2014.

n = ndims(X);
sz = size(X);
diffs = zeros(n,n);

for i = 1:n
    for j = i+1:n
        if ~isequal(size(X.u{i}), size(X.u{j}))
            diffs(i,j) = Inf;            
        elseif isequal(X.u{i},X.u{j})
            diffs(i,j) = 0;
        else
            diffs(i,j) = norm(X.u{i} - X.u{j});
        end
    end
end

tf = all(diffs(:) == 0);
