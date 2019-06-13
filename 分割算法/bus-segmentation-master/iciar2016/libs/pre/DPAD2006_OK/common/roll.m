function Y = roll(varargin)
% ROLL   Rolls matrix elements.
%    y = ROLL(x,[Ri]) rolls matrix x Ri elements in dimension i.
%    The rolled matrix y is the same size as x. The last element
%    in each dimension is repeated to fill blank places
%
%    Example: ROLL([1 2 3 4],1) = [1 1 2 3]
%             ROLL([1 2 3 4], -1) = [2 3 4 4]
%             ROLL([1  2  3  4]          [1 1 2 3]
%                  [5  6  7  8]        = [1 1 2 3]
%                  [9 10 11 12],[1 1])   [5 5 6 7]
%
%    If ndims(x)>1, ROLL(x,N) == ROLL(x,N*ones(1,ndims(x)))
%
%    ROLL(x,[Ri],'rot') rotates the elements instead of 
%    discarding them.
%      Example: ROLL([1 2 3 4],1,'rot') = [4 1 2 3]
% 

[X,R,ROT] = parse_inputs(varargin{:});

Y = zeros(size(X));

ind = cell(length(R),1);

if ROT == 1 % rotate elements
   R = mod(abs(R),size(X)).*sign(R); % Eliminates complete rotations
   for i = 1 : length(R)
      if R(i) >= 0
         ind{i} = [size(X,i)-R(i)+1:size(X,i) 1:size(X,i)-R(i)];
      else
         ind{i} = [1-R(i):size(X,i) 1:-R(i)];
      end
   end   
else %% if ROT == 0
   for i = 1 : length(R)
      if R(i) >= 0
         ind{i} = [repmat(1,[1 R(i)]) 1:size(X,i)-R(i)];
      else
         ind{i} = [1-R(i):size(X,i) repmat(size(X,i),[1 -R(i)])];
      end
   end
end

Y = X(ind{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,R,ROT] = parse_inputs(varargin)
ROT = 0;
switch nargin
case 0
   error('Too few arguments')
   
case 1
   X = varargin{1};
   R = 1;
   
case 2
   X = varargin{1};
   R = varargin{2};
   
case 3
   X = varargin{1};
   R = varargin{2};
   if strcmp(lower(varargin{3}),'rot')
      ROT = 1;
   else
      error('Unknown parameter.')   
   end
   
case 4
   error('Too many parameters')   
end   

if length(R)==1
   R = R*ones(1,ndims(X));
   if sum(size(X)>1)==1 % X is vector
      R(size(X)==1) = 0;
   end
end

if ndims(X) ~= length(R)
   error('Incompatible dimensions!')
end

if any((size(X)-abs(R)-1)<0) & ROT == 0
   error('Rolling bigger the matrix size')
   return
end