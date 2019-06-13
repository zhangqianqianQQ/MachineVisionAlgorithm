%KTENSOR Class for Kruskal tensors (decomposed).
%
%KTENSOR Methods:
%   arrange      - Arranges the rank-1 components of a ktensor.
%   datadisp     - Special display of a ktensor.
%   disp         - Command window display for a ktensor.
%   display      - Command window display for a ktensor.
%   double       - Convert a ktensor to a double array.
%   end          - Last index of indexing expression for ktensor.
%   extract      - Creates a new ktensor with only the specified components.
%   fixsigns     - Fix sign ambiguity of a ktensor.
%   full         - Convert a ktensor to a (dense) tensor.
%   innerprod    - Efficient inner product with a ktensor.
%   isequal      - True if each datum of two ktensor's are numerically equal.
%   issymmetric  - Verify that a ktensor X is symmetric in all modes.
%   ktensor      - Tensor stored as a Kruskal operator (decomposed).
%   minus        - Binary subtraction for ktensor.  
%   mtimes       - Implement A*B (scalar multiply) for ktensor.
%   mttkrp       - Matricized tensor times Khatri-Rao product for ktensor.
%   ncomponents  - Number of components for a ktensor.
%   ndims        - Number of dimensions for a ktensor.
%   norm         - Frobenius norm of a ktensor.
%   normalize    - Normalizes the columns of the factor matrices.
%   nvecs        - Compute the leading mode-n vectors for a ktensor.
%   permute      - Permute dimensions of a ktensor.
%   plus         - Binary addition for ktensor.
%   redistribute - Distribute lambda values to a specified mode. 
%   score        - Checks if two ktensors match except for permutation.
%   size         - Size of ktensor.
%   subsasgn     - Subscripted assignement for ktensor.
%   subsref      - Subscripted reference for a ktensor.
%   symmetrize   - Symmetrize a ktensor X in all modes.
%   times        - Element-wise multiplication for ktensor.
%   tocell       - Convert X to a cell array.
%   ttm          - Tensor times matrix for ktensor.
%   ttv          - Tensor times vector for ktensor.
%   uminus       - Unary minus for ktensor. 
%   uplus        - Unary plus for a ktensor. 
%
% See also
%   TENSOR_TOOLBOX

function t = ktensor(varargin)
%KTENSOR Tensor stored as a Kruskal operator (decomposed).
%
%   K = KTENSOR(lambda,U1,U2,...,UM) creates a Kruskal tensor from its
%   constituent parts. Here lambda is a k-vector and each Um is a
%   matrix with k columns.
%
%   K = KTENSOR(lambda, U) is the same as above except that U is a
%   cell array containing matrix Um in cell m.
%
%   K = KTENSOR(U) assumes U is a cell array containing matrix Um in
%   cell m and assigns the weight of each factor to be one.
%
%   K = KTENSOR(T) creates a ktensor by copying an existing ktensor.
%
%   K = KTENSOR(S) creates a ktensor from a symktensor.
%
%   Examples
%   K = ktensor([3; 2], rand(4,2), rand(5,2), rand(3,2))
%
%   See also KTENSOR, CP_ALS, CP_OPT, CP_WOPT, CP_APR.
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


% EMPTY CONSTRUCTOR
if nargin == 0
    t.lambda = [];
    t.u = {};
    t = class(t,'ktensor');
    return;
end

% Copy CONSTRUCTOR
if (nargin == 1) && isa(varargin{1}, 'ktensor')
    t.lambda = varargin{1}.lambda;
    t.u = varargin{1}.u;
    t = class(t, 'ktensor');
    return;
end


% CONSTRUCTOR from SYMKTENSOR
if (nargin == 1) && isa(varargin{1}, 'symktensor')
    t.lambda = varargin{1}.lambda;
    [t.u{1:varargin{1}.m}] = deal(varargin{1}.u);
    t = class(t, 'ktensor');
    return;
end

if isa(varargin{1},'cell')

    u = varargin{1};
    t.lambda = ones(size(u{1},2),1);
    t.u = u;
    
else

    t.lambda = varargin{1};
    if ~isa(t.lambda,'numeric') || ndims(t.lambda) ~=2 || size(t.lambda,2) ~= 1
	error('LAMBDA must be a column vector.');
    end
    
    if isa(varargin{2},'cell')
	t.u = varargin{2};
    else
	for i = 2 : nargin
	    t.u{i-1} = varargin{i};
	end
    end

end
    
    
% Check that each Um is indeed a matrix
for i = 1 : length(t.u)
    if ndims(t.u{i}) ~= 2
	error(['Matrix U' int2str(i) ' is not a matrix!']);
    end
end

% Size error checking			     
k = length(t.lambda); 
for i = 1 : length(t.u)            
    if  size(t.u{i},2) ~= k
       error(['Matrix U' int2str(i) ' does not have ' int2str(k) ' columns.']);
    end
end

t = class(t, 'ktensor');
return;
