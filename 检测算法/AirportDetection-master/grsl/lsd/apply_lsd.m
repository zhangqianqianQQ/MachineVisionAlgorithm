function lines_info = apply_lsd(img_path)
    tmp = lsd(img_path);
    lines_info = ceil(tmp(1:4,:)); % X1,X2,Y1,Y2
    lines_info(5,:) = round(sqrt((tmp(1,:)-tmp(2,:)).^2 + (tmp(3,:)-tmp(4,:)).^2)); 
    
    slp = (tmp(3,:)-tmp(4,:)) ./ (tmp(1,:)-tmp(2,:)); 
    angle = atan(abs(slp)) * (180/pi);
    for c = 1 : length(angle)
        if slp(c)>0
            lines_info(6,c) = 180 - angle(c);
        else
            lines_info(6,c) = angle(c);
        end
        % considering that 180 and 0 degree denote the same orientation
        if lines_info(6,c) >= 179
            lines_info(6,c) = 0;
        end
    end
    
end

