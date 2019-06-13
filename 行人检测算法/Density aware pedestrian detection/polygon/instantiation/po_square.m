function square = po_square(center, width, tilt, number_of_edges, resolution)
%po_square: instantiation of a closed polygon sampling a square
%   p = po_square(c, w, t, n, s) computes a closed polygon sampling the square
%   of center c, width w, and tilt angle t with either n regularly spaced
%   vertices (or equivalently n edges) or a vertex every s pixels. Resolution s
%   is used unless n is strictly greater than 3. s does not have to be an
%   integer. If n is strictly greater than 3, then it must be equal to 4*i for
%   an integer i.
%   t is in degrees.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

if number_of_edges > 3
   resolution = 4 * width / number_of_edges;
end

half_width = width / 2;
width = round(width / resolution);

if width <= 0
   square = [];
   return
end

horizontal_side = resolution * (width:-1:0) - half_width;
vertical_side   = horizontal_side(2:end-1);
horizontal_side(1) = half_width;

square = [vertical_side, zeros(1,width + 1) - half_width, ...
          fliplr(vertical_side), half_width * ones(1,width + 1); ...
          half_width * ones(1, width - 1), horizontal_side, ...
          zeros(1, width - 1) - half_width, fliplr(horizontal_side); ...
          ones(1, 4 * width)];

tilt = tilt * pi / 180;
cos_of_tilt = cos(tilt);
sin_of_tilt = sin(tilt);

in_place = [cos_of_tilt, - sin_of_tilt, center(1); ...
            sin_of_tilt,   cos_of_tilt, center(2)];
square = in_place * square;

square = [square(:,end) square];
