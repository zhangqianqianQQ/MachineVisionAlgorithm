function images = prepare_image(im, oversample)
% Function prepare_image prepare images to be inputted into a caffe
% network as shown on matcaffe_demo of caffe distribution

    d = load('ilsvrc_2012_mean');
    IMAGE_MEAN = d.image_mean;
    IMAGE_DIM = 256;
    CROPPED_DIM = 227;
    
    % resize to fixed input size
    im = single(im);
    im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
    % permute from RGB to BGR and subtract the image mean out of it
    im = im(:, :, [3 2 1]) - IMAGE_MEAN;
    
    images = imresize(im, [CROPPED_DIM CROPPED_DIM], 'bilinear');
    
    if oversample
        % oversample (4 corners, center, and their x-axis flips)
        images = zeros(CROPPED_DIM, CROPPED_DIM, 3, 10, 'single');
        indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
        curr = 1;
        for ii = indices
            for jj = indices
                images(:, :, :, curr) = permute(im(ii:ii+CROPPED_DIM-1, jj:jj+CROPPED_DIM-1, :), [2 1 3]);
                images(:, :, :, curr+5) = images(end:-1:1, :, :, curr); % flipped the image
                curr = curr + 1;
            end
        end
        center = floor(indices(2) / 2) + 1;
        images(:, :, :, 5) = permute(im(center:center+CROPPED_DIM-1, center:center+CROPPED_DIM-1, :), [2 1 3]);
        images(:, :, :, 10) = images(end:-1:1, :, :, 5);
    end
end