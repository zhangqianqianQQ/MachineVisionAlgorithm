
%% Define Parameters

rebuild_train_val_split = true;
min_object_OS = 0.7; % minimum overlapping score for considering an object sample
max_noobject_OS = 0.2; % maximum overlapping score for considering a no object sample

%%%%%%%%%%% IMAGES PARAMETERS
classes = [0, 1]; % [No Object, Object]

path_objects = '/Volumes/SHARED HD/Video Summarization Objects/Features';
objects_folders = {...
    {'Data MSRC BING', 'Data MSRC Ferrari', 'Data MSRC MCG', 'Data MSRC SelectiveSearch'}, ...
    {'Data PASCAL_12 BING', 'Data PASCAL_12 Ferrari', 'Data PASCAL_12 MCG', 'Data PASCAL_12 SelectiveSearch'}};%, ...
    %{'Data Narrative_Dataset BING', 'Data Narrative_Dataset Ferrari', 'Data Narrative_Dataset MCG', 'Data Narrative_Dataset SelectiveSearch'}};
nObjectDetectors = 4;

%%%%%%%%%%% RESULTING CROPS
path_to_store = '/Volumes/SHARED HD/ODCNN_Data';
images_lists_results = {'train.txt', 'val.txt'}; % croped images list train/test file names
images_crop_lists_results = {'train_crop_list.txt', 'val_crop_list.txt'}; % croped images list train/test file names
train_val_prop = 3/4; % proportion of training images w.r.t validation


