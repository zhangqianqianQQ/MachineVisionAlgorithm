%TTENSOR Class for Tucker tensors (decomposed).
%
%TTENSOR Methods:
%   disp      - Command window display of a ttensor.
%   display   - Command window display of a ttensor.
%   double    - Convert ttensor to double array.
%   end       - Last index of indexing expression for ttensor.
%   full      - Convert a ttensor to a (dense) tensor.
%   innerprod - Efficient inner product with a ttensor.
%   isequal   - True if the part of two ttensor's are numerically equal.
%   mtimes    - Implement scalar multiplication for a ttensor.
%   mttkrp    - Matricized tensor times Khatri-Rao product for ttensor.
%   ndims     - Return the number of dimensions for a ttensor.
%   norm      - Norm of a ttensor.
%   nvecs     - Compute the leading mode-n vectors for a ttensor.
%   permute   - Permute dimensions for a ttensor.
%   size      - Size of a ttensor.
%   subsasgn  - Subscripted reference for a ttensor.
%   subsref   - Subscripted reference for a ttensor.
%   ttensor   - Tensor stored as a Tucker operator (decomposed).
%   ttm       - Tensor times matrix for ttensor.
%   ttv       - Tensor times vector for ttensor.
%   uminus    - Unary minus for ttensor.
%   uplus     - Unary plus for ttensor.
%
% See also
%   TENSOR_TOOLBOX

function t = ttensor(varargin)
%TTENSOR Tensor stored as a Tucker operator (decomposed).
%
%   T = TTENSOR(G,U1,U2,...,UM) creates a TUCKER tensor from its
%   constituent parts. Here G is a tensor of size K1 x K2 x ... x KM
%   and each Um is a matrix with Km columns.
%
%   T = TTENSOR(G,U) is the same as above except that U is a cell
%   array containing matrix Um in cell m.
%
%   The core tensor G can be any type of tensor that supports the
%   following functions:
%     - size
%     - uminus
%     - disp (with 2 arguments; see, e.g., TENSOR/DISP)
%     - ttv
%     - ttm
%     - mtimes (scalar multiplication only)
%     - permute
%     - subsasgn
%     - subsref
%   
%   T = TTENSOR(S) creates a TUCKER tensor by copying an existing
%   TUCKER tensor.
%
%   T = TTENSOR is the empty constructor.
%
%   See also TTENSOR, TUCKER_ALS.
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

% Empty constructor
if (nargin == 0)
    t.core = tensor;                    % empty tensor
    t.u = [];
    t = class(t, 'ttensor');
    return;
end

% Copy CONSTRUCTOR
if (nargin == 1) && isa(varargin{1}, 'ttensor')
    t.core = varargin{1}.core;
    t.u = varargin{1}.u;
    t = class(t, 'ttensor');
    return;
end

% Core can be basically anything that supports certain functions.
t.core = varargin{1};

if isa(varargin{2},'cell')
    t.u = varargin{2};
else
    for i = 2 : nargin
	t.u{i-1} = varargin{i};
    end
end

% Check that each Um is indeed a matrix
for i = 1 : length(t.u)
    if ndims(t.u{i}) ~= 2
	error(['Matrix U' int2str(i) ' is not a matrix!']);
    end
end

% Size error checking			     
k = size(t.core); 

if length(k) ~= length(t.u)
    error(['CORE has order ', int2str(length(k)), ...
	   ' but there are ', int2str(length(t.u)), ' matrices.']);
end

for i = 1 : length(t.u)            
    if  size(t.u{i},2) ~= k(i)
	error(['Matrix U' int2str(i) ' does not have ' int2str(k(i)) ...
	       ' columns.']);
    end
end

t = class(t, 'ttensor');
return;
