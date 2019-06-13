function [M,P] = GetMP(Feats,Labels) 
    l = unique(Labels);
    X = cell(length(l),1);
    P = zeros(10,1);
    
    for iter = 1:size(X,1)
        X{iter} =  [];
    end
    
    for i = 1:size(Feats,1)
        r = find(l == Labels(i));
        X{r} = vertcat(cell2mat(X(r)),Feats(i,:));
        P(Labels(i)+1) = P(Labels(i)+1) + 1;
    end
    
    P = P/sum(P);
    M = [];
    
    for j = 1:size(X,1)
        M = vertcat(M,mean(cell2mat(X(j)),1));
    end

end