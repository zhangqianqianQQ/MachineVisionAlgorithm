function out =  bicubic_interpolation_cell(p, x, y)
v(1) = cubic_interpolation_cell(p(1,:), y); 
v(2) = cubic_interpolation_cell(p(2,:), y);
    v(3) = cubic_interpolation_cell(p(3,:), y);
    v(4) = cubic_interpolation_cell(p(4,:), y);
   out =  cubic_interpolation_cell(v, x);
    
end