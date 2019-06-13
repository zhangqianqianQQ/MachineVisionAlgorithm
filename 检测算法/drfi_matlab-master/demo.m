addpath(genpath('.'));

image_name = './data/1_45_45397.png';
image = imread( image_name );

para = makeDefaultParameters;

% acclerate using the parallel computing
% matlabpool

t = tic;
smap = drfiGetSaliencyMap( image, para );
time_cost = toc(t);
fprintf( 'time cost for saliency computation using DRFI approach: %.3f\n', time_cost );

subplot('121');
imshow(image);
subplot('122');
imshow(smap);