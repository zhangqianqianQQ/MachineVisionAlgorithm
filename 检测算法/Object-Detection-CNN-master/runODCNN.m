%% Runs the Object Discovery CNN on a set of test images
loadParameters;

%% Load validation data split
load(train_val_split); % images_list
val_split = images_list{2};

%% For each image
nImages = size(val_split,1);
times = zeros(nImages, 1);
count_imgs = 1;
prev_folder = '';
for img_ind = val_split'
    disp(' ');
    disp(['## Processing image ' num2str(count_imgs) '/' num2str(nImages)]);
    disp(' ');
    
    % Reload objects structure if we have changed the current folder
    if(~strcmp(prev_folder, list_paths_images{img_ind(1)}))
        prev_folder = list_paths_images{img_ind(1)};
        load([path_objects '/' objects_folders{img_ind(1)} '/objects.mat']);
    end
    
    % Load current image
    img = imread([list_paths_images{img_ind(1)} '/' objects(img_ind(2)).imgName]);
    img = imresize(img, [size(img,1)/prop_res{img_ind(1)} size(img,2)/prop_res{img_ind(1)}]);
    
    tic
%     [ maps, objects ] = applyODCNN(img, ODCNN_params);
    [ maps_tests ] = applyODCNN(img, ODCNN_params, false);
    time = toc;

    disp(['Elapsed time: ' num2str(time)]);
    times(count_imgs) = time;

    % Store resize applied on the image
    maps.maps = maps_tests;
    maps.resizeMaps = prop_res{img_ind(1)};
    
    % Save results
    save([path_maps '/' num2str(img_ind(1)) '_' objects(img_ind(2)).imgName '_maps.mat'], 'maps');
%     save([path_maps '/' num2str(count_paths) '_' im_name{1} '_objects.mat'], 'objects');

    count_imgs = count_imgs+1;
end

save([path_maps '/times.mat'], 'times');
disp('Done');
exit;
