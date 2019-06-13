function boxStruct = GetGTAndSSBoxes(imName)
% Using the imName, get the GT bounding boxes and the Selective Search bounding boxes
% to create Girshick-style RCNN features afterwards
% 
% The boxStruct contains the fields:
%       boxes:       N x 4 (single)
%       class:       N x 1 (uint8)
%       gt:          N x 1 (logical)
%       is_difficult:N x 1 (logival)
%       overlap:     N x 200 (double)

global DATAopts;

record = VOCreadxml(sprintf(DATAopts.annopath, imName));

class_to_id = containers.Map(DATAopts.classes, 1:length(DATAopts.classes));

im = imread(sprintf(DATAopts.imgpath, imName));
im = im2double(im);
selectiveSearchBoxes = selective_search_boxes(im, true, 500);

boxStruct = attach_proposals(record.annotation, selectiveSearchBoxes, class_to_id);


% ------------------------------------------------------------------------
function rec = attach_proposals(voc_rec, boxes, class_to_id)
% ------------------------------------------------------------------------

% change selective search order from [y1 x1 y2 x2] to [x1 y1 x2 y2]
boxes = boxes(:, [2 1 4 3]);

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]
if isfield(voc_rec, 'object')
    num_gt_boxes = length(voc_rec.object);
    gt_boxes = zeros(num_gt_boxes, 4);
    gt_classes = zeros(num_gt_boxes, 1);
    for i=1:length(voc_rec.object)
        gt_boxes(i,:) = [str2double(voc_rec.object(i).bndbox.xmin) ...
                         str2double(voc_rec.object(i).bndbox.ymin) ...
                         str2double(voc_rec.object(i).bndbox.xmax) ...
                         str2double(voc_rec.object(i).bndbox.ymax)];
        gt_classesT = class_to_id.values({voc_rec.object(i).name});
        gt_classes(i) = gt_classesT{1};
    end
    all_boxes = cat(1, gt_boxes, boxes);
else
    gt_boxes = [];
    all_boxes = boxes;
    gt_classes = [];
    num_gt_boxes = 0;
end
num_boxes = size(boxes, 1);

rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
rec.overlap = zeros(num_gt_boxes+num_boxes, class_to_id.Count, 'single');
% Get overlap wrt ground truth boxes
for i = 1:num_gt_boxes
    rec.overlap(:, gt_classes(i)) = ...
      max(rec.overlap(:, gt_classes(i)), BoxOverlap(all_boxes, gt_boxes(i, :)));
end
rec.boxes = single(all_boxes);
rec.feat = [];
rec.class = uint16(cat(1, gt_classes, zeros(num_boxes, 1)));
