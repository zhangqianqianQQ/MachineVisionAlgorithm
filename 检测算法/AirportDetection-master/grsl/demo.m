%  created on 01/16/2019
%  author: Qijian Zhang, Beijing Normal University, China
%  email: zhangqijian1106@163.com

%  Implementation of Paper: Q. Zhang, L. Zhang, W. Shi and Y. Liu, 
%  "Airport Extraction via Complementary Saliency Analysis and Saliency-Oriented Active Contour Model," 
%  in IEEE Geoscience and Remote Sensing Letters, vol. 15, no. 7, pp. 1085-1089, July 2018.

%  We also provide some successful data samples (100 images with 600*600 pixels) 

%  If you use this code for academic purposes, please cite the paper above.

close all; 
clear;
clc
%% path configuration
dataset_folder = [pwd,'\samples\'];
output_folder = [pwd,'\output\'];
format = '.png';
F = dir([dataset_folder,'*',format]);
for img_idx = 1 : length(F)
tic
img_name = F(img_idx).name(1:end-4);
img_path = [dataset_folder,img_name,format];
img = imread(img_path);
img_size = size(img);
%% apply lsd and refine detected line segments
lines_info = apply_lsd(img_path);
lines_refined = refine_lines(lines_info,img_size);
% figure,imshow(img),hold on,
% line(lines_refined([1,2],:),lines_refined([3,4],:), 'Color', [1,0,0], 'LineWidth', 1.5)
%% obtain saliency map 
% Note that in this code we converted to a new method for compute kos&vos 
% that differs from the original design in our paper, because our futher 
% researches show that SLIC is not very robust in complex scenes.

%-- obtain kos map
kos_map = obtain_kos_map(lines_refined,img_size);

%-- obtain vos map
N = 12;
img_q = quantization(img,N);
vos_map = obtain_vos_map(img_q,N);

%-- fuse kos and vos
gaus_sigma = 0.4;
smap = mat2gray(exp(kos_map.*vos_map/0.4));

%-- binarize the smap to smap_b
th_rescale = 1.2;
th = th_rescale * graythresh(smap); % using ostu method ofr binarization
smap_b = imbinarize(smap,th);
smap_b = reserve_major_islands(smap_b);
%% extract local evolving window (lew_rgb), where soacm is applied
num_epoch = 400; 
[obj_contour_local,i_min,i_max,j_min,j_max] = apply_soacm(img,smap_b,num_epoch);
[obj_contour_local,~] = get_kth_islands(obj_contour_local,1);
obj_contour = zeros(img_size(1),img_size(2));
obj_contour(i_min:i_max,j_min:j_max) = obj_contour_local;
delta_t = toc;
disp([img_name,format,': ',int2str(round(delta_t*1000)),'ms']);
%% generate bounding box on original image
bbox = generate_bbox(img,obj_contour);
%% visualize/save
% uncomment the following to visualize or save results

% figure,
% subplot(131),imshow(smap),title('saliency map');
% subplot(132),imshow(obj_contour),title('object contour');
% subplot(133),imshow(img),title('bbox'),hold on,
% [ii,jj] = find(obj_contour~=0);
% rectangle( 'LineWidth',1,'EdgeColor','r','Position',...
%            [min(jj),min(ii),(max(jj)-min(jj)),(max(ii)-min(ii))])

% imwrite(smap,[output_folder,img_name,'_1_sm',format]);
% imwrite(obj_contour,[output_folder,img_name,'_2_ct',format]);
% imwrite(bbox,[output_folder,img_name,'_3_bb',format]);
end