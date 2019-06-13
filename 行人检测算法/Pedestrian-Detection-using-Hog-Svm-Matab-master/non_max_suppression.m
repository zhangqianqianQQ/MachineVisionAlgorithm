function max_indices = non_max_suppression(coords, probs, bb_sizes)
% NON_MAX_SUPRESION applies non maximum suppression to get the 
% most confident detections over a proximity area.
% Input: window coordiantes, window classification probabilities and 
%        window size referenced to the level 0 pyramid layer.
% Output: the most confident window indices

%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 23-Nov-2013 12:37:16 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : non_max_supresion.m 

MIN_DIST = 1024;
 MAX_AREA = 128*64/6;

max_indices = [];
m = size(coords,1);
indices = 1:m;

% while we have nearby windows not suppressed...
while size(indices, 2) > 1

    nearby_window_indices = indices(1);
    
    % for all remaining indices...
    for i=2:size(indices,2)
        
        % we search the nearby windows
        d = distance(coords(indices(1),:), coords(indices(i),:));
        if d < MIN_DIST
            nearby_window_indices = [nearby_window_indices, indices(i)];
        end

        area = overlap(coords(indices(1),:), coords(indices(i),:), bb_sizes(indices(i),:));
         if area > MAX_AREA
             nearby_window_indices = [nearby_window_indices, indices(i)];
         end
    end
    
    % from the nearby windows we only keep the most confident one
    nearby_probs = probs(nearby_window_indices,1);
    max_indx = nearby_window_indices(max(nearby_probs) == nearby_probs);
    max_indices = [max_indices, max_indx];
    
    % removing from indices all the treated ones
    for k=1:size(nearby_window_indices,2)
       indices = indices(indices ~= nearby_window_indices(k));
    end
    
end
end




function d = distance(coords1, coords2)
    d = sum((coords1-coords2).^2);
end

function overlapping_area = overlap(coords1, coords2, bb_size2)
    delta = coords1-coords2;
    delta_x = delta(1);
    delta_y = delta(2);
    h = bb_size2(1);
    w = bb_size2(2);
    overlapping_area = w*h - abs(delta_x*w) - abs(delta_y*h) + abs(delta_x*delta_y);
end



