function [x,pca_x,pca_coeff] = preprocess(x)
    [pca_coeff,pca_x,latent] = pca(x);
end