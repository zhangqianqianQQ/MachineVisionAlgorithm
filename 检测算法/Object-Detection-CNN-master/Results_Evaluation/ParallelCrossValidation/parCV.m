function parCV( init_val_split, end_val_split, id_partition )

    %% Specific Cross-Validation parameters
    mergeType_values = {'IoU', 'NMS', 'MS'};
    minObjVal_values = {0.75, 0.85, 0.95};
    mergeScales_values = {true};
    % Thresholds used for each of the methods (in the same order as
    % mergeType_values)
    mergeThreshold_values = {{0.8, 0.65, 0.5}, ...
                            {0.8, 0.65, 0.5}, ...
                            {0.2, 0.3, 0.4}};

    %% Load general Parameters
    cd ..
    cd ..
    loadParameters;

    disp(['Starting CV execution on partition ' num2str(id_partition)]);
    
    %% Load validation data split
    load(train_val_split); % images_list
    val_split = images_list{2};
    val_split = val_split(init_val_split:end_val_split,:);
    nImages = size(val_split,1);


    %% For each image
    count_imgs = 1;
    prev_folder = '';
    objectsCV = struct('imgName', [], 'folder', []);
    for img_ind = val_split'

        disp(' ');
        disp(['## Processing image ' num2str(count_imgs) '/' num2str(nImages)]);
        disp(' ');

        % Reload objects structure if we have changed the current folder
        if(~strcmp(prev_folder, list_paths_images{img_ind(1)}))
            prev_folder = list_paths_images{img_ind(1)};
            load([path_objects '/' objects_folders{img_ind(1)} '/objects.mat']);
        end
        tic

        % Store ground truth information
        objectsCV(count_imgs).ground_truth = objects(img_ind(2)).ground_truth;
        objectsCV(count_imgs).imgName = objects(img_ind(2)).imgName;
        objectsCV(count_imgs).folder = objects(img_ind(2)).folder;

        % Prepare tests parameters and resulting object candidates
        objectsCV(count_imgs).test = struct('mergeType', [], 'minObjVal', [], 'mergeScales', [], 'mergeThreshold', [], 'objects', []);

        % Load maps results
        load([path_maps '/' num2str(img_ind(1)) '_' objects(img_ind(2)).imgName '_maps.mat']); % maps

        objectsCV(count_imgs).resizeMaps = maps.resizeMaps;
        maps = maps.maps;

        %% For each mergeType
        count_type = 1;
        count_tests = 1;
        for mergeType = mergeType_values
            ODCNN_params.mergeType = mergeType{1};
            %% For each minObjVal
            for minObjVal = minObjVal_values
                ODCNN_params.minObjVal = minObjVal{1};
                %% Whether we merge all scales or not
                for mergeScales = mergeScales_values
                    ODCNN_params.mergeScales = mergeScales{1};

                    %% Apply tests for all the chosen thresholds
                    [objects_list, conf_windows, scales] = mergeWindowsCV(maps, ODCNN_params, mergeThreshold_values{count_type});
                    this_all_objects.list = objects_list;
                    this_objects.scales = scales;

                    % Get max scale
                    maxScale = -1;
                    maxScale_val = [-Inf -Inf];
                    countScales = 1;
                    for s = scales
                        s = regexp(s{1}, '_', 'split');
                        s = [str2num(s{1}) str2num(s{2})];
                        if(s(1) > maxScale_val(1))
                            maxScale_val = s;
                            maxScale = countScales;
                        end
                        countScales = countScales+1;
                    end

                    count_threshold = 1;
                    for mergeThreshold = mergeThreshold_values{count_type}
                        ODCNN_params.mergeThreshold = mergeThreshold{1};

                        % Store information for this parameter combination
                        objectsCV(count_imgs).test(count_tests).mergeType = ODCNN_params.mergeType;
                        objectsCV(count_imgs).test(count_tests).minObjVal = ODCNN_params.minObjVal;
                        objectsCV(count_imgs).test(count_tests).mergeScales = ODCNN_params.mergeScales;
                        objectsCV(count_imgs).test(count_tests).mergeThreshold = ODCNN_params.mergeThreshold;

                        % Apply parameters and extract objects
                        this_objects.list = this_all_objects.list{count_threshold};

                        % Store resulting objects
                        count_objects = 1;
                        nScales = length(this_objects.list);
                        for i = 1:nScales
                            s = regexp(this_objects.scales{i}, '_', 'split');
                            s = [str2num(s{1}) str2num(s{2})];
                            objs = this_objects.list{i};
                            confs = conf_windows{i}{1};

                            ratio = maxScale_val(2)/s(2);
                            count_o = 1;
                            for o = objs'
                                o = o*ratio;
                                objectsCV(count_imgs).test(count_tests).objects(count_objects).ULx = o(1);
                                objectsCV(count_imgs).test(count_tests).objects(count_objects).ULy = o(2);
                                objectsCV(count_imgs).test(count_tests).objects(count_objects).BRx = o(3);
                                objectsCV(count_imgs).test(count_tests).objects(count_objects).BRy = o(4);
                                objectsCV(count_imgs).test(count_tests).objects(count_objects).confidence = confs(count_o);
                                count_objects = count_objects+1;
                                count_o = count_o + 1;
                            end
                        end

                        count_tests = count_tests+1;
                        count_threshold = count_threshold+1;
                    end

                end
            end
            count_type = count_type+1;
        end

        time = toc;
        disp(['Elapsed time: ' num2str(time)]);

%         % Save temporal results
%         if(mod(count_imgs, 100) == 0)
%             save(['tmp_cv_results/tmp_state_' num2str(count_imgs) '.mat']);
%         end

        count_imgs = count_imgs+1;
    end

    %% Save Results
    save(sprintf('tmp_cv_results/CrossValidation_validation_test_part_%0.3d.mat', id_partition), 'objectsCV');

    disp('Done');
    
end

