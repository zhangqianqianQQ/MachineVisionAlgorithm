function [ iou ] = IOU( xi, X )
%IOU Intersection over union similarity measure for two bounding boxes.
%   Each sample must be composed of x = [ULx ULy BRx BRy]


    % Check area on xi
    xi_height = (xi(4) - xi(2) + 1);
    xi_width = (xi(3) - xi(1) + 1);
    xi_area = xi_height * xi_width;

    nSamples = size(X,1);
    iou = zeros(nSamples, 1);
    for j = 1:nSamples
        
        xj = X(j,:);

        % Check area on xj
        xj_height = (xj(4) - xj(2) + 1);
        xj_width = (xj(3) - xj(1) + 1);
        xj_area = xj_height * xj_width;

        % Check intersection
        count_intersect = rectint([xi(2), xi(1), xi_height, xi_width], [xj(2), xj(1), xj_height, xj_width]);

        % Calculate overlap score (intersection over union)
        iou(j) = count_intersect / (xi_area + xj_area - count_intersect);
    end

end

