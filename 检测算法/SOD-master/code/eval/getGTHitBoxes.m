%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the correct detection
% windows given the ground truth.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = getGTHitBoxes(bboxes, anno, thresh)
res = [];
if isempty(anno) || isempty(bboxes)
    return;
end
for i = 1:size(anno,1)
    iou = getIOU(bboxes', anno(i,:));
    [score, idx] = max(iou);
    if score > thresh
        res = [res bboxes(:,idx)];
        bboxes(:,idx) = [];
    end
end