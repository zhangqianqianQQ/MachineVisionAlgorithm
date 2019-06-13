function XPCANorm = PCANorm(X, num_component)

% X  size: num_sample * num_feature

X_norm = bsxfun(@minus,X,mean(X));

Sigma = X_norm'*X_norm/size(X_norm,1);

[U S V] = svd(Sigma);

XPCANorm = X_norm * U(:,1:num_component);

% XPCANorm = bsxfun(@rdivide,bsxfun(@minus,XPCANorm,mean(XPCANorm,1)),std(XPCANorm,0,1));

% minZ = min(XPCANorm);
% maxZ = max(XPCANorm);
% XPCANorm = bsxfun(@minus, XPCANorm, minZ);
% XPCANorm = bsxfun(@rdivide, XPCANorm, maxZ-minZ);
end