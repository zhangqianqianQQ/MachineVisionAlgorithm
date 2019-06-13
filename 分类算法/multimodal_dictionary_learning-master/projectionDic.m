% Project the dictionary D to satisfy the constraint that the norm of each
% column should be smaller or euqal to 1

function D = projectionDic(D)

% for i = 1: size(D,2)
%     norm_col_squared = sum(D(:,i).^2);
%     if norm_col_squared > 1
%         D(:,i) = D(:,i)/sqrt(norm_col_squared);
%     end
% end

% vectorize
norm_col_squared = sum(D.^2,1);
if norm_col_squared > 1
    D(:,norm_col_squared > 1) = D(:,norm_col_squared > 1)./repmat(sqrt(norm_col_squared(1,norm_col_squared > 1)),size(D,1),1);
end
