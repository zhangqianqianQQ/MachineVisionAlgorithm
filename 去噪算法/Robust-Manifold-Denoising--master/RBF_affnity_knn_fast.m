function [W_G, IDX2, S, IDX_vote, S_vote] = RBF_affnity_knn_fast(data_noise,params)
%mydisp('Computing RBF affinity')
if nargin < 2
    neibours = 20;
else
    neibours = params.n_neighbors;
end
Sigma = params.Sigma;
N=size(data_noise,2);

%W_G=sparse(zeros(N,N));
W_G=spalloc(N,N,300*N);
%W_G=(zeros(N,N));
affinity_type = params.affinity_type;
retain = params.m*params.n_neighbors;

%S = pdist2imp(data_noise',data_noise','sqeuclidean');
switch  affinity_type
    case 'cosine'
    %S = pdist2imp(data_noise',data_noise','cosine');
    [IDX_vote,S]=knnsearch(data_noise',data_noise','k',retain+1,'distance','cosine');
    IDX_vote=IDX_vote(:,2:end);
    S=S(:,2:end);
    S_vote=S;
    IDX_vote=IDX_vote';
    S=S';
    S_vote=S;
    S = S(1:neibours,:);
    otherwise
%   S = single(pdist2imp(data_noise',data_noise','sqeuclidean'));
%   S = (pdist2imp(data_noise',data_noise','sqeuclidean'));
   %[IDX_vote,S]=knnsearch(data_noise',data_noise','k',neibours+1,'distance','euclidean');
    [IDX_vote,S]=knnsearch(data_noise',data_noise','k',retain+1,'distance','euclidean');

     IDX_vote=IDX_vote(:,2:end);
     S=S(:,2:end);
     IDX_vote=IDX_vote';
     S=S';
      
     
end
% [~, IDX] = ((sort(S,2)));
% IDX=single(IDX);
%% Clipping NN

IDX2 = IDX_vote(1:neibours,:);
S_vote=S;
S = S(1:neibours,:);


a1=1:N;
a2=repmat(a1,neibours);
a2=a2(1:neibours,1:N);
a3=a2(:);
I=a3;
J=IDX2(:);
s = sqrt( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) );
s=S(:);
Sigma=0.05;
w_temp=exp(-(s) ./ 2*Sigma );
waff = sparse(I,J,w_temp,N,N);

W_k=waff;
%W_k=max(W_k,W_k');
%W_k= (W_k + W_k')./2 ;
W_k= (W_k + W_k')./2 + abs(W_k - W_k')./2;
%W_k(1:N+1:end)=0;
% for i = 1:N
%     temp_nei_i=IDX2(:,i);
%     %s1=(S(i,:).^2)';s2=exp((-s1./2*Sigma));
%     %s1=(S(:,i).^2);
%     s1=(S(:,i));
%     s2=(exp((-s1./2*Sigma)));
%     W_G(temp_nei_i,i)=s2;
%     W_G(i,temp_nei_i)=s2;
%     temp_nei_i_large=IDX_vote(:,i);
%     s1large=(S_vote(:,i));
%     s2large=(exp((-s1large./2*Sigma)));
% %     W_large(temp_nei_i_large,i)=s2large;
% %     W_large(i,temp_nei_i_large)=s2large;
%     
%  %   W_G(i,temp_nei_i)=exp((-S(temp_nei_i,i)./Sigma));
% end
W_G=sparse(W_k);




