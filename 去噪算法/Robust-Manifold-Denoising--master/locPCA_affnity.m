function [Data_PCA,F,angles] = locPCA_affnity(data,index_mat,params)
n_neighbors = size(index_mat,1);%params.n_neighbors;
int_dim = params.int_dim;
N = size( data, 2 );
D = size( data, 1 );
Data_eig=cell(1,N);
retain = params.m*params.n_neighbors;
F=spalloc(N,N,300*N);
%F=(zeros(N,N));
[m,N] = size(data);  % m is the dimensionality of the input sample points.
N
eig_dim1=zeros(m,N);
if length(n_neighbors)==1
    K = repmat(n_neighbors,[1,N]);
end;

for i=1:N
    
    % Compute the d largest right singular eigenvectors of the centered matrix
    Ii = index_mat(:,i); ki = K(i)
    Xi = data(:,Ii)-repmat(mean(data(:,Ii),2),[1,ki]);
    
    %construct the matrix Y
    Y = Xi' / sqrt(n_neighbors-1);
    %[U,Sing,V] = svd( Xi );
    [U,Sing,V] = svd( Y,'econ');
    %   Zi = U(:,1:d)*U(1:d,:)*Xi;
    %  [signals,PC,V] = pca2(Xi) ;
    % Data_PCA(1:D,i) = data(1:D,i);
    %Data_eig{i}=V(:,1:d);
    Data_eig{i}= V(:,1:int_dim);
    eig_dim1(:,i)=(Data_eig{i}(1:m));
    %Data_eig{i}=V(:,:1:d);
    
end

angles=spalloc(N,N,300*N);
%h = waitbar(0,'Local PCA...');
if params.int_dim>1
for i=1:N
    waitbar(i/N);
    normal_i=Data_eig{i}';
    temp_nei_i=index_mat(:,i);
    for j=1:length(temp_nei_i)
        idxNeig = temp_nei_i(j);
        normal_j=(Data_eig{idxNeig})';
        [theta] = max(subspaceangle(normal_i',normal_j'));
        angles(idxNeig,i) = theta;
        angles(i,idxNeig) = theta;
       % theta = subspace(normal_i',normal_j');
        F(idxNeig,i)=cos(theta).^params.powerCos;
        % F(j,i)=abs(acosd(theta));
        %F(j,i) = sind(F(j,i));
        %F(j,i)=exp((-F(j,i).^2)./1.0);
        F(i,idxNeig)=F(idxNeig,i);
    end
end
elseif params.int_dim==1
%  % s = sqrt( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) );
for i=1:N
    waitbar(i/N);
    normal_i   =   eig_dim1(:,i)';
    temp_nei_i =   index_mat(:,i); 
    normal_j=( eig_dim1(:, temp_nei_i));
    F(i, temp_nei_i)=normal_i*normal_j;
    F(temp_nei_i,i)=F(i,temp_nei_i);
end
[I]=find(F);
s1 =  (acosd(F(I))); 
s2=  180- (acosd(F(I)));
s=min(s1,s2);
angles(I)=s;

end   
    
   
Data_PCA = Data_eig;
end
