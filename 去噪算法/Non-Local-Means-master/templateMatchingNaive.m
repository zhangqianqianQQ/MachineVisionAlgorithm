function [offsetsRows, offsetsCols, distances] = templateMatchingNaive(row, col,...
    patchSize, searchWindowSize, image)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsRows(1) = -1;
% offsetsCols(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

% NOTE : row and col are the coordinates of the pixel we want our pach to be centered.
% We need the delta to see when we're sliding the patch if we're still inside the image
% or not
delta = floor(patchSize/2);

[rows columns dimensions] = size(image);

% Let's grab the reference patch centered at (row, col)
reference_patch = double(image(row-delta:row+delta, col-delta:col+delta)); 

% We'll have as many patches as the window Area which is
% (searchWindowSize*searchWindowSize) 
% Therefore we'll have the same number for the distances and for the offsets 
% in the X and Y direction 
distances = zeros(1,searchWindowSize*searchWindowSize); 
offsetsRows = zeros(1,searchWindowSize*searchWindowSize); 
offsetsCols = zeros(1,searchWindowSize*searchWindowSize);

distances_index = 1;

% We use the delta window to center the window to the pixel we want to
% denoise.
delta_window = floor(searchWindowSize/2);

% CLIP the search window agains the image
% Suppose we want to denoise the pixel x and center the 
%
% |------------|  
% |     #######|####################
% |     #x     |                   #
% |-----#------|                   #
%       #                          #
%       #                          #
%       #                          #
%       ############################
%
%

start_rows = max(row-delta_window, 1+delta);
start_columns = max(col-delta_window, 1+delta);

end_rows = min(row+delta_window, rows-delta);
end_columns = min(col+delta_window, columns-delta);


% Loop through the clipped window
for row_searchWindow = start_rows:end_rows
    for column_searchWindow = start_columns:end_columns
        
        %obtain the patch we want to compare with
        patch = double(image(row_searchWindow-delta:row_searchWindow+delta, column_searchWindow-delta:column_searchWindow+delta));
        
        %compute the difference
        sum_squared_distance = sum(sum(double(reference_patch - patch).^2));
        
        %store the results
        distances(distances_index) = sum_squared_distance;
        offsetsRows(distances_index) = row_searchWindow - row;
        offsetsCols(distances_index) = column_searchWindow - col;
        distances_index = distances_index + 1;
        
    end
end

end