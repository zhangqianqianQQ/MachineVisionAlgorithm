function static_detector(I,model)
% STATIC_DETECTOR given a folder containing PNG or JPG images applies
%                 the specified libSVM model to scan through every image 
%                 for pedestrians in a sliding window basis.
%  
% All the parameters are hard coded to guaratee independence from
% external files, assuming once this function in run the whole set of 
% parameters are well known and no further experimentation is needed.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 05-Dec-2013 23:09:05 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : static_detector.m 

    %% VARS
    hog_size = 3780;
    scale = 1.2;
    stride = 8;
    show_all = false;
    draw_all = false;
    
    %% color definitions
    green = uint8([0,255,0]);
    yellow = uint8([255,255,0]);
    
    %% shape inserters
    ok_shapeInserter = ...
        vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',green);
    other_shapeInserter = ...
        vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',yellow);

    %images_path = uigetdir('.\..','Select image folder');
    
    %% image reading
   % jpgs = rdir(strcat(images_path,filesep,'*.jpg'));
   % pngs = rdir(strcat(images_path,filesep,'*.png'));
   % images = [jpgs, pngs];
   % num_images = size(images,1);

    %for i=1:num_images
        
        %fprintf('-------------------------------------------\n')
        %disp(images(i).name);
        %I = imread(images(i).name);

        %% Reescale
        [h,w,~] = size(I);
        rscale = min(w/96, h/160);
        I = imresize(I, 1.2/rscale);

        %% HOG extraction for all image windows
        ti = tic;
        fprintf('\nbegining the pyramid hog extraction...\n')
        [hogs, windows, wxl, coordinates] = get_pyramid_hogs(I, hog_size, scale, stride);
        tf = toc(ti);
        fprintf('time to extract %d hogs: %d\n', size(hogs,1), tf);

        %% SVM prediction for all windows... 
        [predict_labels, ~, probs] = ...
            svmpredict(zeros(size(hogs,1),1), hogs, model, '-b 1');

        %% filtering only positives windows instances
        % index of positives windows
        range = 1:max(size(predict_labels));
        pos_indxs = range(predict_labels == 1);
         %pos_indxs = range(probs(1) >= 0.8);

        % positive match information
        coordinates = coordinates';
        coordinates = coordinates(pos_indxs,:);
        probs = probs(pos_indxs,:);


        %% Computing level 0 coordinates for drawing
        [bb_size, l0_coordinates] = compute_level0_coordinates(wxl, coordinates, pos_indxs, scale);
        
        %% Showing all positive windows in separate figures
        if show_all
            windows = windows(:,:,:,pos_indxs);

            for w=1:size(pos_indxs,2)
               figure('name',sprintf('x=%d, y=%d', l0_coordinates(w,1),l0_coordinates(w,2))); 
    %            figure('name',sprintf('x=%d, y=%d', bb_size(w,1),bb_size(w,2))); 
               ii = insertText(windows(:,:,:,w), [1,1], probs(w), 'FontSize',9,'BoxColor', 'green');
               imshow(ii) 
            end
        end

        %% Drawing detections over the original image
        %draw = I;
        shape_inserter = other_shapeInserter;
        if ~draw_all
            
           shape_inserter = ok_shapeInserter;
            
           %% non-max-suppression!
           max_indxs = non_max_suppression(l0_coordinates, probs, bb_size); 
           pos_indxs = pos_indxs(max_indxs);
           l0_coordinates = l0_coordinates(max_indxs,:);
           bb_size = bb_size(max_indxs, :);
           probs = probs(max_indxs,:);
        end
            
        draw = I;
        for w=1:size(pos_indxs,2)
            %% Drawing the rectangle on the original image
            x = l0_coordinates(w,1);
            y = l0_coordinates(w,2);

            % Rectangle conf
            bb_height = bb_size(w,1);
            bb_width = bb_size(w,2);
            rectangle = int32([x,y,bb_width,bb_height]);

            draw = step(shape_inserter, draw, rectangle);
            draw = insertText(draw, [x,y+bb_height], probs(w), 'FontSize',9,'BoxColor', 'green');

        end
        % Showing image with all the detection boxes
        imshow(draw);
        figure(gcf);
      %  pause;
            
    %end
end



%% Aux function to compute the windows coordiantes at level 0 pyramid image
function [bb_size, new_cords] = compute_level0_coordinates(wxl, coordinates, inds, scale)

    % Consts
    bb_width = 64;
    bb_height = 128;
    
    % Vars
    new_cords = zeros(size(inds,2),2);
    bb_size = zeros(size(inds,2),2);
    
    % for each positive window index...
    for i=1:size(inds,2)
        
        % linear index of the window
        ind = inds(i);
        
        % find the positive window original level 
        level = 0;

        while ind > sum(wxl(1:level))
        	level = level + 1;
        end

%         fprintf('Match found at level %d\n', level);
        
        % compute original coordinates in Level0 image 
        factor = (scale^(level-1));
        new_cords(i,1) = floor(coordinates(i,1) * factor);
        new_cords(i,2) = floor(coordinates(i,2) * factor);
        
        % Bounding Box resizing?
        bb_size(i,1) = ceil(bb_height*factor);
        bb_size(i,2) = ceil(bb_width*factor);
    end
end