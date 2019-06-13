%% function to get rcnn detected part boxes
%% Written by Ning Zhang

function detect_boxes = get_rcnn_detections(config)
try 
  load('caches/rcnn_detect_boxes.mat');
catch
  try  
    load('caches/rcnn_part_models.mat');  
  catch
    disp('Train part detectors in rcnn and save it in the caches');
    exit(-1);
  end
  detect_boxes = test_rcnn_parts(part_models, config);
  save('caches/rcnn_detect_boxes.mat', 'detect_boxes');
end
end

