%==========================================================================
%
%   Active contour with Chen-Vese Method
%   for image segementation
%
%   Implemented by Yue Wu (yue.wu@tufts.edu)
%   Tufts University
%   Feb 2009
%   http://sites.google.com/site/rexstribeofimageprocessing/
%
%   all rights reserved
%   Last update 02/26/2009
%--------------------------------------------------------------------------
%   Usage of varibles:
%   input:
%       I           = any gray/double/RGB input image
%       mask        = initial mask, either customerlized or built-in
%       num_iter    = total number of iterations
%       mu          = weight of length term
%       method      = submethods pick from ('chen','vector','multiphase')
%
%   Types of built-in mask functions
%       'small'     = create a small circular mask
%       'medium'    = create a medium circular mask
%       'large'     = create a large circular mask
%       'whole'     = create a mask with holes around
%       'whole+small' = create a two layer mask with one layer small
%                       circular mask and the other layer with holes around
%                       (only work for method 'multiphase')
%   Types of methods
%       'chen'      = general CV method
%       'vector'    = CV method for vector image
%       'multiphase'= CV method for multiphase (2 phases applied here)
%
%   output:
%       phi0        = updated level set function
%
%--------------------------------------------------------------------------
%
% Description: This code implements the paper: "Active Contours Without
% Edges" by Chan and Vese for method 'chen', the paper:"Active Contours Without
% Edges for vector image" by Chan and Vese for method 'vector', and the paper
% "A Multiphase Level Set Framework for Image Segmentation Using the
% Mumford and Shah Model" by Chan and Vese.
%
%--------------------------------------------------------------------------
% Deomo: Please see HELP file for details
%==========================================================================

function [seg, phi0]= chenvese(I,mask,num_iter,mu,method)

%%
%-- Default settings
%   length term mu = 0.2 and default method = 'chan'
if(~exist('mu','var'))
    mu=0.2;
end

if(~exist('method','var'))
    method = 'chan';
end

%-- End default settings

%%
%-- Initializations on input image I and mask
%  resize original image
row=size(I,1);
col=size(I,2);
s = 200./min(size(I,1),size(I,2)); % resize scale
if s<1
    I = imresize(I,s);
end

%   auto mask settings
if ischar(mask)
    switch lower (mask)
        case 'small'
            mask = maskcircle2(I,'small');
        case 'medium'
            mask = maskcircle2(I,'medium');
        case 'large'
            mask = maskcircle2(I,'large');
        case 'whole'
            mask = maskcircle2(I,'whole');
            %mask = init_mask(I,30);
        case 'whole+small'
            m1 = maskcircle2(I,'whole');
            m2 = maskcircle2(I,'small');
            mask = zeros(size(I,1),size(I,2),2);
            mask(:,:,1) = m1(:,:,1);
            mask(:,:,2) = m2(:,:,2);
        otherwise
            error('unrecognized mask shape name (MASK).');
    end
else
    if s<1
        mask = imresize(mask,s);
    end
    if size(mask,1)>size(I,1) || size(mask,2)>size(I,2)
        error('dimensions of mask unmathch those of the image.')
    end
    switch lower(method)
        case 'multiphase'
            if  (size(mask,3) == 1)
                error('multiphase requires two masks but only gets one.')
            end
    end
    
end


switch lower(method)
    case 'chan'
        if size(I,3)== 3
            P = rgb2gray(uint8(I));
            P = double(P);
        elseif size(I,3) == 2
            P = 0.5.*(double(I(:,:,1))+double(I(:,:,2)));
        else
            P = double(I);
        end
        layer = 1;
        
    case 'vector'
        s = 200./min(size(I,1),size(I,2)); % resize scale
        I = imresize(I,s);
        mask = imresize(mask,s);
        layer = size(I,3);
        if layer == 1
            display('only one image component for vector image')
        end
        P = double(I);
        
    case 'multiphase'
        layer = size(I,3);
        if size(I,1)*size(I,2)>200^2
            s = 200./min(size(I,1),size(I,2)); % resize scale
            I = imresize(I,s);
            mask = imresize(mask,s);
        end
        
        P = double(I);  %P store the original image
    otherwise
        error('!invalid method')
end
%-- End Initializations on input image I and mask

