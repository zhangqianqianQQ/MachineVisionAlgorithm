function draw_sliding_window(I, model)
% DRAW_SLIDING_WINDOW function that given an image and a model scans 
% exhaustively over a scale-space pyramid the image for pedestrians
% drawing the sliding detection window and the confidence probability.
%
% INPUT:
%       model: model to test
%       I: image to scan
%   
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: - $ 
%$ Revision : 1.00 $ 
%% FILENAME  : draw_sliding_window.m 

% Testing if param file exists in the params directory
if exist(['params',filesep,'detect_and_draw.params'],'file')
    test_params = load(['params',filesep,'detect_and_draw.params'],'-ascii');

% Testing if param file exists in the current directory
elseif exist('detect_and_draw.params','file')
    test_params = load('detect_and_draw.params','-ascii');

% Dialog to select param file
else
    [param_file,PathName,~] = uigetfile('*.params','Select parameter file');
    if ~isa(param_file,'double')
        test_params = load([PathName,filesep,param_file],'-ascii');
    else
        cprintf('Errors','Missing param file...\nexiting...\n\n');
        return
    end
end
  
%% wiring up the param vars
th = test_params(1);
scale = test_params(2);
hog_size = test_params(3); 
stride = test_params(4);

% fprintf('Threshold=%f\n',th)
% fprintf('Scale=%f\n',scale)
% fprintf('Descriptor size=%f\n',hog_size)
% fprintf('Window stride=%f\n',stride)

%% color definitions
red = uint8([255,0,0]);
green = uint8([0,255,0]);

%% shape inserters
ok_shapeInserter = ...
    vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',green);
ko_shapeInserter = ...
    vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',red);

ti = tic;
fprintf('\nbegining the pyramid hog extraction...\n')
[hogs, ~, wxl, coordinates] = get_pyramid_hogs(I, hog_size, scale, stride);
tf = toc(ti);
fprintf('time to extract %d hogs: %d\n', size(hogs,1), tf);

%% refer coordinates to the original image... (Level0)
% for each window in every level...
ind = 1;
for l=1:size(wxl,2)
    ws= wxl(l);
    for w=1:ws
        % compute original coordinates in Level0 image 
        factor = (scale^(l-1));
        coordinates(1,ind) = floor(coordinates(1,ind) * factor);
        coordinates(2,ind) = floor(coordinates(2,ind) * factor);
        ind = ind + 1;
    end
end

%% SVM prediction for all windows... 
[predict_labels, ~, probs] = ...
    svmpredict(zeros(size(hogs,1),1), hogs, model, '-b 1');
   
% draw in the original image the detecction window
% red: not detected
% green: detected
for i=1:numel(predict_labels)
    [level, ~] = get_window_indices(wxl, i);
%     figure('name', sprintf('level %d detection', level));
    
    x = coordinates(1,i);
    y = coordinates(2,i);
    factor = (scale^(level-1));
    rectangle = int32([x,y,64*factor,128*factor]);
        
    if predict_labels(i) == 1 && probs(i) > th
       % J = step(ok_shapeInserter, I, rectangle);
       % J = insertText(J, [x,y], probs(i), 'FontSize',9,'BoxColor', 'green');
       % imshow(J);
       % figure(gcf); 
        %pause(0.5);
       disp('ok');
    else
        disp('mok');
        J = step(ko_shapeInserter, I, rectangle);
        imshow(J);
        figure(gcf); 
    end
end
% closing all figures...
% close all
end




%% Aux func. to get the level and window number given a linear index
function [level, num_window] = get_window_indices(wxl, w_linear_index)
    accum_windows = 0;
    for i=1:size(wxl,2)
        accum_windows = accum_windows + wxl(i);
        if w_linear_index <= accum_windows
           level = i;
           num_window = accum_windows - w_linear_index;
           break 
        end
    end

end