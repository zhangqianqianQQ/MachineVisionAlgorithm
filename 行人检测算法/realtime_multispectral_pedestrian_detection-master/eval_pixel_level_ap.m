%% Evaluate the pix-level AP on the reasonable subset in the KAIST test set

clc; clear; close all;

gt_dir = 'GT_Reasonable/';
dt_dir = 'HMFFN320/';
% dt_dir = 'HMFFN640/';

scene = 'all';
% scene = 'day';
% scene = 'night';

gt_ids = dir(fullfile(gt_dir,'*.png'));
dt_ids = dir(fullfile(dt_dir,'*.png'));

num_images = length(gt_ids);
gt_total=cell(1,num_images); dt_total=cell(1,num_images);
for ind=1:num_images
gt = imread([gt_dir,gt_ids(ind).name]); 
gt = single(gt)/255;
dt = imread([dt_dir,dt_ids(ind).name]);
dt = single(dt)/255;

dt = dt(:); gt = gt(:); 
ignores = logical(((gt>0).*(gt<1)));
dt(ignores)=-1; gt(ignores)=-1;
gt_total{1,ind}=dt; dt_total{1,ind}=gt;
end

dts=cell2mat(gt_total); dts=dts(:); gts=cell2mat(dt_total); gts=gts(:); 
if strcmp(scene,'all'); 
elseif strcmp(scene,'day'); seed=length(gt_total{1,1}); dts=dts(1:seed*1455,:); gts=gts(1:seed*1455,:);
elseif strcmp(scene,'night'); seed=length(gt_total{1,1}); dts=dts((1+seed*1455):end,:); gts=gts((1+seed*1455):end,:);
end

tic;
ap = prec_rec(dts, gts, 'plotPR', 1, 'plotROC', 0, 'plotBaseline', 0); ylim([0 1]);
fprintf('Pix-level Average Precision = %0.3f \n', ap);
toc;


