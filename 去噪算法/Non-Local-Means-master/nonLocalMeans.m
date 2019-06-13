function [result] = nonLocalMeans(image, sigma, h, patchSize, windowSize, rgb)
    
    % the code is very similar to what we did in
    % "nonLocalMeansWithoutIntegral" and "TemplateMatchingIntegralImage"
    image = double(image);
    delta_window = floor(windowSize/2);
    delta = floor(patchSize/2);
    result = image;
    
    [rows, columns, dimensions] = size(image);
    
    tic
    integralImagesCell = cell(windowSize, windowSize);
    
    % All the attempts made to store and to compute the integral images are 
    % explained in the "templateMatchingIntegralImage" file
    
    for row_searchWindow = -delta_window:delta_window
        for column_searchWindow = -delta_window:delta_window
            
            xOffset = row_searchWindow;
            yOffset = column_searchWindow;
            
            shifted_image = imtranslate(image,[yOffset, xOffset]);

            %integral_image = computeIntegralImage((shifted_image-image).^2, false);
            % NOTE MATLAB funciton is obviously faster
            integral_image = integralImage((shifted_image-image).^2);
            
            integralImagesCell{xOffset+delta_window+1, yOffset+delta_window+1} = integral_image;
            
        end
    end
    toc
    
    
    for row = 1+delta:rows-delta
        
        % clip the searchWindow
        start_rows = max(row-delta_window, 1+delta);
        end_rows = min(row+delta_window, rows-delta);
        
        for col = 1+delta:columns-delta
            
            start_columns = max(col-delta_window, 1+delta);
            end_columns = min(col+delta_window, columns-delta);
            
            % the same values in the other non local means version
            weighted_sum = 0;
            weight_sum = 0;
            
            % Loop through all the pixels in the SearchWindow 
            for row_searchWindow = start_rows : end_rows
                for column_searchWindow = start_columns : end_columns
                    
                    xOffset = row_searchWindow - row;
                    yOffset = column_searchWindow - col;
                    
                    % retrive the Integral Image for the corresponding
                    % offset
                    integral_image = integralImagesCell{xOffset+delta_window+1, yOffset+delta_window+1};
                    
                    % Compute the distance (how is explained inside the function)
                    distance = evaluateIntegralImage(integral_image, row_searchWindow, column_searchWindow, delta);
                    
                    %compute the weights
                    weight = computeWeighting(distance, h, sigma, patchSize);
                    
                    % compute the weighted sum
                    weighted_sum = weighted_sum +  (double(image(row_searchWindow,column_searchWindow, :)) * weight);
                    
                    % keep adding the weights in order to normalize.
                    weight_sum = weight_sum + weight;
                end
            end
            
            % store the resulting denoised pixel at location (row, col)
            result(row, col, :) = (weighted_sum/weight_sum);
            
        end
    end
    
    % We need to normalize to actually see something otherwise is going to
    % bee too bright.
    result = 255*(result - min(result(:))) / (max(result(:)) - min(result(:)));
    result = uint8(result);

end

