function p= mlogistic(w,x)

% compute the  multinomial distributions (one per sample)
m = size(w,2)+1;

aux = exp(w'*x);

p =  aux./repmat(1+sum(aux,1),m-1,1);

% last class
p(m,:) = 1-sum(p,1);

% 
% aux(m,:) = 1;
% 
% sumProbClass = sum(aux,1);

% assoc = log(aux./repmat(sumProbClass,[m,1]));


% p =  aux./repmat(1+sum(aux,1),m-1,1);

% last class
% p(m,:) = 1-sum(p,1);
% 
% probClass = exp(Y*W);
% probClass(:,CLASS) = 1;
% 
% sumProbClass = sum(probClass,2);
% 
% assoc = log(probClass./repmat(sumProbClass,[1,CLASS]));
