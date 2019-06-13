function [offsetsRows, offsetsCols, distances] = templateMatchingIntegralImage(row,...
    col,patchSize, searchWindowSize, image)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsX(1) = -1;
% offsetsY(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

% This time, use the integral image method!
% NOTE: Use the 'computeIntegralImage' function developed earlier to
% calculate your integral images
% NOTE: Use the 'evaluateIntegralImage' function to calculate patch sums

image = double(image);
[rows columns d] = size(image);


% The intialization is the same as the TemplateMatching in the naive case
delta = floor(patchSize/2);
delta_window = floor(searchWindowSize/2);

distances = zeros(1,searchWindowSize*searchWindowSize); 
offsetsRows = zeros(1,searchWindowSize*searchWindowSize); 
offsetsCols = zeros(1,searchWindowSize*searchWindowSize);
distances_index = 1;

% I store all my integral images in a Cell Array
integralImagesCell = cell(searchWindowSize, searchWindowSize);

% all the possible offsets are all the possible combinations of indices in
% thesearch window
    for row_searchWindow = -delta_window:delta_window
        for column_searchWindow = -delta_window:delta_window
            
            xOffset = row_searchWindow;
            yOffset = column_searchWindow;
            
            % HOW WE CAN SHIFT THE IMAGE
            % CASE ONE -- AFFINE TRANFSORMATION
            %T = maketform('affine', [1 0 0; 0 1 0; yOffset xOffset  1]);
            %shifted_image = imtransform(image, T,'XData',[1 size(image,2)],'YData',[1 size(image,1)]);
            
            % CASE TWO -- CIRCULAR SHIFT
            %shifted_image = circshift(image , [xOffset,yOffset]);
            
            %TRANSLATE THE IMAGE
            shifted_image = imtranslate(image,[yOffset, xOffset]);
            
            % Let's compute the integral image for the difference squared of the
            % two images (how I compute the integral image is explained in
            % the method "computeIntegralImage").
            integral_image = computeIntegralImage((double(shifted_image-image)).^2, false);
            
            % Store the result, note the cell has no negative indices
            integralImagesCell{xOffset+delta_window+1, yOffset+delta_window+1} = integral_image;
            
            %NOTE : we can also store the integral images ina matrix or in a 
            %       dictionary  
            %c([num2str(xOffset) ' ' num2str(yOffset)]) = integral_image;
            %integralImages(:,:, index:index+2) = integral_image;
            
        end
    end


    start_rows = max(row-delta_window, 1+delta);
    end_rows = min(row+delta_window, rows-delta);
    start_columns = max(col-delta_window, 1+delta);
    end_columns = min(col+delta_window, columns-delta);
            
            for row_searchWindow = start_rows : end_rows
                for column_searchWindow = start_columns : end_columns
                    
                    % SOME DEBUG CODE
                    %disp('###################');
                    %disp(row_searchWindow-delta);
                    %disp(column_searchWindow);
                    %disp(delta);
                    %disp(column_searchWindow-delta);
                    %disp(column_searchWindow+delta);
                    
                    xOffset = row_searchWindow - row;
                    yOffset = column_searchWindow - col;
                    
                    % Get the corresponding integral image at the two
                    % offsets
                    integral_image = integralImagesCell{xOffset+delta_window+1, yOffset+delta_window+1};
                    
                    % compute the distance between the two patches
                    distance = evaluateIntegralImage(integral_image, row_searchWindow, column_searchWindow, delta);
                    
                    % Store the results
                    distances(distances_index) = distance;
                    offsetsRows(distances_index) = xOffset;
                    offsetsCols(distances_index) = yOffset; 
                    distances_index = distances_index + 1;
                end
            end

end