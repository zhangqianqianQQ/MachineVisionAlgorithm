function lines_refined = refine_lines(lines_info,img_size)
    ignore_scale = 0.05;
    min_len = (img_size(1)*0.03+img_size(2)*0.03)/2;

    lines_refined = []; lr = 0;

    mini = round(img_size(1)*ignore_scale);
    maxi = round(img_size(1)*(1-ignore_scale));
    minj = round(img_size(2)*ignore_scale);
    maxj = round(img_size(2)*(1-ignore_scale));
    for lidx = 1 : size(lines_info,2)
        if lines_info(5,lidx) <= min_len
            % remove too short lines
        elseif lines_info(1,lidx)<mini || lines_info(1,lidx)>maxi || ...
               lines_info(2,lidx)<mini || lines_info(2,lidx)>maxi || ...
               lines_info(3,lidx)<minj || lines_info(3,lidx)>maxj || ...
               lines_info(4,lidx)<minj || lines_info(4,lidx)>maxj
            % remove boundary lines
        else
           lr = lr + 1; 
           lines_refined(:,lr) = lines_info(:,lidx);
        end
    end
end

