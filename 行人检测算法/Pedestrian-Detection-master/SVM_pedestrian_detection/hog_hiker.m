function feature = hog_hiker(filename, VISUAL_FLAG)
%% set VISUAL_FLAG to false to disable visualize
%% set filename to the image you want to extract HoG feature
%% Sample call:
%% feature = hog_hiker('soccor-crop.jpg', true);
addpath('testimgs');
img_ori = imread(filename);
if length(size(img_ori))==3
    img = im2double(rgb2gray(img_ori));
else
    img = im2double(img_ori);
end

NUM_OF_BINNING = 9;
cell_size = [6, 6];
block_size = [3, 3];
block_overlap = ceil(block_size/2);

block_step = block_size - block_overlap;
dx = conv2(img, [-1, 0, 1], 'same');
dy = conv2(img, [-1; 0; 1], 'same');
[h_img, w_img] = size(img);
% calculate radians matrix for each pixel
% plus pi/2 to change to vertical of gradient
radians = atan(dy./dx) + pi/2;
% magnitude matrix
mag = sqrt(dx.^2 + dy.^2);
bin_slot = pi/NUM_OF_BINNING;
orientation = ceil(radians ./ bin_slot);
% range orientation from 1 to NUM_OF_BINNING
orientation(orientation == 0) = NUM_OF_BINNING;
cell_matrix_size = floor(size(img)./cell_size);
% construct cell matrix
% vector cell(h, w) contains entry cell_matrix(:, h, w)
cell_matrix = zeros(NUM_OF_BINNING, cell_matrix_size(1), cell_matrix_size(2));
for w = 1:cell_matrix_size(2)
    for h = 1:cell_matrix_size(1)
        orientation_cell = orientation(((h-1)*cell_size(1)+1):(h*cell_size(1)), ...
            ((w-1)*cell_size(2)+1):(w*cell_size(2)));
        mag_cell = mag(((h-1)*cell_size(1)+1):(h*cell_size(1)), ...
            ((w-1)*cell_size(2)+1):(w*cell_size(2)));
        for bin = 1:NUM_OF_BINNING
            cell_matrix(bin, h, w) = sum(mag_cell(orientation_cell == bin));
        end
    end
end

% block normalization
block_matrix_size = floor((cell_matrix_size - block_size) ./ block_step) + 1;
block_len = NUM_OF_BINNING*prod(block_size);
block_matrix = zeros(block_len, block_matrix_size(1), block_matrix_size(2));
norm_cell_matrix = zeros(NUM_OF_BINNING, cell_matrix_size(1), cell_matrix_size(2));
for w = 1:block_matrix_size(2)
    for h = 1:block_matrix_size(1)
        block_vec = cell_matrix(:, ...
            ((h-1)*block_step(1)+1):((h-1)*block_step(1)+block_size(1)), ...
            ((w-1)*block_step(2)+1):((w-1)*block_step(2)+block_size(2)));
        block_matrix(:, h, w) = block_vec(:) / norm(block_vec(:));
        norm_cell_matrix(:, ...
            ((h-1)*block_step(1)+1):((h-1)*block_step(1)+block_size(1)), ...
            ((w-1)*block_step(2)+1):((w-1)*block_step(2)+block_size(2))) = ...
            block_vec / norm(block_vec(:));
    end
end
feature = block_matrix(:);
if VISUAL_FLAG
    visualize(norm_cell_matrix, img_ori);
end