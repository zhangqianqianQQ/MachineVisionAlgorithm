%% Creating negative dataset images
%
% This is the code for Caltech USA Dataset
% 
% We create negative images for the classifier
% First part involves getting addresses
% code for it is written
%
% Second part is reading annotations file and selecting those with no peds
% Use standard bounding boxes mentioned in [posn dimn] to crop them
%
% Third part is strung along second
% The resized cropped neg images need to be stored together in a matrix
%
% Author:   Shardul Jade
% Date:     03/05/2017
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

tot_add_n = zeros(filecount,1);
% ped_nim_add=[];
ped_nim_mat=[];
% im_mat = [];
loopcount = 0;
posn = [80 200; 160 280; 320 160; 400 200; 520 200];
dimn = [20 48; 40 96; 80 192];

for i = 1:filecount
    filename = tot_add(i,2);
    fid = fopen(char(tot_add(i,2)));
%    disp(tot_add(i,2));
    tline0 = fgetl(fid);
    tline1 = fgetl(fid);
    no_npeds = 0;
    no_im_peds = 0;
    
    if (tline1==-1)
        % create neg images
        nir5 = ceil(rand(1)*5);
        nir3 = ceil(rand(1)*3);
        for nin = 1:5
            inc5 = mod(nir5+nin,5)+1; % randomized crop order
            inc3 = mod(nir3+nin,3)+1;
            imnc = imread(char(tot_add(i,1)));
            imnc = imcrop(imnc,[posn(inc5,:) dimn(inc3,:)]); % fill in crop size
            imnc = rgb2gray(imnc);
            imnc = imresize(imnc,[96,40]);
            imnr = imnc(:)';
%                 ped_nim_add = vertcat(ped_nim_add,[filename,nica(i,:)]);
            ped_nim_mat = vertcat(ped_nim_mat,imnr);
            no_npeds = no_npeds+1;
            loopcount = loopcount+1; disp(loopcount);
        end

    else
        % do nothing
    end
    
%     while ischar(tline)
%         tline = fgetl(fid);
%         if (tline==-1)
%             % create neg images
%             nir5 = ceil(rand(1)*5);
%             nir3 = ceil(rand(1)*3);
%             for nin = 1:5
%                 inc5 = mod(nir5+nin,5)+1; % randomized crop order
%                 inc3 = mod(nir3+nin,3)+1;
%                 imnc = imread(char(tot_add(i,1)));
%                 imnc = imcrop(imnc,[posn(inc5,:) dimn(inc3,:)]); % fill in crop size
%                 imnc = rgb2gray(imnc);
%                 imnc = imresize(imnc,[96,40]);
%                 imnr = imnc(:)';
% %                 ped_nim_add = vertcat(ped_nim_add,[filename,nica(i,:)]);
%                 ped_nim_mat = vertcat(ped_nim_mat,imnr);
%                 no_npeds = no_npeds+1;
%                 loopcount = loopcount+1; disp(loopcount);
%             end
%             
%         else
%             % do nothing
%             
% %             str = sscanf(char(tline),'%*s %d %d %d %d %d %d %d %d %d %d %d');
% %             if str(5,1)~=1
% %                 imc = imread(char(tot_add(i,1)));
% %                 imc = imcrop(imc,str(1:4));
% %                 imc = rgb2gray(imc);
% %                 imc = imresize(imc,[96,40]);
% %                 
% %                 imr = imc(:)';
% %                 ped_im_add = vertcat(ped_im_add,[filename,str(1:4)']);
% %                 ped_im_mat = vertcat(ped_im_mat,imr);
% % %                 im_mat = vertcat(im_mat,[filename,imr]);
% %                 
% %                 no_peds = no_peds+1;
% %                 
% %                 loopcount = loopcount+1; disp(loopcount);
% %                 
% %             end
%         end
%         no_im_peds = no_im_peds+1;
%     end
%     
    fclose(fid);
    tot_add_n(i,1) = no_npeds;    % bool non occluded peds

end
% im_matrix = struct('filename',im_name,'image',im_conc);