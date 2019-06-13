%    Script that gives a demo of the saliency method presented in 
%    Saliency-Aware Geodesic Video Object Segmentation CVPR2015
%    Contact: wenguanwang@bit.edu.cn or wenguanwang.china@gmail.com

clc
clear

options.valScale = 60;
options.alpha = 0.02;
options.salScale = 0.1;
options.color_size = 5;
% Print status messages on screen
options.vocal = true;
options.regnum =500;
options.m = 20;
options.topRate = 0.01;
options.gradLambda = 1;

addpath( genpath( '.' ) );
foldername = fileparts( mfilename( 'fullpath' ) );

videoFiles = dir(fullfile(foldername, 'data', 'inputs'));
videoNUM = length(videoFiles)-2;

for videonum = 1:videoNUM
    videofolder =  videoFiles(videonum+2).name;
    
    if( options.vocal )
       disp( ['Processing:', videoFiles(videonum+2).name]);
    end
    
    options.infolder = fullfile( foldername, 'data', 'inputs',videofolder );
    options.outfolder = fullfile( foldername, 'data', 'outputs', videofolder );
    %Getting final saliency results
    sal{videonum} = computeSaliency(options);
end