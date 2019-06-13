function H = compute_HOG(I, cell_size, block_size,n_bins)
% COMPUTE_HOG Computes the HOG descriptor of the given image computed
%             with the specified paramters.
%
% INPUT:
%       I: image to extract HOGs
%       cell_size: size of the cells in pixels
%       block_size: size of the blocks in cells
%       n_bins: number of bins of the histograms
%
% OUTPUT: 
%       H: HoG descriptor in a column vector form.
%
%
%$ Author Jose Marcos Rodriguez $    
%$ Date: 2013/20/08 22:00:00 $    
%$ Revision: 1.1 $

%% Setting gradient configuration
% gradient angle range control 
epsilon = 0.0001;
L_norm = 2;
desp = 1;
total_angles = 180.0;
bin_width = total_angles/n_bins;

%% column matrix for mapping indices to bin center values
bin_centers_map = (bin_width/2:bin_width:total_angles)';

%% Compute the gradient in polar coordinates
[angles, magnitudes] = compute_gradient(I);

%% Split the gradient in cells
cell_coords = compute_cell_coordinates(angles,cell_size,cell_size,false);

%% initialize 3 dimensional matrix to hold all the histograms
% number of vertical and horizontal cells
[height,width] = size(I(:,:,1));
n_v_cells = floor(height/cell_size);
n_h_cells = floor(width/cell_size);

% init the histograms 3D matrix (7x14x9)
histograms = zeros(n_v_cells,n_h_cells,n_bins);



% ================================================
%% Computing histograms for all image cells
% ================================================
for index=1:size(cell_coords,2)
    
    % current cell histogram initialization
    h = zeros(1,n_bins);
    
    % cell coords
    x_min = cell_coords(1,index);
    x_max = cell_coords(2,index);
    y_min = cell_coords(3,index);
    y_max = cell_coords(4,index);

    % retrieve angles and magnitudes for all the pixels in the 
    % cell and conversion to degrees.
    angs = angles(y_min:y_max,x_min:x_max);
    angs = angs.*180/pi;
    mags = magnitudes(y_min:y_max,x_min:x_max);

    % indices for the left and right histogram bins that bound
    % the current angle value for all the pixels in the cell
    left_indices = round(angs/bin_width);
    right_indices = left_indices+1;

    % wraping contributions over the histogram boundaries.
    left_indices(left_indices==0) = 9;
    right_indices(right_indices==10) = 1;
    
    % retrieving the left bin center value.
    left_bin_centers = bin_centers_map(left_indices);
    angs(angs < left_bin_centers) = ...
        total_angles + angs(angs < left_bin_centers);
    
    
    % calculating the contribution to both bins sides (vote weight)
    % (matrices with same size as the cell)
    right_contributions = (angs-left_bin_centers)/bin_width;
    left_contributions = 1 - right_contributions;
    left_contributions = mags.*left_contributions;
    right_contributions = mags.*right_contributions;
    

    % computing contributions for the current histogram bin by bin.
    for bin=1:n_bins
        % pixels that contribute to the bin with its left portion
        pixels_to_left = (left_indices == bin);
        h(bin) = h(bin) + sum(left_contributions(pixels_to_left));
        
        % pixels that contribute to the bin with its right portion
        pixels_to_right = (right_indices == bin);
        h(bin) = h(bin) + sum(right_contributions(pixels_to_right));
    end

    % appending current hist. to the histograms matrix
    row_offset = floor(index/n_h_cells + 1);
    column_offset = mod(index-1,n_h_cells)+1;
    histograms(row_offset,column_offset,:) = h(1,:);

end

% ================================================
%%          block normalization (L2 norm)
% ================================================
hist_size = block_size*block_size*n_bins;
descriptor_size = hist_size*(n_v_cells-block_size+desp)*(n_h_cells-block_size+desp);
H = zeros(descriptor_size, 1);
col = 1;
row = 1;
% H = [];

%% Split the histogram matrix in blocks (this code assumes an 50% of overlap as desp is hard coded as 1)
while row <= n_v_cells-block_size+1
    while col <= n_h_cells-block_size+1
        
        % Getting all the histograms for a block
        blockHists = ...
            histograms(row:row+block_size-1, col:col+block_size-1, :);
        
        % Getting the magnitude of the histograms of the block
        magnitude = norm(blockHists(:),L_norm);
    
        % Divide all of the histogram values by the magnitude to normalize 
        % them.
        normalized = blockHists / (magnitude + epsilon);

        % H = [H; normalized(:)];
        offset = (row-1)*(n_h_cells-block_size+1)+col;
        ini = (offset-1)*hist_size+1;
        fin = offset*hist_size;

        H(ini:fin,1) = normalized(:);

        col = col+desp;
    end
    row = row+desp;
    col = 1;
end






