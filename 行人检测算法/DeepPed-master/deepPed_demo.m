function deepPed_demo()

imgPath = 'DeepPed/TestImages';
listImages = bbGt('getFiles',{imgPath});

% load and adjust the LDCF detector
load('toolbox/detector/models/LdcfCaltechDetector.mat');
pModify = struct('cascThr',-1,'cascCal',.025);
detector = acfModify(detector,pModify);

% load the trained SVM
SVM = load('data/rcnn_models/DeepPed/SVM_finetuned_alexnet.mat');
PersonW = SVM.W;
PersonB = SVM.b;

% load the trained svm of level 2
cl2 = load('data/rcnn_models/DeepPed/SVM_level2.mat');

%load the finetuned AlexNet
rcnn_model_file = 'data/rcnn_models/DeepPed/finetuned_alexNet.mat';
use_gpu = 1;    %to change to zero if caffe compiled without CUDA support
rcnn_model = rcnn_load_model(rcnn_model_file, use_gpu);
thresh = 2;

for i = 1 : length(listImages)
   img = imread(listImages{i});
   % detect possible pedestrians with LDCF
   bbs = acfDetect(img,detector);
   dt_ldcf = bbs;

   % evaluate BBs retrieved by LDCF with our finetuned AlexNet
   bbs(:,3) = bbs(:,1) + bbs(:,3);
   bbs(:,4) = bbs(:,2) + bbs(:,4);
   bbs(:,5) = [];
   feat = rcnn_features(img, bbs, rcnn_model);
   scores_cnn = feat*PersonW + PersonB;

   % use second level SVM
   scores = [dt_ldcf(:,5) scores_cnn]*cl2.W+cl2.b;
   
   % discard BBs with too low score and apply NMS
   I = find(scores(:) > thresh);
   scored_boxes = cat(2, bbs(I, :), scores(I));
   keep = nms(scored_boxes, 0.3); 
   dets = scored_boxes(keep, :);
   dets(:,3) = dets(:,3) - dets(:,1);
   dets(:,4) = dets(:,4) - dets(:,2);
   
   % show the final obtained results
   figure(1);
   imshow(img);
   hold on
   for k = 1 : size(dets,1)
       rectangle('Position',dets(k,1:4),'EdgeColor', 'r','LineWidth',3);   
   end
   hold off
   title('Press a button to continue');
   waitforbuttonpress();
end

end

