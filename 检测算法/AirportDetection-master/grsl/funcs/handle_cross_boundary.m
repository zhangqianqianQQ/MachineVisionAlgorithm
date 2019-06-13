function [x_min,x_max,y_min,y_max] = handle_cross_boundary(x_min,x_max,y_min,y_max,img_size)
    row = img_size(1);
    col = img_size(2);
    if x_min < 1
        x_min = 1;
    end
    if y_min < 1
        y_min = 1;
    end
    if x_max > row
        x_max = row;
    end
    if y_max > col
        y_max = col;
    end
end

