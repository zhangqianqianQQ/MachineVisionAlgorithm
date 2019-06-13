function [ windows, confidences ] = matchScoring( windows, confidences, threshold, img_size )
%MATCHSCORING This function applies a windows merging algorithm inspired 
%   by: Pierre Sermanet et. al "OverFeat: Integrated recognition, 
%       Localization and Detection using Convolutional Networks."

    max_dist = sqrt(img_size(1)^2 + img_size(2)^2);
    max_intersect = img_size(1) * img_size(2);
    
    % Add additional information to the windows (max distance and max
    % intersection area)
    nWindows = size(windows,1);
    win_aux = [windows repmat(max_dist, nWindows, 1) repmat(max_intersect, nWindows, 1)];
    
    % Get windows with lower match score (most similar)
    d = squareform(pdist(win_aux, @matchScore));
    d = d+eye(nWindows);
    [v, p] = min(d);
    [v2, p2] = min(v);
    
    % Only keep merging if their Match_Score <= threshold
    while(size(win_aux,1) > 1 && v2 <= threshold)
        w1 = win_aux(p(p2),:);
        w2 = win_aux(p2,:);

        % Create merged window
        w_new = [mean([w1(1:4); w2(1:4)]) max_dist max_intersect];
        conf_new = mean([confidences(p(p2)) confidences(p2)]);

        % Remove old windows
        win_aux([p(p2) p2],:) = [];
        confidences([p(p2) p2]) = [];

        % Remove old windows' distances
        d([p(p2) p2],:) = [];
        d(:,[p(p2) p2]) = [];
        
        % Calculate distances to new window and insert
        d_new = pdist2(w_new, win_aux, @matchScore);
        d(:,end+1) = d_new';
        d(end+1,:) = [d_new 1];
        win_aux(end+1,:) = w_new;
        confidences(end+1) = conf_new;
        
        % Get windows with lower match score (most similar)
        [v, p] = min(d);
        [v2, p2] = min(v);
    end

    if(~isempty(win_aux))
        windows = win_aux(:,1:4);
    end
end

