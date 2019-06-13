% Example for extracting dense Color Histogram and dense SIFT feature from
% a test image
%
% Created by Rui Zhao, rzhao@ee.cuhk.edu.hk 
% May 11, 2013.
%

im = imread('test.png');
gridstep = 4;
patchsize = 10;

% get number of patches in two directions
[h, w, ~] = size(im);
nx = length(patchsize/2:gridstep:w-patchsize/2);
ny = length(patchsize/2:gridstep:h-patchsize/2);

% common options for extracting dense color sift feature
clear options1;
options1.gridspacing                = gridstep;
options1.patchsize                  = patchsize;
options1.scale                        = [0.5 , 0.75 , 1]; % downsampled scales 
options1.nbins                        = 32;               % number of bins in computing color histogram
options1.sigma                       = 0.6;               % bandwidth of gaussian function
options1.clamp                       = 0.2;               % clamp in normalization

% common options for dense SIFT features
clear options2;
options2.gridspacing                        = gridstep;
options2.patchsize                           = patchsize;
options2.color                                 = 3;       % color channels
options2.nori                                  = 8;       % number of orientations
options2.alpha                                 = 9;       % parameter for attenuation of angles (must be odd)
options2.nbins                                 = 4;       % histogram bins in computing SIFT
options2.norm                                  = 4;       % normalization type 
options2.clamp                                 = 0.2;     % clamp in normalization
options2.sigma_edge                            = 1.2;     % gaussian function parameters 
[options2.kernely , options2.kernelx]          = gen_dgauss(options2.sigma_edge);

densefeat = get_densefeature(im, options1, options2, ny*nx);
save densefeat.mat densefeat
imagesc(densefeat);

