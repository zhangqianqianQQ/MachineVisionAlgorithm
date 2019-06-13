function STR = generate_structural_map( img, luminanceConversion, view_structure_map )
% %------------------------------------------------------------------------
% % function generate_structural_map. Generates a map of recognizable
% % structures wihin the image region.
% % 
% % Input: img: RGB/Grayscale 8 bit image
% %        luminanceConversion: parameters for display gamma curve
% %                    Example: luminanceConversion.b       = 0.0794;
% %                             luminanceConversion.k       = 0.9195*0.03;
% %                             luminanceConversion.gamma   = 2.358;
% %        view_structure_map: if 1, will show the structure map
% %  
% % Output:
% %        STR: the structure map
% %  
% % Questions?Bugs?
% % Please contact by: Mushfiqul Alam
% %                    mushfiqulalam@gmail.com
% %
% % If you use the codes, cite the following works:
% %     •	Alam, M. M., Nguyen, T., and Chandler, D. M., 
% %     "A perceptual strategy for HEVC based on a convolutional neural 
% %     network trained on natural videos," SPIE Applications of Digital 
% %     Image Processing XXXVIII, August 2015. Doi: 10.1117/12.2188913.    
% %------------------------------------------------------------------------
disp('Creating structure map...');

structure_blk_size = [32 32];
structure_overlap  = 50;
fractal_nt       = 1;

%---------------------------------------------------
% generate sharpness map using s3 sharpness
% measure developed by Cuong Vu et al.
%---------------------------------------------------
[s_map1 s_map2 s3] = s3_map( img, 0 );
% blocking the s3 sharpness map
sharpness_blk = blocking_function( s3, structure_blk_size, structure_overlap );

img_blk = blocking_function( img, structure_blk_size, structure_overlap );

luminance_map       = zeros( size(img_blk) );
entropy_map         = zeros( size(img_blk) );
average_fractal_map = zeros( size(img_blk) );
std_fractal_map     = zeros( size(img_blk) );
sharpness_map       = zeros( size(img_blk) );


for i = 1 : size(img_blk, 1)
    for j = 1 : size(img_blk, 2)
        
        blk = img_blk{i, j};
        
        % double and uint8
        blk_u = uint8( blk );
        blk_d = double( blk );
        
        % luminance
        blk_luminance = ( luminanceConversion.b + luminanceConversion.k * blk_d ) .^ luminanceConversion.gamma;
        luminance_map(i, j) = mean2(blk_luminance);
        
        % entropy
        entropy_map(i, j) = entropy( blk_u(:) );
        
        % fractal
        temp = sfta( blk_u, fractal_nt );
        temp(isnan(temp)) = [];
        average_fractal_map(i, j) = mean(temp);
        std_fractal_map(i, j)     = std(temp);
        
        % sharpness
        sharpness_map(i, j) = mean2(sharpness_blk{i, j});
        
    end
    
end

%---------------------------------------------------
% Clipping values to empirical minimum and maximums
%---------------------------------------------------
lum_min = 0.0027;
lum_max = 94.4808;
luminance_map( luminance_map < lum_min )                = lum_min;
luminance_map( luminance_map > lum_max )                = lum_max;

entropy_min = 0;
entropy_max = 7.7664;
entropy_map( entropy_map < entropy_min )                = entropy_min;
entropy_map( entropy_map > entropy_max )                = entropy_max;

average_fractal_min = 0;
average_fractal_max = 268.6723;
average_fractal_map( average_fractal_map < average_fractal_min )   = average_fractal_min;
average_fractal_map( average_fractal_map > average_fractal_max )   = average_fractal_max;

std_fractal_min = 0;
std_fractal_max = 264.7019;
std_fractal_map( std_fractal_map < std_fractal_min )    = std_fractal_min;
std_fractal_map( std_fractal_map > std_fractal_max )    = std_fractal_max;

sharpness_min = 0;
sharpness_max = 209.4375;
sharpness_map( sharpness_map < sharpness_min )          = sharpness_min;
sharpness_map( sharpness_map > sharpness_max )          = sharpness_max;

normalized_luminance_map        = (luminance_map - lum_min) / (lum_max-lum_min);
normalized_entropy_map          = (entropy_map - entropy_min) / (entropy_max-entropy_min);
normalized_average_fractal_map  = (average_fractal_map - average_fractal_min) / (average_fractal_max-average_fractal_min);
normalized_std_fractal_map      = (std_fractal_map - std_fractal_min) / (std_fractal_max - std_fractal_min);
normalized_sharpness_map        = (sharpness_map - sharpness_min) / (sharpness_max - sharpness_min);

%---------------------------------------------------
% interpolating to create map
%---------------------------------------------------
L  = imresize(normalized_luminance_map, size(img), 'bicubic');
Sh = imresize(normalized_sharpness_map, size(img), 'bicubic');
E  = imresize(normalized_entropy_map, size(img), 'bicubic');
D1 = imresize(normalized_average_fractal_map, size(img), 'bicubic');
D2 = imresize(normalized_std_fractal_map, size(img), 'bicubic');

%---------------------------------------------------
% The structure map
%---------------------------------------------------
STR = L.*E.*Sh.*(1-D1).^2.*(1-D2).^2;
STR(STR<0) = 0;

if (view_structure_map == 1)
    figure('Name', 'Structure map');
    imshow(STR, []);
end

disp('Done creating structure map.');
