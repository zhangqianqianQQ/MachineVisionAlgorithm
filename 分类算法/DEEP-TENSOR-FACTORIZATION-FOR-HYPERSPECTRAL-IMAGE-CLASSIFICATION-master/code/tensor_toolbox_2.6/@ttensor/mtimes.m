function C = mtimes(A,B)
%MTIMES Implement scalar multiplication for a ttensor.
%
%   See also TTENSOR.
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

if ~isa(B,'ttensor') && numel(B) == 1
    C = ttensor(B * A.core, A.u);
elseif ~isa(A,'ttensor') && numel(A) == 1
    C = ttensor(A * B.core, B.u);
else
    error('Use mtimes(full(A),full(B)).');
end
