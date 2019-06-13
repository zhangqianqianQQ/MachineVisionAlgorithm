function [W_G, IDX2, S, IDX_vote, S_vote] = RBF_affnity_knn_fast_outliers(data_noise,params,f_outliers)
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
% s = sqrt( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) );
% s=S(:);
% s = sqrt( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) );

Sigma=0.1;
% s = (1.1./ (1.1+ (f_outliers(I)-f_outliers(J)).^2)).^2;
% s1= ( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) )
% s2= (1.0./ (1+ s1)).^2;
% s2=s2';

s = (f_outliers(I)-f_outliers(J) ).^2;
w_temp=exp(-(s) ./ Sigma );
%s=s.*s2;
%w_temp=s;
waff = sparse(I,J,w_temp,N,N);
W_k=waff;
%W_k= (W_k + W_k')./2 ;
W_k= ((W_k + W_k')+ abs(W_k - W_k'))./2;
W_G=sparse(W_k);




