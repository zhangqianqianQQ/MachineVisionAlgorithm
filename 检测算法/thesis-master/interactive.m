% interactive mode
init;

dataset = 'trainval';
object_class = 'aeroplane';
object_id = 1;

% Get test image path
im_dir = [VOC07PATH 'JPEGImages/'];
fid = fopen([VOC07PATH 'ImageSets/Main/' object_class '_' dataset '.txt']);
anno_dir = [VOC07PATH 'Annotations/'];
contents = textscan(fid, '%s %d');
ids = contents{1};
has_object = contents{2};
num_test = sum(find(has_object == 1));

% Load trained SVM models
load(['svm_models/caffenet/trainval.mat']);

% Network parameter
caffe_params.model = 'caffenet';
caffe_params.model_file = 'bvlc_reference_caffenet.caffemodel';
caffe_params.def_file = 'deploy_fc7.prototxt';
caffe_params.device = 0;

for ii=1:size(has_object)
    if has_object(ii) == -1
        continue;
    end
    disp(['Image: ' num2str(ii) ' id: ' ids{ii}]);
    im = imread([im_dir ids{ii} '.jpg']);
    
    while 1
        imshow(im);
        rect = getrect;
        region = im(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :);
        
        rep = extract_caffe_feature(region, caffe_params);
        rep = mean(rep, 2);
        rep = rep .* range;
        
        prediction = models{object_id}.w * rep;
        fprintf('score %f', prediction);
        
        x = input('Next image?', 's');
        if isempty(x)
            break; 
        end
    end
        
    
    
end