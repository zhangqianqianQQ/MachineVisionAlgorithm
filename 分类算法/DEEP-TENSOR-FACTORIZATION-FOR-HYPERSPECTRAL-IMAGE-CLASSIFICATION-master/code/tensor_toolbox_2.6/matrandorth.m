function M=matrandorth(n, tol)
%MATRANDORTH Generates random n x n orthogonal real matrix.
%
%   M = MATRANDORTH(N) generates a random N x N orthogonal real matrix.
%
%   M = MATRANDORTH(M,TOL) explicitly specifies a threshold value, TOL,
%   that measures linear dependence of a newly formed column with the
%   existing columns. Defaults to 1e-6. 
%
%   In this version the generated matrix distribution *is* uniform over the
%   manifold O(n) w.r.t. the induced R^(n^2) Lebesgue measure, at a slight
%   computational overhead (randn + normalization, as opposed to rand ). 
% 
%   NOTE: This code is renamed from RANDORTHMAT by Olef Shilon.
%
%  (c) Ofek Shilon, 2006.
%
%This code is *not* copyrighted by Sandia, but it is distributed with:
%
%   See also MATRANDNORM, MATRANDCONG, CREATE_PROBLEM, CREATE_GUESS.
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



    if nargin==1
	  tol=1e-6;
    end
    
    M = zeros(n); % prealloc
    
    % gram-schmidt on random column vectors
    
    vi = randn(n,1);  
    % the n-dimensional normal distribution has spherical symmetry, which implies
    % that after normalization the drawn vectors would be uniformly distributed on the
    % n-dimensional unit sphere.

    M(:,1) = vi ./ norm(vi);
    
    for i=2:n
	  nrm = 0;
	  while nrm<tol
		vi = randn(n,1);
		vi = vi -  M(:,1:i-1)  * ( M(:,1:i-1).' * vi )  ;
		nrm = norm(vi);
	  end
	  M(:,i) = vi ./ nrm;

    end %i
        
end  % RandOrthMat
    
