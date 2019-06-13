function [Normal_Space,W_tangnet,angles] = TVG_affinity_knn(data,index_mat,params,S_tan)
n_neighbors = size(index_mat,1);%params.n_neighbors;
int_dim = params.int_dim;
N = size( data, 2 );
D = size( data, 1 );
W_tangnet=zeros(N,N);
Sigma_vote=params.Sigma_vote;
angles=zeros(N,N);
[m,N] = size(data);  % m is the dimensionality of the input sample points.

%h = waitbar(0,'Tensor Voting Graph ...');
% Compute Tensor Voting and extract the reversed tensor votes
inv_noise_data=data';
% [Reversed_Votes,Data_STV_N] = Reversed_Sparse_Ball(inv_noise_data, Sigma_vote, 1, 'Std2',index_mat);
% [Ordered_Reversed_V]=Ordered_Reversed_Votes(Reversed_Votes,N,int_dim,D,index_mat);
[index_mat_vote,S]=knnsearch(inv_noise_data,inv_noise_data,'k',(params.n_neighbors*params.m) +1,'distance','euclidean');
index_mat_vote=index_mat_vote(:,2:end);
index_mat_vote=index_mat_vote';
S=S(:,2:end);
S=S';
%S =L2_distance(data,data);
F = S<2*sqrt( params.Sigma_vote);
[Data_STV_N, avg_votenum] = Reversed_Sparse_Ball_fast(inv_noise_data, Sigma_vote, 1, 'Std2',index_mat_vote);

for i=1:N
    waitbar(i/N);
    normal_i=Data_STV_N(i,(2*D)+2:(2*D)+1+(int_dim*D));
    normal_i=reshape(normal_i,D,int_dim);
    temp_nei_i = find(F(:,i));
    temp_nei_i=index_mat_vote(temp_nei_i,i);
for j=1:length(temp_nei_i)
        idxNeig = temp_nei_i(j);
        normal_j=Data_STV_N(idxNeig,(2*D)+2:(2*D)+1+(int_dim*D));
        normal_j=reshape(normal_j,D,int_dim);
      
       [theta]=max(subspaceangle(normal_i,normal_j));
       angles(idxNeig,i)=theta;
     %  [theta]=max(subspace(normal_i,normal_j));
     W_tangnet(idxNeig,i)=cos(theta).^1;
        %W_tangnet(idxNeig,i)=cos(theta).^params.powerCos;
     %   W_tangnet(i,idxNeig)=W_tangnet(idxNeig,i);
        W_tangnet(i,i)=0;
        %        F(j,i)=abs(acosd(theta));
        %F(j,i) = sind(F(j,i));
        %F(j,i)=exp((-F(j,i).^2)./1.0);
        
    end
end
%close(h);
Normal_Space=Data_STV_N(:,(2*D)+2:(2*D)+1+(int_dim*D));
end
