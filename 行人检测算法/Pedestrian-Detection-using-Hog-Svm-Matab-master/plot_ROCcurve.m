function plot_ROCcurve()
% PLOT_ROCCURVE asks for a svm model file, pos & neg images 
%               and plots the ROC curve. 
%  
%   ... 
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 11-Jan-2014 19:05:13 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : plot_ROCcurve.m 

% load model
[model_file,full_path,~] = uigetfile('.\models','Select model');
model = load([full_path,filesep,model_file]);
names = fieldnames(model);
model = getfield(model, names{1});

% ROC plotting
[pos_ims, neg_ims] = get_files(-1,-1);
[labels, matrix] = get_feature_matrix(pos_ims, neg_ims);
plotroc(labels, matrix, model.hog)
