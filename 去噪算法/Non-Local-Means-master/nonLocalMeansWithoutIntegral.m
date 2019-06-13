function [result] = nonLocalMeansWithoutIntegral(image, sigma, h, patchSize, windowSize, rgb)
    
    % The intialization is very similar to the templateMatching code
    delta_window = floor(windowSize/2);
    delta = floor(patchSize/2);
    result = image;
    
    [rows columns dimensions] = size(image);

        
    for row = 1+delta:rows-delta
        % start clipping the searchWindow against the image
        start_rows = max(row-delta_window, 1+delta);
        end_rows = min(row+delta_window, rows-delta);
        
        for col = 1+delta:columns-delta
            % get the reference patch centered at [row col]
            reference_patch = double(image(row-delta:row+delta, col-delta:col+delta, :));  
            start_columns = max(col-delta_window, 1+delta);
            end_columns = min(col+delta_window, columns-delta);            
            
            % the result is going to be the division between these two
            % values
            weighted_sum = 0;
            weight_sum = 0;
            
            % Loop over the clipped searchWindow
            for row_searchWindow = start_rows : end_rows
                for column_searchWindow = start_columns : end_columns
                    
                    % SOME DEBUG CODE
                    %disp('###################');
                    %disp(row_searchWindow-delta);
                    %disp(column_searchWindow);
                    %disp(delta);
                    %disp(column_searchWindow-delta);
                    %disp(column_searchWindow+delta);
                    
                    % get the reference Patch
                    patch = double(image(row_searchWindow-delta:row_searchWindow+delta, column_searchWindow-delta:column_searchWindow+delta, :));
                    % compute the SSD
                    sum_squared_distance = sum(sum(sum(double(patch - reference_patch).^2)));
                    
                    % compute the weight associated with the patch we're
                    % evaluating, how do we compute the patch is explained
                    % in the method "computeWeighting"
                    weight = computeWeighting((sum_squared_distance), h, sigma, patchSize);
                    
                    % NOTE : this is the pixel wise implementation of the
                    % non local means algorithm so we actually store the
                    % weighted sum only for the central pixel of the patch
                    weighted_sum = weighted_sum +  (double(patch(1+delta,1+delta, :)) * weight);
                    
                    % we keep summing all the weights because at the end of
                    % the two loops we want to normalize the weighted sum.
                    weight_sum = weight_sum + weight;
                end
            end
            
            % The result as explained before is the weighted_sum
            % normalized note this code works perfectly with RGB images
            result(row, col, :) = (weighted_sum/weight_sum);

        end
    end
end

