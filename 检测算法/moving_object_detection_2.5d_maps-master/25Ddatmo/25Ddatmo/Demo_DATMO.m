%% 2.5d grid-based datmo
% Inputs: Velodyne points and GPS/IMU localization
% Output: Detection and tracking moving objects (DATMO)
% Alireza Asvadi, 2015 Apr
%% clear memory & command window
clc
clear all
close all
%% setting
[st, stack]   = stt;                                          % set parameters
x.trc         = []; ncn = []; k = []; nzn = [];               % keep object locations for plot
%% datmo
for frame     = st.st.st : st.st.tn 

%% observations
[mat, pts]    = obs(st, frame);                               % points (with trns) and grid    
%% robust motion detection / moving object detection
[brm, stack]  = mdl(stack, pts, mat, st);                     % background model
[frm, pts, ocn, szn] = frg(brm, pts, mat, st);                % foreground model & centroid of objects in the world coordinate
%% multiple object tracking
k             = klmi(ocn, ncn, nzn, k, frame, st);            % initialize new kalman filter
[k, ncn, nzn] = asc(k, ocn, szn);                             % data association + new candidates
k             = klmf(k);                                      % kalman tracking                   
x             = plt(x, k, pts, frm, st, frame);               % record object locations and plot

end   

