function [ result ] = proj_inference( img ,model)
%TEST given a hog descriptor. predict on whether it contains a man.
%   output = 2 if positive, 1 if negative
feature=extractHOGFeatures(img);
addpath('data')
[output,~]=inference(model,feature);
[~,result]=max(output,[],1);
%if result==2
%    fprintf('It contains a man. \n')
%    %imshow(imresize(resized_img,[300 150]))
%else
%    fprintf('It does not contain a man. \n')
%end
end

