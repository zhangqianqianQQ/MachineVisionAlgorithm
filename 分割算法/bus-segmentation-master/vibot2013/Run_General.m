clc;close all;clear all; warning off;
addpath(genpath('./libs'));
disp('The demo is Started...');
% ------------------------Team work---------------------------------------%                                                       
% -      Ibrahim Sadek , Mohamed Elawady , Victor Stefanovski            -%
%--------------------------------------------------------------------------
% - This script is intended to segment ultrasound breast lesions images 
% - Methodology : 
% - 1- Apply Image pre-processing.
% - 2- Applying normalized cut technique , partitioning an image into
%      multiple regions according to some homogeneity criterion.
% - 3- Segmentation , measuring the accuracy.               
% - To run the code first you need to do the following:
% - type compileDir_simple to compile the mex files (ignore the error on
% - the C++ non-mex file; needs to be done once)
%%
inputPath = './Data/Input/';
gtPath = './Data/GT/';
fileList = getAllFiles(inputPath,'*.png');

%%
for i=1:numel(fileList)
    file = fileList{i};
    disp(['File #' num2str(i) ' Processing ... ' file]);
    %- Process1: Pre-Processing
    outPre{i} = PreProcessing_General(file);    
    %- Process2: Applying normalized cut
    OutSeg{i} = Segmentation(file);
    %- Process3 : Postprocessing
    outPost{i}=PostProcessing_General(OutSeg{i},file);
    %- Comparison with GT and outputing statistics
    [~,name,ext] = fileparts(file);
    gtFile{i}=imread([gtPath name ext]);
    [statJaccard(i),statDice(i),statRFP(i),statRFN(i)]=sevaluate(gtFile{i},outPost{i});
    PlotAnnotations(gtFile{i},outPost{i},file);
end
close all;
disp('Processing is Finished ...');