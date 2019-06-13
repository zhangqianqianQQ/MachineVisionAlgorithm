%% Define Parameters

%%%%%%%%%%% IMAGES PARAMETERS
classes = [0, 1]; % [No Object, Object]

% path_objects = '/Volumes/SHARED HD/Video Summarization Objects/Features';
path_objects = '/media/lifelogging/HDD_2TB/Video Summarization Objects/Features';
objects_folders = {...
    {'Data MSRC Ferrari', 'Data MSRC BING', 'Data MSRC MCG', 'Data MSRC SelectiveSearch'}, ...
    {'Data PASCAL_12 Ferrari', 'Data PASCAL_12 BING', 'Data PASCAL_12 MCG', 'Data PASCAL_12 SelectiveSearch'}};%, ...
    % {'Data Narrative_Dataset BING', 'Data Narrative_Dataset Ferrari', 'Data Narrative_Dataset MCG', 'Data Narrative_Dataset SelectiveSearch'}};
nObjectDetectors = 4;
    
% path_images = '/Volumes/SHARED HD/Video Summarization Project Data Sets';
path_images = '/media/lifelogging/Shared SSD/Object Discovery Data/Video Summarization Project Data Sets';
images_folders = {'MSRC', 'PASCAL_12/VOCdevkit/VOC2012'};
%%% IMPORTANT!
% proportion resolution for each dataset
% MSRC 1.25, PASCAL 1
prop_res = {1.25, 1};

formats = {'.JPG', '.jpg'};

%%%%%%%%%%% RESULTING CROPS
path_to_store = '/media/lifelogging/HDD_2TB/Object-Detection-CNN_Data/';
% path_to_store = '/Volumes/SHARED HD/ODCNN_Data';
path_crop_images = {'objDetectionCNN_train', 'objDetectionCNN_val'}; % resulting images train/test
images_crop_lists_results = {'train_crop_list.txt', 'val_crop_list.txt'}; % croped images list train/test file names

CNN_input_img = 256;


%% Loop for train and test data
for i_set = 1:2
    disp(['Start extracting crops from ' images_crop_lists_results{i_set}]);
    path_crop = path_crop_images{i_set};
    
    % Create crops folder
    path_store = [path_to_store '/' path_crop];
    mkdir(path_store);
    
    % Read list of images
    f = fopen([path_to_store '/' images_crop_lists_results{i_set}], 'r');
    
    %% Get each line in the file
    line = fgetl(f);
    prev_file_name = '';
    prev_dataset_name = '';
    count_lines = 1;
    while(ischar(line))
        % name name_crop dataset_id label ULx_coord ULy_coord BRx_coord BRy_coord
        line = regexp(line, ' ', 'split');
        
        dataset_name = images_folders{str2num(line{3})};
        % Force to reload image if dataset is different from the previous one
        % and reload objects data
        if(~strcmp(prev_dataset_name, dataset_name))
            prev_file_name = '';
            load([path_objects '/' objects_folders{str2num(line{3})}{1} '/objects.mat']);
        end
        
        % Get image ID in the current objects structure
        img_id = regexp(line{2}, '_', 'split');
        img_id = str2num(img_id{2});
        
        % Reload image if it is different from the previous one
        file_name = line{1};
        if(~strcmp(prev_file_name, file_name))
            this_img = imread([path_images '/' dataset_name '/' objects(img_id).folder '/' file_name]);
            this_img = imresize(this_img, round([size(this_img,1) size(this_img,2)]/prop_res{str2num(line{3})}));
        end

        % Calculate crop upper-left position
        ULx = str2num(line{5});
        ULy = str2num(line{6});
        BRx = str2num(line{7});
        BRy = str2num(line{8});

        % Crop image and resize w.r.t. CNN input image
        crop_image = this_img(ULy:BRy, ULx:BRx, :);
        crop_image = imresize(crop_image, [CNN_input_img CNN_input_img]);

        % Save cropped image
        crop_name = line{2};
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         crop_name = [line{4} '__' crop_name];
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        imwrite(crop_image, [path_store '/' crop_name]);

        % Show progress
        if(mod(count_lines,2000) == 0)
            disp(['Cropped ' num2str(count_lines) ' samples']);
        end
            
        % Get next line
        prev_file_name = file_name;
        prev_dataset_name = dataset_name;
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for out = 1:100
        line = fgetl(f);
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        count_lines = count_lines+1;
    end
    
    fclose(f);
end

% exit;
