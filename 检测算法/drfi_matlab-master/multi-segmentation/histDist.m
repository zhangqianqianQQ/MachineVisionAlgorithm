function dist = histDist(h1, h2, method)
    if nargin == 2
        method = 'x2';
    end
    
    % normalize
    h1 = h1 / (sum(h1(:)) + eps);
    h2 = h2 / (sum(h2(:)) + eps);
    
    dist = 0;
    
    switch method
        case 'x2'
            dist = sum((h1-h2).^2 ./ (h2+h1+eps)) / 2;
    end
    