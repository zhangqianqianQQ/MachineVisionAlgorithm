%This is an alternative function to using Compute feats
function [Feats] = BestFeats()
    
    load('HOG_Features.mat');
    F1 = cell2mat(Features(1));
    F2 = cell2mat(Features(2));
    F3 = cell2mat(Features(3));
    F4 = cell2mat(Features(4));
    F5 = cell2mat(Features(5));
    
    F = horzcat(F1,F2,F3,F4,F5);
    
    %The var function in matlab uses normalization implicitly
    %This performs the PCA step
    V = var(F,[],2);
    %Alpha selected based on maximum variance in a particular feature
    alpha = zeros(150,1);
    for j = 1:150
        [~,alpha(j)] = max(V);
        V(alpha(j)) = 0;
    end
    
    Feats = [];
    for i = 1:length(Features)
        F = cell2mat(Features(i));
        F_alpha = [];
        for j = 1:length(alpha)
            F_alpha = vertcat(F_alpha,F(alpha(j),:)); 
        end
        Feats = horzcat(Feats,F_alpha);
    end
    Feats = Feats';
    %Final features matrix with dimensions 5000*alpha 
end