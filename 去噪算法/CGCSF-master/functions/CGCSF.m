function CGCSF_CRMS_thr = CGCSF( img, block_size, STRFcondition, distortion )
% %------------------------------------------------------------------------
% % function CGCSF (Contrast Gain Control with Structural
% % Facilitation). Generates the distortion-visibility
% % (contrast-detection-thresholds) of a distortion
% % when overlayed on the input image
% % 
% % Input: img: RGB/Grayscale 8 bit image
% %        block_size: size of the block to divide the image
% %                    recommended to choose such that
% %                    image size is integer multiple of
% %                    the block_size. For example if image
% %                    size is 512x768 block size can be 
% %                    32x32 or 64x64 or 32x64 or 64x32
% %        STRFcondition: Either of the following three
% %                    'AlwaysON': Always use the structural
% %                    facilitation
% %                    'AlwaysOFF': Shuts down the structural
% %                    facilitation. Direct contrast gain
% %                    control model is used
% %                    'ImageDependent': For some images
% %                    it will use structural facilitation,
% %                    some images wont use structural facilitation
% %                    depending on image statistics.
% %        distortion: A distortion image, same size as the input
% %                    image
% %  
% % Output:
% %        CGCSF_CRMS_thr: contrast detection thresholds
% %  
% % Questions?Bugs?
% % Please contact by: Mushfiqul Alam
% %                    mushfiqulalam@gmail.com
% %
% % If you use the codes, cite the following works:
% %     •	Alam, M. M., Vilankar, K.P., Field, D.J., and Chandler, D.M., 
% %     ‘‘Local masking in natural images: A database and analysis,’’ 
% %     Journal of Vision, July 2014, vol. 4, no. 8.
% %     •	Alam, M. M., Nguyen, T., and Chandler, D. M., 
% %     "A perceptual strategy for HEVC based on a convolutional neural 
% %     network trained on natural videos," SPIE Applications of Digital 
% %     Image Processing XXXVIII, August 2015. Doi: 10.1117/12.2188913.    
% %------------------------------------------------------------------------

%---------------------------------------------------
% If no input found; return 
%---------------------------------------------------
if (nargin == 0)
    disp('Input image required. Ending program.');
    return;
end

%---------------------------------------------------
% Check if the input image is valid
%---------------------------------------------------
if (ndims(img) == 1)
    disp('Valid image input required. Ending program.');
end

%---------------------------------------------------
% If block_size was not provided, 
% set block_size default to 64
%---------------------------------------------------
if ~exist('block_size', 'var') || isempty(block_size)
    
    % default block size
    block_size(1) = 64;
    block_size(2) = 64;
    
end

%---------------------------------------------------
% Normalizing and rgb2gray conversion if needed
%---------------------------------------------------
if (ndims(img) == 3)
    img = rgb2gray(img);
end
img = double( img );

%---------------------------------------------------
% If the image size is not integer multiple of
% block_size, crop the image so that the cropped
% region is integer multiple of block_size
%---------------------------------------------------
if ( ( rem(size(img, 1), block_size(1)) ~= 0 ) || ( rem(size(img, 1), block_size(2)) ~= 0 ) )
    disp('Warning! Image size is not interger multiple of block size');
    disp('Proceeding with CROPPED image, making image size integer multiple of block size.');
    img = img( 1 : floor(size(img, 1)/block_size(1))*block_size(1), ...
               1 : floor(size(img, 2)/block_size(2))*block_size(2) );
end

%---------------------------------------------------
% Is structural facilitation always on or image
% dependent? Default is always on
%---------------------------------------------------
if ~exist('STRFcondition', 'var') || isempty(STRFcondition)
    
    % default block size
   STRFcondition = 'AlwaysON';
    
end

%---------------------------------------------------
% If distortion image was not provided a 3.69 cycles/deg vertically
% oriented log-Gabor noise target will be used as target described in the
% Alam et. al., "Local Masking in natural scenes: A database and Analysis,"
% Journal of Vision 2014.
%---------------------------------------------------
if ~exist('distortion', 'var') || isempty(distortion)
    distortion = generate_distortion( size(img) );
end

if (ndims(distortion) == 3)
    disp('Distortion must be a 2D data. Ending program.');
    return;
end

figure('Name', 'Image/Mask and Distortion');
subplot(1,2,1), imshow(uint8(img));
title('Image/Mask');
subplot(1,2,2), imshow(distortion, []);
title('Distortion');

CGCSF_CRMS_thr = generate_CRMS_thr( img, block_size, STRFcondition, distortion );
