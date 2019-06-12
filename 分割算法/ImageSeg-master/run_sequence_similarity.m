% run sequence similarity

% whether to run the network to extract feature vectors of the objects
EXTRACT_FEATURES = true;

% whether to calculate the similarity matrix of the objects across frames
CALC_SIMILARITY = false;

CALC_DEEP_MATCH = false;

im_name = ['MOT-09/000001.jpg'];
img = imread(im_name);
[im_H,im_W,im_C] = size(img);
GT = csvread('MOT-09-gt/gt.txt');
W = load('net_weights.mat');
cls_ind = 16; % 1 background, 3 bike, 16 human
%frames = [110,115,120];
%ids = [7,22,44];
frames = [21];
ids = [19];

%{
GET FT VECTORS OF EACH BBOX:

  for each image:
    1. get rois, process it to be in original image pixel unit
    2. keep track of (object index, roi index) pairs
    3. do forward and backward pass of network
    4. extract feature vector (pool_5, contrib_img), save to dictionary
%}

% preprocess gt
gt = GT(:,1:6);
gt(:,5) = gt(:,5) + gt(:,3);
gt(:,6) = gt(:,6) + gt(:,4);
gt_ind = find_gt_idx_frame_obj(gt, frames, ids);
gt = gt(gt_ind,:);
for r=1:size(gt,1)
    if gt(r,3)>im_W
        gt(r,3) = im_W;
    end
    if gt(r,4)>im_H
        gt(r,4) = im_H;
    end
    if gt(r,5)>im_W
        gt(r,5) = im_W;
    end
    if gt(r,6)>im_H
        gt(r,6) = im_H;
    end
end

% resize img
for frame = frames
    im_name = ['MOT-09/' sprintf('%06d',frame) '.jpg'];
    img = imread(im_name);
    resized(frame).img = resize_img(img);
end


% get feature vector per frame
% FT_VEC is a matrix of struct
if EXTRACT_FEATURES
    
    for frame = frames
        gt_ind = find(gt(:,1) == frame);
        rois = gt(gt_ind, 2:6);
        rois(1,2:5) = [1200,300,1920,780];
        obj_ids = gt(gt_ind, 2);

        % setup
        im_name = ['MOT-09/' sprintf('%06d',frame) '.jpg'];
        img = imread(im_name);
        
        %forward & backward pass the network
        tic;
        res = net_forward_pass(img, W, rois, true);toc
        tic;
        contrib = net_reverse_contrib(res, W, cls_ind, 'img');toc
        contrib2 = net_reverse_contrib(res, W, 1, 'img');
        for roi_ind = 1:size(rois, 1)
            obj_id = obj_ids(roi_ind);
            FT_VEC(frame, obj_id).img = img;
            FT_VEC(frame, obj_id).roipool = squeeze(res.pool_5(:,:,:,roi_ind));
            FT_VEC(frame, obj_id).contrib_roipool = squeeze(contrib.roipool(roi_ind,:,:,:));
            FT_VEC(frame, obj_id).contrib_conv1_1 = squeeze(contrib.conv1_1(roi_ind,:,:,:));
            FT_VEC(frame, obj_id).contrib_img = squeeze(contrib.img(roi_ind,:,:,:));
        end
    end
    
end


% get cropped img of rois
for frame=frames
    for id=ids
        % get cropped matrix of rois
        im_name = ['MOT-09/' sprintf('%06d',frame) '.jpg'];
        img = imread(im_name);
        gt_ind = find_gt_idx_frame_obj(gt, [frame], [id]);
        roi = gt(gt_ind, 3:6);
        roi = ceil(roi);
        mat = img(roi(2):roi(4), roi(1):roi(3), :);
        im_name = ['output/' sprintf('%03d',id) '_' sprintf('%03d',frame) '.jpg'];
        imwrite(mat,im_name);
        cropped(frame,id).mat = mat;
    end
end



% generate similarity matrix:
frs = frames;
num_obj = length(frs)*length(ids);
SIM_roipool = zeros(num_obj,num_obj);
SIM_DM = SIM_roipool;
SIM_contrib_roipool = SIM_DM;

if CALC_SIMILARITY   
    count = 0;
    for A_idx = 1:num_obj % A_idx and B_idx are index in the similarity matrix
        for B_idx = A_idx:num_obj
            count = count + 1;
            disp(count);
            
            A_id = ids( floor((A_idx-1)/length(ids)) + 1 ); % the actual frame number
            A_fr = frs( mod((A_idx-1), length(ids)) + 1 ); % the actual id number of the object
            B_id = ids( floor((B_idx-1)/length(ids)) + 1 );
            B_fr = frs( mod((B_idx-1), length(ids)) + 1 );
            
            A_mat = cropped(A_fr,A_id).mat;
            B_mat = cropped(B_fr,B_id).mat;

            A = FT_VEC(A_fr,A_id);
            B = FT_VEC(B_fr,B_id);
            SIM_roipool(A_idx,B_idx) = mat_sim(A, B,'roipool'); 
            SIM_contrib_roipool(A_idx,B_idx) = mat_sim(A, B,'contrib_roipool');
            
            A_chist = my_color_hist(A_mat);
            B_chist = my_color_hist(B_mat);
            SIM_color_hist(A_idx,B_idx) = mat_sim(A_chist,B_chist,'color_hist');
 
            A_chist = my_color_hist_weight(resized(A_fr).img,sum(A.contrib_conv1_1,3));
            B_chist = my_color_hist_weight(resized(B_fr).img,sum(B.contrib_conv1_1,3));
            SIM_color_hist_conv1_contrib(A_idx,B_idx) = mat_sim(A_chist,B_chist,'color_hist');
            if CALC_DEEP_MATCH
                 matches = my_deepmatch(A_mat, B_mat);
                 SIM_DM(A_idx,B_idx) = size(matches, 1)/sqrt(length(A_mat(:))*length(B_mat(:)));
            end
           
        end
    end

end


% post processing
SIM_roipool = matrix_max_percent(SIM_roipool);
SIM_DM = matrix_max_percent(SIM_DM);
SIM_color_hist = matrix_max_percent(SIM_color_hist);
SIM_color_hist_conv1_contrib = matrix_max_percent(SIM_color_hist_conv1_contrib);
SIM_contrib_roipool = matrix_max_percent(SIM_contrib_roipool);



%for roi_ind = 1:size(rois,1)
%    box = squeeze(rois(roi_ind,:));
%    rectangle('Position',[box(2),box(3),box(4)-box(2),box(5)-box(3)]);
%end