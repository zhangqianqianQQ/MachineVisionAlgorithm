function ratio = compute_overlap(reg, obj)

    reg_width = reg(4)-reg(2)+1;
    reg_height = reg(3)-reg(1)+1;
    
    obj_width = obj(4)-obj(2)+1;
    obj_height = obj(3)-obj(1)+1;

    intersection = rectint([reg(2) reg(1) reg_width reg_height], ...
        [obj(2) obj(1) obj_width obj_height]);
    
    reg_area = reg_width*reg_height;
    obj_area = obj_width*obj_height;
    
    ratio = intersection / (reg_area + obj_area - intersection);

end
