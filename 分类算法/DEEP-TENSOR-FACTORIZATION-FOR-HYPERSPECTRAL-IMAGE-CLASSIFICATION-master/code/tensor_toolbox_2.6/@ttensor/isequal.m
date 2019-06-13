function [tf, tf_core, tf_U] = isequal(A,B)
%ISEQUAL True if the part of two ttensor's are numerically equal.
%
%   TF = ISEQUAL(A,B) returns true if each factor matrix and the core
%   are equal for A and B.  
%
%   [TF, TF_CORE, TF_FACTORS] = ISEQUAL(A,B) returns also the result of
%   comparing the core (TF_CORE) and an array with the results of comparing
%   the factor matrices (TF_FACTORS).
%
%    See also TTENSOR.
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

tf = false;
tf_core = false;
tf_U = false;

if ~isa(B,'ttensor')
    return;
end

if ndims(A) ~= ndims(B)
    return;
end

tf_core = isequal(A.core, B.core);
tf_U = cellfun(@isequal, A.u, B.u);
tf = tf_core & all(tf_U);

