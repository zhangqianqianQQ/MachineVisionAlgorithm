function [indexes]=train_test_random_new(y,n,nall)
% function to ramdonly select training samples and testing samples from the
% whole set of ground truth.
% alltrain is the ground truth
% % clc
% alltrain = alltrain';
% y = alltrain(2,:); % Indiana
% y = alltrain(1,:); % Salinas
% yindex = [];
% train = [];
% lys = 0;
K = max(y);
% pK = 0.0001,

% generate the  training set
indexes = [];
for i = 1:K
    index1 = find(y == i);
    per_index1 = randperm(length(index1));
    if length(index1)>n
        indexes = [indexes ;index1(per_index1(1:n))'];
    else
        indexes = [indexes ;index1(per_index1(1:round(length(index1)/2)))'];
    end
end
indexes = indexes(:);
indexes_all = [1:length(y)];
indexes_all(indexes) = [];
n_new = nall - length(indexes);
per_indexall = randperm(length(indexes_all));
indexes_new = indexes_all(per_indexall(1:n_new));
indexes = [indexes;indexes_new'];
indexes = indexes(:);




% indexes = indexes';
% train = y(indexes);
% y(indexes) = [];
% test = y;

% for k_iter = 1:K
%     index_k = y == k_iter;
%     index_k = find(index_k);
%     if length(index_k) > n
%         index_k_random =  ceil(length(index_k).*rand(n,1));
%         index_k_random = sort(index_k_random);
%         index_k_random1 = [index_k_random(2:n);index_k_random(1)];
%         resid = index_k_random1 - index_k_random;
%         resid0 = resid == 0;
%         index_k_random(resid0) = [];
%         train_k = alltrain(:,index_k(index_k_random));
%         yindex = [yindex,index_k(index_k_random)];
%     else
%         n1 = ceil(length(index_k)/2);
%         index_k_random =  ceil(length(index_k).*rand(n1,1));
%         index_k_random = sort(index_k_random);
%         index_k_random1 = [index_k_random(2:n1);index_k_random(1)];
%         resid = index_k_random1 - index_k_random;
%         resid0 = resid == 0;
%         index_k_random(resid0) = [];
%         train_k = alltrain(:,index_k(index_k_random));
%         yindex = [yindex,index_k(index_k_random)];
%     end
%     train = [train,train_k];
% end
% 
% trainold = alltrain;
% alltrain(:,yindex) = [];
% test = alltrain;
% for i = 1:K
%     ly = length(find(y==i));
%     nf = ceil(pK*ly);
%     f = lys + ceil(ly.*rand(nf,1));
%     f = sort(f);
%     findex = [];
%     for j = 1:(length(f)-1)
%         if f(j) == f(j+1)
%             findex = [findex,j];
%         end
%     end
%     f(findex) = [];
%     train10 = alltrain(:,f);
%     yindex = [yindex,f'];
%     train = [train,train10];
%     lys = lys + ly;
% end
% 
% alltrain(:,yindex) = [];
% test = alltrain;
                  