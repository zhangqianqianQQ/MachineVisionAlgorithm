%% Creating dataset images 2
% 
% Reading from Stadtmitte dataset
% 
% Read annotations file in csv format
% Open images and crop and resize them
% Store images in standard format of 3840 int (96x40 pixel) 
% 
% Here a single annotation file has all data stored
% Format is "<im_no>,<ped_no>,<x>,<y>,<w>,<h>"
% Images are also all in the same folder
% 
% Author:   Shardul Jade
% Date:     06/04/2017
% 

%% Code begins

close all;

imadd_St = 'D:\studies\DDP\Datasets\3DMOT2015\train\TUD-Stadtmitte\img1';
anadd_St = 'D:\studies\DDP\Datasets\3DMOT2015\train\TUD-Stadtmitte\gt';
anfnm_St = 'gtnn.txt';
imfnm = dir(imadd_St);

anfad_St = strcat(anadd_St,'\',anfnm_St);
imsz = size(imfnm,1);

ped_St_flags = zeros((imsz-2),2);

%% Read file and process

an_file = csvread(anfad_St);
ansz = size(an_file,1);

ped_im_mat = [];
ped_im_add = [];

for i = 1:ansz
    im_no = an_file(i,1);
    ped_St_flags(im_no,1) = im_no;                  % image no
    ped_St_flags(im_no,2) = ped_St_flags(im_no,2)+1;% no of peds
    
    im_nm = strcat(imadd_St,'\',imfnm(im_no+2).name);
    ped_im_add = vertcat(ped_im_add,im_nm);
    
    im = imread(char(im_nm));
    imc = imcrop(im,an_file(i,3:6)+[-2,-2,4,4]);
    imc = rgb2gray(imc);
    imc = imresize(imc,[96,40]);
    
    imr = imc(:)';
    ped_im_mat = vertcat(ped_im_mat,imr);
    
    disp(i);
end