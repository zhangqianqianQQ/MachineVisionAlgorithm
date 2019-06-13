function [ W, confidences, d ] = mergeBestIOU( W, confidences, mergeThreshold, d )

    % Get most similar windows
    if(isempty(d))
        d = squareform(pdist(W, @IOU));
    end
    [v, p] = max(d);
    [v2, p2] = max(v);

    % Only keep merge if their IoU >= mergeThreshold
    if(size(W,1) > 1 && v2 >= mergeThreshold)
        w1 = W(p(p2),:);
        w2 = W(p2,:);

        % Create merged window
        w_new = mean([w1; w2]);
        conf_new = mean([confidences(p(p2)) confidences(p2)]);

        % Remove old windows
        W([p(p2), p2],:) = [];
        confidences([p(p2) p2]) = [];

        % Remove old windows' distances
        d([p(p2) p2],:) = [];
        d(:,[p(p2) p2]) = [];

        % Calculate distances to new window and insert
        d_new = pdist2(w_new, W, @IOU);
        d(:,end+1) = d_new';
        d(end+1,:) = [d_new 0];
        W(end+1,:) = w_new;
        confidences(end+1) = conf_new;
    end
    
end

