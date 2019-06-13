function ndx = sub2indFast(siz, varargin)
% ndx = sub2indFast(siz, varargin)
%
% Like sub2ind but without time-intensive checks.
%
% Copyright by Mathworks
% Modified by Holger Caesar, 2014

assert(all(numel(siz) == numel(varargin)));

%Compute linear indices
k = [1, cumprod(siz(1:end-1))];
ndx = 1;
numOfIndInput = nargin-1;
for i = 1:numOfIndInput
    v = varargin{i};
    ndx = ndx + (double(v)-1) * k(i);
end
