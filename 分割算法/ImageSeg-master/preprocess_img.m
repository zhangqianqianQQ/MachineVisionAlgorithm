function preprocessed = preprocess_img(img)

    s = size(img);
    img = single(img);
    %img = gpuArray(img);

    % scaling up to 600 if necessary
    minside = min([s(1), s(2)]);
    if minside < 600
        scale = 600/minside;
        numrow = floor(size(img, 1) * scale);
        numcol = floor(size(img, 2) * scale);
        img = imresize(img, [numrow, numcol]);
    end
    % scaling down to 1000 if necessary
    maxside = max([s(1), s(2)]);
    if maxside > 1000
        scale = 1000/maxside;
        numrow = floor(size(img, 1) * scale);
        numcol = floor(size(img, 2) * scale);
        img = imresize(img, [numrow, numcol]);
    end

    % rgb to bgr
    rgb_img = img;
    img(:,:,1) = rgb_img(:,:,3);
    img(:,:,3) = rgb_img(:,:,1);

    % subtract mean 102.9801, 115.9465, 122.7717 (in BGR order as used in faster-rcnn)
    img(:,:,1) = img(:,:,1) - 102.9801;
    img(:,:,2) = img(:,:,2) - 115.9465;
    img(:,:,3) = img(:,:,3) - 122.7717;

    preprocessed = img;
end