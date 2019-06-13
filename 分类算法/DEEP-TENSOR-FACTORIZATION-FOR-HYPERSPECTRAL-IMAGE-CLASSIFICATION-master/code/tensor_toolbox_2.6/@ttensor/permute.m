function b = permute(a,order)
%PERMUTE Permute dimensions for a ttensor.
%
%   Y = PERMUTE(X,ORDER) rearranges the dimensions of X so that they
%   are in the order specified by the vector ORDER. The tensor
%   produced has the same values of X but the order of the subscripts
%   needed to access any particular element are rearranged as
%   specified by ORDER.  
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

N = ndims(a);

if ~isequal(1:N,sort(order))
  error('Invalid permuation');
end

newcore = permute(a.core,order);
newu = a.u(order);
b = ttensor(newcore,newu);