%%
%--   Core function
switch lower(method)
    case {'chan','vector'}
        %-- SDF
        %   Get the distance map of the initial mask
        
        mask = mask(:,:,1);
        phi0 = bwdist(mask)-bwdist(1-mask)+im2double(mask)-.5;
        %   initial force, set to eps to avoid division by zeros
        force = eps;
        %-- End Initialization
        
        %-- Display settings
        figure();
        subplot(2,2,1); imshow(I); title('Input Image');
        subplot(2,2,2); contour(flipud(phi0), [0 0], 'r','LineWidth',1); title('initial contour');
        subplot(2,2,3); title('Segmentation');
        %-- End Display original image and mask
        
        %-- Main loop
        for n=1:num_iter
            inidx = find(phi0>=0); % frontground index
            outidx = find(phi0<0); % background index
            force_image = 0; % initial image force for each layer
            for i=1:layer
                L = im2double(P(:,:,i)); % get one image component
                c1 = sum(sum(L.*Heaviside(phi0)))/(length(inidx)+eps); % average inside of Phi0
                c2 = sum(sum(L.*(1-Heaviside(phi0))))/(length(outidx)+eps); % verage outside of Phi0
                force_image=-(L-c1).^2+(L-c2).^2+force_image;
                % sum Image Force on all components (used for vector image)
                % if 'chan' is applied, this loop become one sigle code as a
                % result of layer = 1
            end
            
            % calculate the external force of the image
            force = mu*kappa(phi0)./max(max(abs(kappa(phi0))))+1/layer.*force_image;
            
            % normalized the force
            force = force./(max(max(abs(force))));
            
            % get stepsize dt
            dt=0.5;
            
            % get parameters for checking whether to stop
            old = phi0;
            phi0 = phi0+dt.*force;
            new = phi0;
            indicator = checkstop(old,new,dt);
