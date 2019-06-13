function [normed_data] = normalization_all(data)
% Calculating mean and standard deviation on whole image, then
% normalization, to keep consistent

mean_val=mean(data,1);
sigma_val=std(data,0,1);
    
normed_data=bsxfun(@minus,data,mean_val);
normed_data=bsxfun(@rdivide,normed_data,sigma_val);