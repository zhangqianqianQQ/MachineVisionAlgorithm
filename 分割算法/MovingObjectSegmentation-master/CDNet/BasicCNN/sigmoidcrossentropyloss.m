function Y = sigmoidcrossentropyloss(X, c, dzdy)
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

% Getting the weights
mass = double(c(:,:,1,:));
mass(:) = 1;
if sz_(3) == 2
  % the second channel of c (if present) is used as weights
  mass = double(c(:,:,2,:));
  c(:,:,2,:) = [] ;
end

mass = single(mass);
c = single(c);

%p     = sigmoid(c);
p_hat = sigmoid(X);

eps = 1e-4;

%sz = [size(X,1),size(X,2),size(X,3),size(X,4)];
%n = sz(1) * sz(2);

if nargin == 2 || isempty(dzdy)
    
    Y = -( c.*log(p_hat + eps) + (1-c).*log(1-p_hat + eps) ) .* mass;
    Y = sum(Y(:));
    
%    Y = -sum(subsref(c * log(p_hat) + (1 - c) * log(1 - p_hat), substruct('()', {':'}))); % Y is divided by d(4) in cnn_train.m / cnn_train_mgpu.m.
%     Y = -1 / prod(d(1 : 3)) * sum(subsref(p * log(p_hat) + (1 - p) * log(1 - p_hat), substruct('()', {':'}))); % Should Y be divided by prod(d(1 : 3))? It depends on the learning rate.
    
elseif nargin == 3 && ~isempty(dzdy)
    
    assert(numel(dzdy) == 1);
    
    Y = dzdy * (p_hat - c) .* mass; % Y is divided by d(4) in cnn_train.m / cnn_train_mgpu.m.
    %Y = dzdy / n * (p_hat - c); % Should Y be divided by prod(d(1 : 3))? It depends on the learning rate.
    
end

end