%             if n==1
%                 figure;
%                 showphi(I,phi0,n);
%             end
%             
            
            % intermediate output
           
            if(mod(n,20) == 0)
                showphi(I,phi0,n);
            end;
            if indicator % decide to stop or continue
                showphi(I,phi0,n);
                
                %make mask from SDF
                seg = phi0<=0; %-- Get mask from levelset
                if s<1
                    seg = imresize(seg,[row col]);
                end
                
                subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');
                
                return;
            end
        end;
        showphi(I,phi0,n);
        
        %make mask from SDF
        seg = phi0<=0; %-- Get mask from levelset
        
        subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');
    case 'multiphase'
        %-- Initializations
        %   Get the distance map of the initial masks
        mask1 = mask(:,:,1);
        mask2 = mask(:,:,2);
        phi1=bwdist(mask1)-bwdist(1-mask1)+im2double(mask1)-.5;%Get phi1 from the initial mask 1
        phi2=bwdist(mask2)-bwdist(1-mask2)+im2double(mask2)-.5;%Get phi1 from the initial mask 2
        
        %-- Display settings
        figure();
        subplot(2,2,1);
        if layer ~= 1
            imshow(I); title('Input Image');
        else
            imagesc(P); axis image; colormap(gray);title('Input Image');
        end
        subplot(2,2,2);
        hold on
        contour(flipud(mask1),[0,0],'r','LineWidth',2.5);
        contour(flipud(mask1),[0,0],'x','LineWidth',1);
        contour(flipud(mask2),[0,0],'g','LineWidth',2.5);
        contour(flipud(mask2),[0,0],'x','LineWidth',1);
        title('initial contour');
        hold off
        subplot(2,2,3); title('Segmentation');
        %-- End display settings
        
        %Main loop
        for n=1:num_iter
            %-- Narrow band for each phase
            nb1 = find(phi1<1.2 & phi1>=-1.2); %narrow band of phi1
            inidx1 = find(phi1>=0); %phi1 frontground index
            outidx1 = find(phi1<0); %phi1 background index
            
            nb2 = find(phi2<1.2 & phi2>=-1.2); %narrow band of phi2
            inidx2 = find(phi2>=0); %phi2 frontground index
            outidx2 = find(phi2<0); %phi2 background index
            %-- End initiliazaions on narrow band
            
            %-- Mean calculations for different partitions
            %c11 = mean (phi1>0 & phi2>0)
            %c12 = mean (phi1>0 & phi2<0)
            %c21 = mean (phi1<0 & phi2>0)
            %c22 = mean (phi1<0 & phi2<0)
            
            cc11 = intersect(inidx1,inidx2); %index belong to (phi1>0 & phi2>0)
            cc12 = intersect(inidx1,outidx2); %index belong to (phi1>0 & phi2<0)
            cc21 = intersect(outidx1,inidx2); %index belong to (phi1<0 & phi2>0)
            cc22 = intersect(outidx1,outidx2); %index belong to (phi1<0 & phi2<0)
            
            f_image11 = 0;
            f_image12 = 0;
            f_image21 = 0;
            f_image22 = 0; % initial image force for each layer
            
            for i=1:layer
                L = im2double(P(:,:,i)); % get one image component
                
                if isempty(cc11)
                    c11 = eps;
                else
                    c11 = mean(L(cc11));
                end
                
                if isempty(cc12)
                    c12 = eps;
                else
                    c12 = mean(L(cc12));
                end
                
                if isempty(cc21)
                    c21 = eps;
                else
                    c21 = mean(L(cc21));
                end
                
                if isempty(cc22)
                    c22 = eps;
                else
                    c22 = mean(L(cc22));
                end
                
                %-- End mean calculation
                
                %-- Force calculation and normalization
                % force on each partition
                
                f_image11=(L-c11).^2.*Heaviside(phi1).*Heaviside(phi2)+f_image11;
                f_image12=(L-c12).^2.*Heaviside(phi1).*(1-Heaviside(phi2))+f_image12;
                f_image21=(L-c21).^2.*(1-Heaviside(phi1)).*Heaviside(phi2)+f_image21;
                f_image22=(L-c22).^2.*(1-Heaviside(phi1)).*(1-Heaviside(phi2))+f_image22;
            end
            
            % sum Image Force on all components (used for vector image)
            % if 'chan' is applied, this loop become one sigle code as a
            % result of layer = 1
            
            % calculate the external force of the image
            
            % curvature on phi1
            curvature1 = mu*kappa(phi1);
            curvature1 = curvature1(nb1);
            % image force on phi1
            fim1 = 1/layer.*(-f_image11(nb1)+f_image21(nb1)-f_image12(nb1)+f_image22(nb1));
            fim1 = fim1./max(abs(fim1)+eps);
            
            % curvature on phi2
            curvature2 = mu*kappa(phi2);
            curvature2 = curvature2(nb2);
            % image force on phi2
            fim2 = 1/layer.*(-f_image11(nb2)+f_image12(nb2)-f_image21(nb2)+f_image22(nb2));
            fim2 = fim2./max(abs(fim2)+eps);
            
            % force on phi1 and phi2
            force1 = curvature1+fim1;
            force2 = curvature2+fim2;
            %-- End force calculation
            
            % detal t
            dt = 1.5;
            
            old(:,:,1) = phi1;
            old(:,:,2) = phi2;
            
            %update of phi1 and phi2
            phi1(nb1) = phi1(nb1)+dt.*force1;
            phi2(nb2) = phi2(nb2)+dt.*force2;
            
            new(:,:,1) = phi1;
            new(:,:,2) = phi2;
            
            indicator = checkstop(old,new,dt);
            
            if indicator
                showphi(I, new, n);
                %make mask from SDF
                seg11 = (phi1>0 & phi2>0); %-- Get mask from levelset
                seg12 = (phi1>0 & phi2<0);
                seg21 = (phi1<0 & phi2>0);
                seg22 = (phi1<0 & phi2<0);
                
                se = strel('disk',1);
                aa1 = imerode(seg11,se);
                aa2 = imerode(seg12,se);
                aa3 = imerode(seg21,se);
                aa4 = imerode(seg22,se);
                seg = aa1+2*aa2+3*aa3+4*aa4;
                if s<1
                    seg = imresize(seg,[row col]);
                end
                subplot(2,2,4); imagesc(seg);axis image;title('Global Region-Based Segmentation');
                
                return
            end
            % re-initializations
            phi1 = reinitialization(phi1, 0.6);%sussman(phi1, 0.6);%
            phi2 = reinitialization(phi2, 0.6);%sussman(phi2,0.6);
            
            %intermediate output
            if(mod(n,20) == 0)
                phi(:,:,1) = phi1;
                phi(:,:,2) = phi2;
                showphi(I, phi, n);
            end;
        end;
        phi(:,:,1) = phi1;
        phi(:,:,2) = phi2;
        showphi(I, phi, n);
        %make mask from SDF
        seg11 = (phi1>0 & phi2>0); %-- Get mask from levelset
        seg12 = (phi1>0 & phi2<0);
        seg21 = (phi1<0 & phi2>0);
        seg22 = (phi1<0 & phi2<0);
        
        se = strel('disk',1);
        aa1 = imerode(seg11,se);
        aa2 = imerode(seg12,se);
        aa3 = imerode(seg21,se);
        aa4 = imerode(seg22,se);
        seg = aa1+2*aa2+3*aa3+4*aa4;
        %seg = bwlabel(seg);
        subplot(2,2,4); imagesc(seg);axis image;title('Global Region-Based Segmentation');
        
        
end
if s<1
    seg = imresize(seg,[row col]);
end
end

