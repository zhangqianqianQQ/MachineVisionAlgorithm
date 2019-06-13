function [area ratio oocyte_size distance]=feature_extraction(fname)
addpath('data_ready')
K=1;
% for select t1, tried ostu and kmeans, does not work well
area_cutff=[579, 970, 2026,4043, 4690, 6751, 9482, 20933, 50200];
% get the area
[major, minor, area, segout, u, I0, seg, boundary]=Cell_area_convex (fname,K,0);
ratio=major./minor;
oocyte_size='NA';
distance='NA';

stage_estimated=find(area_cutff-area<0, 1, 'last' )+2;
fprintf('Based on cell size, this cell is in stage  %4.0f \n',stage_estimated);
disp('Detecting more features......')
% chenvese segmentation on the cleaned image
t3=3e-3;
seg = chenvese(imadjust(I0),'whole',1000,t3,'chan');
if numel(find(seg==1))>numel(find(seg==0))
    seg=~seg;
end
figure;
imshow(seg)

if area<3800
    choice =1;
else if area>3800 && area<15000
        choice=2;
    else
        choice=3;
    end
end

switch choice
    case 1
        disp('--------------------------------------')
        
        disp('Early Stage Loop')
        
        disp('Detecting Blob-like chromosomes in Polyene Nuclei')
        
        disp('--------------------------------------')
        % get the follicle cell
        [I1]=Cell_follicle(segout, seg, major, u, 6);
        figure;
        imshow(I1);
        title('segmentation mask for follicle cells')
        figure;
        imshow(~I1&seg);
        title('segmentation mask for nurse cells')
        
        I_mark=imfill(~I1&seg,'holes');
        I0(I_mark==0)=0;
        figure;
        imshow(I0)
        title('nurse cells in original intensity')
        
        
        L=Cell_watershed(I0, 3);
        
        
        
        
    case 2
        disp('--------------------------------------')
        
        disp('Middle Stage Loop')
        
        disp('Detecting oocyte size and follicle size distribution')
        
        disp('--------------------------------------')
        
        [center, coeff, score, latent, area_real, level_center, oocyte_size]=Cell_orientation(segout, seg, major, u);
        
        
        % get the follicle cell
        [I1]=Cell_follicle(segout, seg, major, u, 11);
        figure;
        imshow(I1);
        title('segmentation mask for follicle cells')
        figure;
        imshow(~I1&seg);
        title('segmentation mask for nurse cells')
        
        %close all
        
        [distri]=Cell_follicledistribution(segout, I1,coeff);
        figure;
        bar(distri)
        distri_norm=distri./sum(distri);
        %delta distance
        distance=sum((distri_norm-ones(size(distri))./sum(ones(size(distri)))).^2./...
            (distri_norm+ones(size(distri))./sum(ones(size(distri)))));
        fprintf('This delta distance of follicle cell distribution is %4.2f \n',distance);
        
        
        
    case 3
        disp('--------------------------------------')
        
        disp('Late Stage Loop')
    
        disp('Detecting oocyte size, follicle size distribution and centripetal migration')
        disp('--------------------------------------')
        % get the orientation
        [center, coeff, score, latent, area_real, level_center, oocyte_size]=Cell_orientation(segout, seg, major, u);
        
        
        % get the follicle cell
        [I1]=Cell_follicle(segout, seg, major, u, 11);
        figure;
        imshow(I1);
        title('segmentation mask for follicle cells')
        figure;
        imshow(~I1&seg);
        title('segmentation mask for nurse cells')
        
        %close all
        
        [distri]=Cell_follicledistribution(segout, I1,coeff);
        figure;
        bar(distri)
        distri_norm=distri./sum(distri);
        %delta distance
        distance=sum((distri_norm-ones(size(distri))./sum(ones(size(distri)))).^2./...
            (distri_norm+ones(size(distri))./sum(ones(size(distri)))));
        fprintf('This delta distance of follicle cell distribution is %4.2f \n',distance);
        
        % get the inside cell
        I_inside=~I1&seg;
        
        I11=Cell_centri(I_inside,  coeff, latent, area_real, boundary);
        figure;
        imshow(I11)
        hold on
        h=imshow(seg);
        alpha(h,0.2)
        title('highlighted centripetal migration')          
  otherwise
        disp('other value')
end












