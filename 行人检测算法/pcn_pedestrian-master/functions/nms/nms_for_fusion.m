function train_box = nms_for_fusion(dt2, nms_thres)
% for rpn-boxes(atrous-box300)
% when nms_thres = 0.5 . 
% we get the table below (recall and avg-boxes - thres)
% thres     avg-boxes   recall-0.5  recall-.75
% 10e-6     130         99.8        66.9
% 10e-5     120         99.8        66.9
% 10e-4     60          99.7        66.9
% 10e-3     30          99.3        66.8
% 10e-2     15          98.6        66.4
% 10e-1     8           96.6        65.3
% when nms_thres = 0.7
% thres     avg-boxes   recall-0.5  recall-0.75
% 10e-3     30          99.8        88.9
% 0.2       10          97.5        84.5
% for the speed and accuracy, we just choose the parameter as below for script_rpn:
% nms_thres = 0.7, thres = 10e-3,
% nms_thres = 0.7, thres = 0.2
train_box = {};
thres = 10e-6;
for j = 1:size(dt2, 2)
    i =1;
    aboxes = dt2{j};

%     aboxes(:, 3) =  aboxes(:, 3)  +  aboxes(:, 1); 
%     aboxes(:, 4) =  aboxes(:, 4)  +  aboxes(:, 2); 
    boxes_cell{i} = aboxes;    
    boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, nms_thres), :);
    if ~isempty(boxes_cell{i})
        I = boxes_cell{i}(:, 5) >= thres;
        boxes_cell{i} = boxes_cell{i}(I, :);
    end
    train_box{j} = boxes_cell;
end