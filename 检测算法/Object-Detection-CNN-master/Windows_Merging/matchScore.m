function [ MScore ] = matchScore( xi, X )
%MATCHSCORE Computes the match score between an element xi and all X
%   The match score is a disimilarity score!

    max_dist = xi(5);
    max_intersect = xi(6);
    
    % Compute center of xi
    cxi = [(xi(3)-xi(1))/2 (xi(4)-xi(2))/2];
    % Compute height and width
    xi_height = (xi(4) - xi(2) + 1);
    xi_width = (xi(3) - xi(1) + 1);
    
    % Compute match score for each pair
    nSamples = size(X,1);
    MScore = zeros(nSamples,1);
    for j = 1:nSamples
        xj = X(j,:);
        
        % Compute center of xj
        cxj = [(xj(3)-xj(1))/2 (xj(4)-xj(2))/2];
        % Compute height and width
        xj_height = (xj(4) - xj(2) + 1);
        xj_width = (xj(3) - xj(1) + 1);

        % Get distance
        D = sqrt((abs(cxi(1)-cxj(1)))^2 + (abs(cxi(2)-cxj(2)))^2);
        D = D/max_dist;
        
        % Get intersection
        I = rectint([xi(2), xi(1), xi_height, xi_width], [xj(2), xj(1), xj_height, xj_width]);
        I = I/max_intersect;

        MScore(j) = D+(1-I)/2;
    end

end

