function [seg_ori] = get_segmentation_orientation(seg_bw)


contours = fit_contour(double(seg_bw));
angles = zeros(numel(contours.edge_x_coords), 1);

for e = 1 : numel(contours.edge_x_coords)
    if contours.is_completion(e), continue; end
    v1 = contours.vertices(contours.edges(e, 1), :);
    v2 = contours.vertices(contours.edges(e, 2), :);

    if v1(2) == v2(2),
        ang = pi/2;
    else
        ang = -atan((v2(1)-v1(1)) / (v2(2)-v1(2))); 
    end
    if ang >0,
        angles(e) = ang;
    else
        angles(e) = pi+ang;
    end
end

seg_ori = zeros(size(seg_bw));
for e = 1 : numel(contours.edge_x_coords)
    if contours.is_completion(e), continue; end
    for p = 1 : numel(contours.edge_x_coords{e}),
        seg_ori(contours.edge_x_coords{e}(p), contours.edge_y_coords{e}(p)) = angles(e);
    end
end
