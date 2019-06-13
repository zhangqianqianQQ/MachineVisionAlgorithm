function [ Mean, dev_images, Eigenfaces ] = eigenfaces(T, Eigen_Threshold)

% Calculate the mean image 
Mean = mean(T,2); 
Train_Number = size(T,2);


% Calculate the deviation of each image from mean image
dev_images = [];  
for i = 1 : Train_Number
    temp = double(T(:,i)) - Mean; 
    dev_images = [dev_images temp]; 
end


% we can calculate eigenvalues of A'*A (a PxP matrix) instead of
% A*A' (a M*NxN*M matrix) because the dimensions of A*A' is much
% larger that A'*A. So the dimensionality will decrease.

Csmall = dev_images'*dev_images; 
[V D] = svd(Csmall); 

% eliminating eigenvalues
% All eigenvalues of matrix which are less than a
% specified threshold, are eliminated.  

c_eigvec = [];
for i = 1 : size(V,2) 
    if( D(i,i)> Eigen_Threshold )
        c_eigvec = [c_eigvec V(:,i)];
    end
end


Eigenfaces = dev_images * c_eigvec; 
end

