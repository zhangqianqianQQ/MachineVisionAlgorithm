%compare roi pool between bike and person

%script to reverse the entire network
s = size(original_img);
im_size = [s(1), s(2)];
contrib_cls_person_score = 1;

cls_ind = 16; %16 is person, 1 is background, 3 bike
[val, roi_ind] = max(squeeze(cls_prob(:,cls_ind)));
roi_ind = 83; % 1,9,13,14,19,26,60,102 for 0002.jpg % 83 person, 73 bike for out_0_7
fc7_roi = squeeze(fc7(roi_ind,:));
fc6_roi = squeeze(fc6(roi_ind,:));
pool_5_roi = squeeze(pool_5(roi_ind,:,:,:));
roi = rois(roi_ind,:);
contrib_fc7 = reverse_fc(fc7_roi,contrib_cls_person_score,cls_score_weights(:,cls_ind));
contrib_fc6 = reverse_fc(fc6_roi,contrib_fc7,fc7_weights);
contrib_roipool = reverse_fc(flat_reshape(pool_5_roi),contrib_fc6,fc6_weights);
contrib_person = reverse_flat_reshape(contrib_roipool, size(pool_5_roi));
disp('completed contrib_roipool_person')

cls_ind = 3; %16 is person, 1 is background, 3 bike
[val, roi_ind] = max(squeeze(cls_prob(:,cls_ind)));
roi_ind = 73; % 1,9,13,14,19,26,60,102 for 0002.jpg % 83 person, 73 bike for out_0_7
fc7_roi = squeeze(fc7(roi_ind,:));
fc6_roi = squeeze(fc6(roi_ind,:));
pool_5_roi = squeeze(pool_5(roi_ind,:,:,:));
roi = rois(roi_ind,:);
contrib_fc7 = reverse_fc(fc7_roi,contrib_cls_person_score,cls_score_weights(:,cls_ind));
contrib_fc6 = reverse_fc(fc6_roi,contrib_fc7,fc7_weights);
contrib_roipool = reverse_fc(flat_reshape(pool_5_roi),contrib_fc6,fc6_weights);
contrib_bike = reverse_flat_reshape(contrib_roipool, size(pool_5_roi));
disp('completed contrib_roipool_bike')


contrib_bike;
contrib_person;
cmax = max([contrib_bike(:); contrib_person(:)]);

for ch = 1:512
    name = ['output/roipool_comp_' num2str(ch) '.jpg']
    img = zeros(7,15);
    img(:,1:7) = contrib_bike(:,:,ch);
    img(:,9:15) = contrib_person(:,:,ch);
    img = img/cmax;
    img(:,8) = 1;
    img = imresize(img, ceil(500/7), 'nearest');
    imwrite(img,name);
end