function [ Feats, projection ] = BestFeats(Features, varianceThreshold)
    featureSize = size(Features,2);
    
    % Perform Mean Normalization on the Feature Matrix.
    % Each pixel can have intensity values from 0 - 255
    for i = 1 : featureSize
        Features(:,i) = Features(:,i) - mean(Features(:,i));
    end
    
    % Get the Covariance Matrix.
    % We will know how each pixel is correlated with other pixels.
    sigma = 0.5 .* (Features' * Features);
    
    % Find The Singular Value Decomposition of the covariance Matrix
    [U, S, ~] = svd(sigma);
    
    % Find Sum of All Eigen Values
    numOfEigenValues = length(S);
    sumOfEigen = zeros(numOfEigenValues,1);
    for i = 1 : numOfEigenValues
        if i == 1
            sumOfEigen(i) = S(i,i);
        else
            sumOfEigen(i) = sumOfEigen(i-1) + S(i,i);
        end
    end
    
    % Find the minimum dimensions to retain the varianceThreshold
    dimension = 100;
    for i = 100 : numOfEigenValues
        sum = sumOfEigen(i);
        varianceRetained = sum / sumOfEigen(numOfEigenValues);
        if varianceRetained > varianceThreshold
            dimension = i;
            break;
        end
    end
    
    % Project the Features on the new dimension
    projection = U(:,1:dimension)';
    Feats = projection * Features';
    Feats = Feats';
end