%% Training/Validation split
if(rebuild_train_val_split)
    disp('Generating random training/validation split...');
    images_list = [];
    for i = 1:length(objects_folders)
        load([path_objects '/' objects_folders{i}{1} '/objects.mat']); % objects
        images_list_aux = [ones(length(objects),1)*i [1:length(objects)]'];
        images_list = [images_list; images_list_aux];
    end
    train_samples = sort(randsample(size(images_list,1), size(images_list,1)*train_val_prop));
    val_samples = setdiff(1:size(images_list,1), train_samples);
    train_samples = images_list(train_samples, :);
    val_samples = images_list(val_samples, :);
    images_list = {train_samples, val_samples};
    save('train_val_split.mat', 'images_list');
else
    load('train_val_split.mat');
end


%% Analyze each data split separately
for i_set = 1:2
    images_split = images_list{i_set};
    
    % Read list of images
    f_crop_train = fopen([path_to_store '/' images_lists_results{i_set}], 'w');
    f_crop_images = fopen([path_to_store '/' images_crop_lists_results{i_set}], 'w');
    
    disp(['Starting object labels retrieval ' images_lists_results{i_set} '...']);
    all_objects = struct('name', [], 'index', [], 'labels_list', [], 'crops_list', [], 'counts', []);
    nObject_Candidates = 0; % total number of objects found
    nImages = size(images_split,1);
    %% For each object detector information (Objectness, MCG, Sel.Search, BING)
    for i_object_detector = 1:nObjectDetectors
        
        %% Loop for every object_candidate (for counting how many samples we have for each class)
        prev_dataset = 0;
        for i_img = 1:nImages
            ind = images_split(i_img,:);
            % Reload objects file if we have changed the dataset
            if(ind(1) ~= prev_dataset)
                load([path_objects '/' objects_folders{ind(1)}{i_object_detector} '/objects.mat']); % objects
                prev_dataset = ind(1);
            end
    
            objects_struct = objects(ind(2));
            if(i_object_detector == 1)
                all_objects(i_img).name = objects_struct.imgName;
                all_objects(i_img).index = ind;
                all_objects(i_img).counts = [0 0];
            end
            
            % Insert object candidates list
            objs_OS = [objects_struct.objects(:).OS];
            objs_ULx = [objects_struct.objects(:).ULx];
            objs_ULy = [objects_struct.objects(:).ULy];
            objs_BRx = [objects_struct.objects(:).BRx];
            objs_BRy = [objects_struct.objects(:).BRy];
            objs_OS = max(reshape(objs_OS, [length(objs_OS)/length(objs_ULx) length(objs_ULx) ]));
            if(isempty(objs_OS))
                objs_OS = zeros(length(objs_ULx),1);
            end
            % Insert ground_truth list
            objs_OS = [objs_OS ones(1, length([objects_struct.ground_truth(:).ULx]))];
            objs_ULx = [objs_ULx objects_struct.ground_truth(:).ULx];
            objs_ULy = [objs_ULy objects_struct.ground_truth(:).ULy];
            objs_BRx = [objs_BRx objects_struct.ground_truth(:).BRx];
            objs_BRy = [objs_BRy objects_struct.ground_truth(:).BRy];
            
            % Check which ones are objects and which ones are no objects
            are_objects = objs_OS >= min_object_OS;
            are_noobjects = objs_OS < max_noobject_OS;
            
            % Filter them
            objs_ULx = [objs_ULx(are_objects) objs_ULx(are_noobjects)];
            objs_ULy = [objs_ULy(are_objects) objs_ULy(are_noobjects)];
            objs_BRx = [objs_BRx(are_objects) objs_BRx(are_noobjects)];
            objs_BRy = [objs_BRy(are_objects) objs_BRy(are_noobjects)];
            
            all_objects(i_img).labels_list = [all_objects(i_img).labels_list; ones(sum(are_objects),1); zeros(sum(are_noobjects),1) ];
            % Count labels
            all_objects(i_img).counts(1) = all_objects(i_img).counts(1) + sum(are_noobjects);
            all_objects(i_img).counts(2) = all_objects(i_img).counts(2) + sum(are_objects);
            % Store window positions
            all_objects(i_img).crops_list = [all_objects(i_img).crops_list; [objs_ULx' objs_ULy' objs_BRx' objs_BRy']];
            
            nObject_Candidates = nObject_Candidates+length(objs_ULx);
        end
        
        disp(['    Finished folder detector ' num2str(i_object_detector) '/' num2str(nObjectDetectors)]);
    end
    
    
    %% Balance classes
    disp(['Balancing classes ' images_lists_results{i_set} '...']);
    % Create list of pixels (index_dataset, index_img, ULx, ULy, BRx, BRy, label)
    list_objects = zeros(nObject_Candidates, 8);
    nClasses = length(classes);
    % Count classes
    countClasses = zeros(1,nClasses);
    last = 0;
    for i = 1:nImages
        
        nThis = size(all_objects(i).labels_list,1);
        list_objects(last+1:last+nThis,1) = all_objects(i).index(1);
        list_objects(last+1:last+nThis,2) = all_objects(i).index(2);
        list_objects(last+1:last+nThis,3) = all_objects(i).crops_list(:,1);
        list_objects(last+1:last+nThis,4) = all_objects(i).crops_list(:,2);
        list_objects(last+1:last+nThis,5) = all_objects(i).crops_list(:,3);
        list_objects(last+1:last+nThis,6) = all_objects(i).crops_list(:,4);
        list_objects(last+1:last+nThis,7) = all_objects(i).labels_list;
        list_objects(last+1:last+nThis,8) = i;
        last = last+nThis;
        
        countClasses(1) = countClasses(1) + all_objects(i).counts(1);
        countClasses(2) = countClasses(2) + all_objects(i).counts(2);
    end
    balancedNum = min(countClasses);
    
    % Select crops randomly
    disp(['Random selection of crops ' images_lists_results{i_set} '...']);
    list_crops = zeros(nClasses, balancedNum, 8);
    for i = 1:nClasses
         elems = list_objects(randsample(find(list_objects(:,7)==classes(i)), balancedNum), :);
         [~, pos] = sortrows(elems);
         list_crops(i,:,:) = elems(pos,:);
    end

    %% Store final selected crops info
    disp(['Storing selected crops ' images_lists_results{i_set} '...']);
    nCropsPerImage = zeros(1, nImages);
    for i = 1:nClasses
        for j = 1:balancedNum
            this_crop = reshape(list_crops(i,j,:), [1,8]);
            
            % Get top X-Y and bottom X-Y crop coordinates, dataset, name and label
            ULx = this_crop(3);
            ULy = this_crop(4);
            BRx = this_crop(5);
            BRy = this_crop(6);
            img_id = this_crop(2);
            dataset = this_crop(1);
            name = all_objects(this_crop(8)).name;
            label = this_crop(7);
            
            % Count crops extracted from each image
            nCropsPerImage(this_crop(8)) = nCropsPerImage(this_crop(8))+1;
            
            % Save crop info in .txt file: 
            %       name name_crop dataset_id label ULx_coord ULy_coord BRx_coord BRy_coord
            name_no_format = regexp(name, '\.', 'split');
            crop_name = sprintf([num2str(dataset) '_' num2str(img_id) '_' name_no_format{1} '_%0.5d.jpg'], nCropsPerImage(this_crop(8)));
            fprintf(f_crop_images, [name ' ' crop_name ' ' num2str(dataset) ' ' num2str(label) ' ' num2str(ULx) ' ' num2str(ULy) ' ' num2str(BRx) ' ' num2str(BRy) '\n']);
            fprintf(f_crop_train, [crop_name ' ' num2str(label) '\n']);
            
            % Show progress
            if(mod(j, 5000) == 0 || j == balancedNum)
                disp(['Stored ' num2str(j) '/' num2str(balancedNum) ' class ' num2str(i-1)]);
            end
        end
    end
    
    fclose(f_crop_train);
    fclose(f_crop_images);
    
end

% exit;
