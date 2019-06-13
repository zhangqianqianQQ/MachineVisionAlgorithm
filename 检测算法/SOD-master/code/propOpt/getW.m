%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Precompute all w_{ij}
% Xp is the likelihood of the optimal assignments given 
% the current output set 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [W, Xp] = getW(B, S, param)

P = zeros(size(B,2));
for i = 1:size(B,2)
    P(i,:) = getIOUFloat(B',B(:,i)');
end
P = bsxfun(@times, P, S(:));
P = [P param.lambda*ones(size(B,2),1)];
P = bsxfun(@times, P, 1./sum(P,2));
W = log(P);
Xp = W(:,end);
W = W(:,1:end-1);