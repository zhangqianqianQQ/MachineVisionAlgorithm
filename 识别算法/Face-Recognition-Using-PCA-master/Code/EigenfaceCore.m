function [m, A, Eigenfaces] = EigenfaceCore(Training_Data)

%----------------------------Calculate the mean image ------------------------
% ---------------------compute the covariance matrix --------------------------
m = mean(Training_Data,2);
Train_Number = size(Training_Data,2);
temp_m = [];  
for i = 1 : Train_Number
    temp_m = [temp_m m];
end
A = double(Training_Data) - temp_m;

%-------------------use the "svd" function to compute the eigenvectors
%--------------------and eigenvalues of the covariance matrix.
disp('Computing...Wait a second please')
L = A'*A;
%size(L)
[V D] = eig(L); 

%-----------------------------Sort and eliminate eigenvalues---------------
Eig_vec = [];
for i = 1 : size(V,2) 
    if( D(i,i)>1000 ) % Set Threshold value whatever you like
        Eig_vec = [Eig_vec V(:,i)];
    end
end

Eigenfaces = A * Eig_vec;