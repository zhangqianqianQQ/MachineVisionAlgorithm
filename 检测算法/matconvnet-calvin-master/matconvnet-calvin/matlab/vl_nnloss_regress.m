function Y = vl_nnloss_regress(X, t, dzdy, varargin)
% vl_nnloss_regress(X, t, dzdy, varargin)
%
% Performs loss incurred by the predicted values X with respect
% to the target values t.
%
% It is assumed that each vector in X is aligned w.r.t. its last dimension:
% 2-dimensional vectors are row vectors
% 3-dimensional vectors are aligned in the z-axis
% 
% Possible loss: {'L1', 'L2', and 'Smooth'}, where Smooth is L2 up until the
% but the maximum derivative with respect to the loss is capped to +/-
% opts.smoothMaxDiff. For opts.smoothMaxDiff = 1, smooth is L2 when |X| < 1 and L1
% otherwise. This form of smooth was used by Girshick to be less insensitive to outliers 
% while having more sensible gradient updates close to the target. The version here
% is more flexible.
%
% Jasper - 2015

% Set standard parameters
opts.instanceWeights = []; 
opts.loss = 'L2';
opts.smoothMaxDiff = 1;
opts = vl_argparse(opts, varargin);

if isempty(opts.instanceWeights)
    instanceWeights = ones(size(X, ndims(X)), 1, 'single');
else
    instanceWeights = opts.instanceWeights;
end

% Display warning once
warning('NotTested:regressloss', ...
    'No loss has been thoroughly tested yet');
warning('off', 'NotTested:regressloss');

assert(isequal(size(X), size(t)));

% Just compute loss
if nargin == 2 || isempty(dzdy)
    switch lower(opts.loss)
        case 'l2'
            diff = X - t;
            Y = diff .* diff / 2;
        case 'l1'
            Y = abs(X - t);
        case 'smooth'
            diff = X - t;
            
            % Loss is L2 for part below opts.smoothMaxDiff and L1 for above.
            diffT = diff;
            maskTooHigh = (diff > opts.smoothMaxDiff);
            maskTooLow = (diff < -opts.smoothMaxDiff);
            diffT(maskTooHigh) = opts.smoothMaxDiff;
            diffT(maskTooLow) = -opts.smoothMaxDiff;            
            squaredPart = (diffT .* diffT / 2);
            
            nonSquaredPart = zeros(size(squaredPart), 'like', X);
            nonSquaredPart(maskTooHigh) =  diff(maskTooHigh) - opts.smoothMaxDiff;
            nonSquaredPart(maskTooLow)  = -diff(maskTooLow)  - opts.smoothMaxDiff;
            nonSquaredPart = nonSquaredPart * opts.smoothMaxDiff; % Derivative of loss is opts.smoothMaxDiff
            
            Y = squaredPart + nonSquaredPart;            
        otherwise
            error('Incorrect loss: %s', opts.loss);
    end
    % Sum loss in all dimensions but the last
    for i=1:ndims(Y)-1
        Y = sum(Y, i);
    end
    
    % Weight loss using instanceWeights
    Y = instanceWeights(:)' * Y(:);
else
    % Get derivatives w.r.t. loss function
    switch lower(opts.loss)
        case 'l2'
            Y = dzdy * (X-t);
        case 'l1'
            Y = dzdy * sign(X-t);
        case 'smooth'
            diff = X-t;
            diff(diff > opts.smoothMaxDiff) = opts.smoothMaxDiff;
            diff(diff < -opts.smoothMaxDiff) = -opts.smoothMaxDiff;
            Y = dzdy * (diff);
        otherwise
            error('Incorrect loss: %s', opts.loss);
    end
    
    % Get instanceWeights in the right shape (aligned according to last dimension)
    iwSize = ones(1, ndims(Y));
    iwSize(end) = length(instanceWeights);
    instanceWeights = reshape(instanceWeights, iwSize);
    
    % Perform instance weighting
    Y = bsxfun(@times, Y, instanceWeights);
    
end
