function [W_k,v] = k_hope_matrix_new (W,m,Sigma,data_noise)
N=size(W,2);
dim=size(data_noise,1);
%W_G=(zeros(N,N));
W_G=spalloc(N,N,300*N);

W_k=W^(m-1);
W_k=full(W_k);
% figure;
% imagesc(W_k)
% disp('check')
temp_k_index_mat=cell(1,N);
kk=length(find(W_k));
temp_k_index_mat2=zeros(kk,1);
%temp_k_index_mat2=[];
% for i=1:N
%     temp_k_index=find(W_k(:,i));
%     %temp_k_index(temp_k_index==i)=[];
%     temp_k_index_mat{i}=(temp_k_index);
%     a1=temp_k_index_mat{i};
%     S_geo = L2_distance(data_noise(:,a1),data_noise(:,i));
%     S_geo=(exp((-S_geo./Sigma.^2)));
%    % temp_k_index_mat2=[S_geo;temp_k_index_mat2];
% end

v=cell(1,N);
for i=1:N
    %temp_k_index=index_mat(:,i);
    temp_k_index=find(W_k(:,i));
    temp_k_index(temp_k_index==i)=[];
    %S_geo = L2_distance(data_noise(:,temp_k_index),data_noise(:,i));
    a1=temp_k_index;
    S_geo = L2_distance(data_noise(:,a1),data_noise(:,i));
   v{i}= S_geo;
    %t=sort(temp_k_index);
    %W_G(t,i)=exp((-S_geo./Sigma.^2));
    %W_G(:,i)=full(W_G(:,i));
    Sigma=10;
     W_G(a1,i)=(exp((-S_geo./Sigma.^2)));
      v{i}= (exp((-S_geo./Sigma.^2)));
    % W_G(i,a1)=(exp((-S_geo./Sigma.^2)));
  %  W_G(:,i)=sparse(W_G(:,i));
end
% figure;
% imagesc(full(W_G))
W_k = W_G;
% %W_k=W_k;
% W_k=sparse(W_k);

% data_noise=double(data_noise);
% [I,J]=find(W_k);
% E=sparse(I,J,ones(size(I,1),1),N,N);
% s = sqrt( sum( ( data_noise(:,I)-data_noise(:,J) ).^2, 1) );
% S=exp(-(s) ./ Sigma^2 );
% waff = sparse(I,J,S,N,N);
% W_k=waff;
% W_k(1:N+1:end)=0;
% % waff = sparse(I,J,S,N,N);
% % W_k=waff; 
% s1=data_noise(1,I);
% s2=data_noise(1,J);
% s=(s1-s2).^2;
% s12=data_noise(2,I);
% s22=data_noise(2,J);
% ss=(s12-s22).^2;
% S = exp(-sqrt(s+ss) ./ Sigma^2 );
% waff = sparse(I,J,S,N,N);
% W_k=waff;

%W_k(1:N+1:end)=0;
% [a1,a2]=find(W_k);
% v = zeros(length(a1),1);
% length(a1)
% length(temp_k_index_mat2)
% length(v)
% for l = 1:length(v)
%    % j=a3(i);
%     v(l) = temp_k_index_mat2(l);
% end
% tic;
% W_k = sparse(a1,a2,v,N,N);
% toc

%A = cell2mat(temp_k_index_mat) ;
