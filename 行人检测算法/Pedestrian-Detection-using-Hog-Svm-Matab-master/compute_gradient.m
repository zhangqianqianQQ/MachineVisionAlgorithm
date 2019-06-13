function [angles,magnitudes] = compute_gradient(I)
% COMPUTE_GRADIENT Function to compute the image gradient in polar form 
%                  between 0º and 180º.
%
% INPUT:
%       I: input Image
%
% OUTPUT:
%       angles: angles of the gradient vectors for each pixel
%       magnitudes: module of the gradient vectors for each pixel 
% 
%$ Author: Jose Marcos Rodriguez $    
%$ Date: N/D $    
%$ Revision: 1.03 $


%% Image reading and adjust to enhace contrast
[cols,rows,color_depth] = size(I);

%% Derivatives masks
dx = [-1,0,1];
dy = -dx';

%% computing the derivative of the extended image and cutting the extended
%% borders
if color_depth == 1
    
    % Adding a 1 pixel border to the image to avoid boundary conditions
    I = imadjust(I);
    extended_img = ones(cols+2,rows+2,color_depth);
    extended_img(2:1+cols,2:1+rows,:) = I(:,:,:);
    
    % Computing the gradient
    Gx = filter2(dx,double(extended_img));
    Gx = Gx(1:cols,1:rows);
    Gy = filter2(dy,double(extended_img));
    Gy = Gy(1:cols,1:rows);
    
    % Tranforming the gradient vectors to polar form
    angles = atan2(Gy,Gx);
    magnitudes = sqrt(Gy.^2 + Gx.^2);
    
elseif color_depth > 1
    
    % Computing gradient for every chanel
    [red_angs, red_mags] = compute_gradient(I(:,:,1));
    [green_angs, blue_mags] = compute_gradient(I(:,:,2));
    [blue_angs, green_mags] = compute_gradient(I(:,:,3));

    % magnitudes as the max magnitud over the three chanels
    magnitudes = max(green_mags,max(red_mags,blue_mags));

    % angle of the chanel with maximum magnitude
    angles = zeros(size(magnitudes));
    angles(magnitudes == red_mags) = red_angs(magnitudes == red_mags);
    angles(magnitudes == blue_mags) = green_angs(magnitudes == blue_mags);
    angles(magnitudes == green_mags) = blue_angs(magnitudes == green_mags);
end

%% Making angles be between [0,180] degrees
% As atan2 gives angles in [-pi,pi] we filter negative values for
% having all angles in [0,pi] (1st & 2nd quadrant)
angles(angles(:)<0) = angles(angles(:)<0)+pi;


