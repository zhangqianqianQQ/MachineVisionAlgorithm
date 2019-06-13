function x = thomas(varargin)
% THOMAS    Solves a tridiagonal linear system
%
%    x = THOMAS(A,d) solves a tridiagonal linear system using the very efficient
%    Thomas Algorith. The vector x is the returned answer.
%
%       A*x = d;    /  a1  b1   0   0   0   ...   0  \   / x1 \    / d1 \
%                   |  c1  a2  b2   0   0   ...   0  |   | x2 |    | d2 |
%                   |   0  c2  a3  b3   0   ...   0  | x | x3 | =  | d3 |
%                   |   :   :   :   :   :    :    :  |   | x4 |    | d4 |
%                   |   0   0   0   0 cn-2 an-1 bn-1 |   | :  |    |  : |
%                   \   0   0   0   0   0  cn-1  an /    \ xn /    \ dn /
%
%   - The matrix A must be strictly diagonally dominant for a stable solution.
%   - This algorithm solves this system on (5n-4) multiplications/divisions and
%      (3n-3) subtractions.
%
%   x = THOMAS(a,b,c,d) where a is the diagonal, b is the upper diagonal, and c is 
%       the lower diagonal of A also solves A*x = d for x. Note that a is size n 
%       while b and c is size n-1.
%       If size(a)=size(d)=[L C] and size(b)=size(c)=[L-1 C], THOMAS solves the C
%       independent systems simultaneously.
%   
%
%   ATTENTION : No verification is done in order to assure that A is a tridiagonal matrix.
%   If this function is used with a non tridiagonal matrix it will produce wrong results.
%
%   The form x = THOMAS(a,b,c,d) is much more efficient than the THOMAS(A,d).
%

[a,b,c,d] = parse_inputs(varargin{:});

% Initialization
m = zeros(size(a));
l = zeros(size(c));
y = zeros(size(d));
n = size(a,1);

%1. LU decomposition ________________________________________________________________________________
%
% L = / 1                \     U =  / m1  r1              \
%     | l1 1             |          |     m2 r2           |
%     |    l2 1          |          |        m3 r3        |
%     |     : : :        |          |         :  :  :     |
%     \           ln-1 1 /          \                  mn /
%
%  ri = bi -> not necessary 
m(1,:) = a(1,:);

y(1,:) = d(1,:); %2. Forward substitution (L*y=d, for y) ____________________________

for i = 2 : n
   i_1 = i-1;
   l(i_1,:) = c(i_1,:)./m(i_1,:);
   m(i,:) = a(i,:) - l(i_1,:).*b(i_1,:);
   
   y(i,:) = d(i,:) - l(i_1,:).*y(i_1,:); %2. Forward substitution (L*y=d, for y) ____________________________
    
end
%2. Forward substitution (L*y=d, for y) ______________________________________________________________
%y(1) = d(1);
%for i = 2 : n
%   y(i,:) = d(i,:) - l(i-1,:).*y(i-1,:);
%end

%3. Backward substitutions (U*x=y, for x) ____________________________________________________________
x(n,:) = y(n,:)./m(n,:);
for i = n-1 : -1 : 1
   x(i,:) = (y(i,:) - b(i,:).*x(i+1,:))./m(i,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,c,d] = parse_inputs(varargin)

if nargin == 4
   a = varargin{1};
   b = varargin{2};
   c = varargin{3};
   d = varargin{4};
elseif nargin == 2
   A = sparse(varargin{1});
   a = diag(A);
   b = diag(A,1);
   c = diag(A,-1);
   d = varargin{2};
else
   error('Incorrect number of inputs.')
end