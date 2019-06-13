% ------------------------------------------------------------------------
function images = prepare_batch2(image_files,imgs_loaded, parallel,IMAGE_MEAN,batch_size)
% ------------------------------------------------------------------------

if nargin < 2
    imgs_loaded = false;
end
if nargin < 3
    parallel = true;
end
if nargin < 4
    d = load('ilsvrc_2012_mean');
    IMAGE_MEAN = d.image_mean; 
end
num_images = length(image_files);
if nargin < 5
    batch_size = num_images;
end

IMAGE_DIM = 256;
CROPPED_DIM = 227;
indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
center = floor(indices(2) / 2)+1;

num_images = length(image_files);
images = zeros(CROPPED_DIM,CROPPED_DIM,3,batch_size,'single');

% Parallel computation
if(parallel)
    parfor i=1:num_images
        % read file
    %     fprintf('%c Preparing %s\n',13,image_files{i});
        try
            if(~imgs_loaded)
                im = imread(image_files{i});
            else
                im = image_files{i};
            end
            % resize to fixed input size
            im = single(im);
            im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
            % Transform GRAY to RGB
            if size(im,3) == 1
                im = cat(3,im,im,im);
            end
            % permute from RGB to BGR (IMAGE_MEAN is already BGR)
            im = im(:,:,[3 2 1]) - IMAGE_MEAN;
            % Crop the center of the image
            images(:,:,:,i) = permute(im(center:center+CROPPED_DIM-1,...
                center:center+CROPPED_DIM-1,:),[2 1 3]);
        catch
            if(image_files{i} ~= 0)
                warning('Problems with file',image_files{i});
            end
        end
    end
% Non-parallel computation
else
    for i=1:num_images
        % read file
    %     fprintf('%c Preparing %s\n',13,image_files{i});
        try
            if(~imgs_loaded)
                im = imread(image_files{i});
            else
                im = image_files{i};
            end
            % resize to fixed input size
            im = single(im);
            im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
            % Transform GRAY to RGB
            if size(im,3) == 1
                im = cat(3,im,im,im);
            end
            % permute from RGB to BGR (IMAGE_MEAN is already BGR)
            im = im(:,:,[3 2 1]) - IMAGE_MEAN;
            % Crop the center of the image
            images(:,:,:,i) = permute(im(center:center+CROPPED_DIM-1,...
                center:center+CROPPED_DIM-1,:),[2 1 3]);
        catch
            if(image_files{i} ~= 0)
                warning('Problems with file',image_files{i});
            end
        end
    end
end