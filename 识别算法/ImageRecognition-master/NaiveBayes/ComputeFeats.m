% Compute a Features

function [Feats] = ComputeFeats()
load('HOG_Features.mat');

Feats = [];


K = cell2mat(Features(1));
%Selects alpha random features from all the features generated
alpha = randperm(size(K,1),100);

for i = 1:length(Features)
   F = cell2mat(Features(i));
   F_alpha = [];
   for j = 1:size(alpha,2)
       F_alpha = vertcat(F_alpha,F(alpha(j),:)); 
   end
   Feats = horzcat(Feats,F_alpha); 
end

Feats = Feats';
%Features matrix with dimensions 5000*alpha
%Change alpha if needed to view results
end