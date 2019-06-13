%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An implementation of the Maximum Marginal
% Relevance re-ranking method used in this 
% paper:
%
% J. Carreira and C. Sminchisescu. CPMC: 
% Automatic object segmentation using 
% constrained parametric min-cuts. PAMI,
% 34(7):1312–1328, 2012.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P, S] = doMMR(bbox, score, lambda)

res = [];
bbox = [bbox score(:)];
if isempty(bbox)
    return;
end

res = bbox(1,:);
bbox(1,:) = [];
while ~isempty(bbox)
    ss = bbox(:,end);
    for i = 1:size(bbox,1)
        ss(i) = ss(i) -lambda*max(getIOU(res,bbox(i,1:4)));
    end
    [ss,iidx] = sort(ss,'descend');
    bbox = bbox(iidx,:);

    res(end+1,:) = [bbox(1,1:4) ss(1)];
    bbox(1,:) = [];
end
P = res(:,1:4)';
S = res(:,end);