function [bboxes,idx] = doNMS(bboxes, thresh)

if isempty(bboxes)
    return
end
tmp = bboxes(:,1);
idx = 1;
for i = 2:size(bboxes,2)
    if max(getIOUFloat(tmp',bboxes(:,i)')) < thresh
        tmp = [tmp bboxes(:,i)];
        idx = [idx i];
    end
end
bboxes = tmp;