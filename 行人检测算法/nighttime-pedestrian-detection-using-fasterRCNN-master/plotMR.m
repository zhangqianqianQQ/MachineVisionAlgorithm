clear all;
addpath(genpath('./external/toolbox(kaist)'));

exp_name='(kaist-reasonable-day)';
% exp_name='(kaist-reasonable-night)';
% exp_name='(kaist-reasonable-all)';

thr=0.5; % if overlap>thr, true positive
mul=0;
ref=10.^(-2:.25:0);
n=1000; clrs=zeros(n,3);
for i=1:n, clrs(i,:)=max(.3,mod([78 121 42]*(i+1),255)/255); end % make 'n' kind of colors

gt_boxes=load(fullfile(pwd,'test',['gt_boxes',exp_name]));
gt_boxes=gt_boxes.gt_boxes;
for i=1:length(gt_boxes)
    boxes=gt_boxes{i};
    boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
    gt_boxes{i}=boxes;
end

day=1455;
dt_dir=dir(fullfile(pwd,'test','*dt.mat'));
dt_num=length(dt_dir);
for i=1:dt_num
    dt_boxes=load(fullfile(dt_dir(i).folder,dt_dir(i).name));
    dt_boxes=dt_boxes.dt_boxes;
    
    if contains(exp_name,'day')
        dt_boxes=dt_boxes(1:day);
    elseif contains(exp_name,'night')
        dt_boxes=dt_boxes(day+1:end);
    end

    for j=1:length(dt_boxes)
        boxes=dt_boxes{j};
        boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
        dt_boxes{j}=boxes;
    end
    % dt_boxes,gt_boxes should be [x,y,w,h]
    [gt,dt] = bbGt('evalRes',gt_boxes,dt_boxes,thr,mul);
    
    [fp,tp,score,miss] = bbGt('compRoc',gt,dt,1,ref);
    
    miss=exp(mean(log(max(1e-10,1-miss))));

    lgd{i}=sprintf('%.2f%% %s',miss*100,dt_dir(i).name(1:end-7));
    h(i)=plotRoc([fp tp],'logx',1,'logy',1,'xLbl','False positives per image',...
    'lims',[3.1e-3 1e1 .05 1],'color',clrs(i,:),'lineSt', '-','smooth',1,'fpTarget',ref);
    
end
legend(h,lgd,'Location','sw','FontSize',11); 
title(exp_name,'FontSize',15);