function Y = euclideanloss(X, c, dzdy)
%EUCLIDEANLOSS Summary of this function goes here
%   Detailed explanation goes here

%assert(numel(X) == numel(c));

sz = [size(X,1) size(X,2) size(X,3) size(X,4)] ;

if numel(c) == sz(4)
  % one label per image
  c = reshape(c, [1 1 1 sz(4)]) ;
end
if size(c,1) == 1 & size(c,2) == 1
  c = repmat(c, [sz(1) sz(2)]) ;
end

% one label per spatial location
sz_ = [size(c,1) size(c,2) size(c,3) size(c,4)] ;
assert(isequal(sz_, [sz(1) sz(2) sz_(3) sz(4)])) ;
assert(sz_(3)==1 | sz_(3)==2) ;


mass = double(c(:,:,1,:));
mass(:) = 1;
if sz_(3) == 2
  % the second channel of c (if present) is used as weights
  mass = double(c(:,:,2,:));
  c(:,:,2,:) = [] ;
end

diff = (X - c).*mass;

if nargin == 2 || (nargin == 3 && isempty(dzdy))
    
    Y =  1/2 * diff(:)' * diff(:);
    
    %Y = 1 / (2*prod(d(1:3))) * diff(:)' * diff(:);
    %Y = 1 / 2 * sum(subsref((X - c) .^ 2, substruct('()', {':'}))); % Y is divided by d(4) in cnn_train.m / cnn_train_mgpu.m.
    %Y = 1 / (2 * prod(d(1 : 3))) * sum(subsref((X - c) .^ 2, substruct('()', {':'}))); % Should Y be divided by prod(d(1 : 3))? It depends on the learning rate.
    
elseif nargin == 3 && ~isempty(dzdy)
    
    assert(numel(dzdy) == 1);
    
    Y = dzdy * diff; % Y is divided by d(4) in cnn_train.m / cnn_train_mgpu.m.
    %     Y = dzdy / prod(d(1 : 3)) * (X - c); % Should Y be divided by prod(d(1 : 3))? It depends on the learning rate.
    
end

end

