function [pruned_boxes pruned_scores] = prune_detection(boxes, scores)
    
    num_boxes = size(boxes, 1);
    threshold = 0.5;
    D = zeros(num_boxes);
    
    % Check all bounding boxes overlap
    for ii=1:num_boxes
        for jj=1:num_boxes
            if compute_overlap(boxes(ii, :), boxes(jj, :)) > threshold
                D(ii, jj) = 1;
            end
        end
    end
    
    % Find connected component, group of boundinb boxes that are likely
    % coming from the same objects
    [S, C] = graphconncomp(sparse(D));
    pruned_boxes = zeros(S, 4);
    pruned_scores = zeros(S, 1);
    for ii=1:S
        index = (ii == C);
        corresponding_boxes = boxes(index, :);
        corresponding_scores = scores(index);
        
        % get weighted average
        mean_scores = corresponding_scores ./ sum(corresponding_scores);
        y1_mean = sum(corresponding_boxes(:, 1) .* mean_scores);
        x1_mean = sum(corresponding_boxes(:, 2) .* mean_scores);
        y2_mean = sum(corresponding_boxes(:, 3) .* mean_scores);
        x2_mean = sum(corresponding_boxes(:, 4) .* mean_scores);
        
        pruned_boxes(ii, :) = int32([y1_mean x1_mean y2_mean x2_mean]);
        pruned_scores(ii) = max(corresponding_scores);
    end

end