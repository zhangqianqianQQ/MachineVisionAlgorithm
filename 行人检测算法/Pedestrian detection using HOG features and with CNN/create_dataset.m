%% Creating dataset images
%
% This is the code for Caltech USA Dataset
% 
% First part involves getting addresses
% code for it is written
%
% Second part is reading annotations file and getting bounding boxes
% Use these bounding boxes to crop them from images and resize
%
% Third part is strung along second
% The resized cropped images need to be stored together in a matrix
% 
% Later stages will involve clubbing with occluded images
%
% Author:   Shardul Jade
% Date:     06/04/2017
% 

%% Code begins

close all;

imadd = 'D:\studies\DDP\Datasets\CNN-dat\images'; %images main folder
anadd = 'D:\studies\DDP\Datasets\CNN-dat\annotations'; %annotations

%% Reading filenames

[Pim, Fim] = subdir(imadd);
[Pan, Fan] = subdir(anadd);
psz = size(Pim,2);

filecount = 0;
tot_add = [];

for i = 1:psz
    fsz = size(Fim{i},2);
    for j = 1:fsz
        curr_im_add = strcat(Pim(i),'\',Fim{i}(j));
        curr_an_add = strcat(Pan{i},'\',Fan{i}(j));
        tot_add = vertcat(tot_add,[curr_im_add curr_an_add]);
        filecount = filecount+1;
    end
end

%% Reading files

tot_add_flags = zeros(filecount,3);
ped_im_add=[];ped_im_mat=[];
im_mat = [];
loopcount = 0;

for i = 1:filecount
    filename = tot_add(i,2);
    fid = fopen(char(tot_add(i,2)));
%    disp(tot_add(i,2));
    tline = fgetl(fid);
    no_peds = 0;
    no_im_peds = 0;
    while ischar(tline)
        tline = fgetl(fid);
        if (tline==-1)
            % do nothing
        else
            str = sscanf(char(tline),'%*s %d %d %d %d %d %d %d %d %d %d %d');
            if str(5,1)~=1
                imc = imread(char(tot_add(i,1)));
                imc = imcrop(imc,str(1:4));
                imc = rgb2gray(imc);
                imc = imresize(imc,[96,40]);
                
                imr = imc(:)';
                ped_im_add = vertcat(ped_im_add,[filename,str(1:4)']);
                ped_im_mat = vertcat(ped_im_mat,imr);
%                 im_mat = vertcat(im_mat,[filename,imr]);
                
                no_peds = no_peds+1;
                
                loopcount = loopcount+1; disp(loopcount);
                
            end
        end
        no_im_peds = no_im_peds+1;
    end
    fclose(fid);
    tot_add_flags(i,2) = 1*(no_peds~=0);    % bool non occluded peds
    tot_add_flags(i,1) = 1*(no_im_peds~=1); % bool all peds
    tot_add_flags(i,3) = no_peds;           % no of peds in image

end
% im_matrix = struct('filename',im_name,'image',im_conc);