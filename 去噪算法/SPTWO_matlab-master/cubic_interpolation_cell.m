function out =  cubic_interpolation_cell(v, x)

   out =  v(1) + 0.5 * x * (v(2) - v(0) +x * (2.0 *  v(0) - 5.0 * v(1) + 4.0 * v(2) - v(3) + x * (3.0 * (v(1) - v(2)) + v(3) - v(0))));
end