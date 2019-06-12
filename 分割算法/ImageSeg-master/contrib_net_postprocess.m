% post process contrib_img
close all;
image(original_img/256+0.5);
box = squeeze(rois(roi_ind,:,:,:,:,:))
rectangle('Position',[box(2),box(3),box(4)-box(2),box(5)-box(3)]);
figure;


img = sum(contrib_conv1_1,3)/max(contrib_conv1_1(:))*10;
image(img);
figure;

contrib_img = reverse_conv_original_img(original_img, contrib_conv1_1, conv1_1_weights);
image(contrib_img/5);
%{
%my_image(contrib_conv1_1, 0.5);
%img = sum(contrib_conv1_1,3)/max(contrib_conv1_1(:));
contrib = contrib_roipool;
s = size(contrib);
for ch = 1:s(3)
    name = ['output/conv_roipool_' num2str(ch) '.jpg']
    img = contrib(:,:,ch);
    img = imresize(img, ceil(500/s(2)), 'nearest');
    img = img/max(contrib(:));
    %imwrite(img,name);
end
%figure;
%}