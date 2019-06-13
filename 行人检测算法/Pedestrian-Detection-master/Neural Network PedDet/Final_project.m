%% You can choose different segment size to train the model with Startoveragain=1,
%for different size, you should use different loss_thresh to stop the
%training procoss (for larger size, you should use lower loss_thresh), 
%if you've already trained the model, use Startoveragain=0
%and if you want to do resize, use Doresize=1.
function [] = Final_project(Startoveragain , Doresize)
close all
addpath('layers')
addpath('segment')
sz1=74;
sz2=34;
loss_thresh=0.18;
if Startoveragain
    model=proj_train_original(sz1,sz2,loss_thresh);
else
    load('proj_model.mat')
end
%img_origin=imread('Capture1.JPG');
img_origin=imread('img2.jpg');
%list = dir(pathstr);

%for i = 1 : length(list)
%    if (~isempty(findstr(list(i).name, 'jpg')))
%        img_origin = imread(list(i).name);
%        if Doresize
%            for k=3:9
%        %the resized picture has height as k times as the segement
%        figure
%        windows=resndet(img_origin,model,sz1,sz2,k);
%        end
%else
%    windows=getped(img_origin,model,sz1,sz2);
%end
%    end
%end


 if Doresize
     for k=3:9
         %the resized picture has height as k times as the segement
         figure
         winds=resndet(img_origin,model,sz1,sz2,k);
         fprintf('One image is finished\n')
     end
     fprintf('Scaled image detection is finished\n')
 end
figure
windows=getped(img_origin,model,sz1,sz2);
fprintf('Original size image detection finished.\n')
end