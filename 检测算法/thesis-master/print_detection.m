% Print detection to file
init;

% Get test image path
testing_data = exp_params.test_dataset;
im_dir = [VOC07PATH 'JPEGImages/'];
fid = fopen([VOC07PATH 'ImageSets/Main/' testing_data '.txt']);
imgs = textscan(fid, '%s');
imgs = imgs{1};

% Load trained SVM models
net_model = exp_params.net_model;
training_data = exp_params.dataset;
load(['svm_models/' net_model '/' training_data '.mat']);

% Open stream to file
fids = cell(20,1);
for cls=1:20
    fid = fopen(['results/' net_model '_' training_data '_' testing_data '_' VOCCLASS{cls} '.txt'], 'w');
    fids{cls} = fid;
end

num_imgs = size(imgs, 1);
for ii=1:num_imgs
    tic
    disp(['Detecting image: ' imgs{ii} ' ' num2str(ii) '/' num2str(num_imgs)]);
    filename = ['data/' net_model '/' testing_data '/' imgs{ii} '.mat'];
    load(filename);
    
    num_regions = size(regions, 2);
    test_features = zeros(num_regions, 4096);
    boxes = zeros(num_regions, 4);
    for bb=1:num_regions
        test_features(bb, :) = features{bb}';
        boxes(bb, :) = regions{bb};
    end
    test_features = test_features .* range;
    
    for cls=1:1
        model = models{cls};

        prediction = model.w * test_features';
        prediction = [-prediction; 1:num_regions]';
        prediction = sortrows(prediction, 1);

        if -prediction(1, 1) > 0
            scores = -prediction(:, 1);
            index = scores > 0;
            scores = scores(index);
            dets = boxes(prediction(index, 2), :);

            [pruned_boxes, pruned_scores] = prune_detection(dets, scores);
            for bb=1:size(pruned_boxes, 1)
                id = imgs{ii};
                box = pruned_boxes(bb, :);
                line = [id ' ' num2str(pruned_scores(bb), 6) ' ' num2str(box(2)) ' ' num2str(box(1)) ' ' num2str(box(4)) ' ' num2str(box(3)) '\n'];
                disp(line);
                fprintf(fids{cls}, line);
            end
        end
    end
    toc
end

for cls=1:20
    fclose(fids{cls});
end
