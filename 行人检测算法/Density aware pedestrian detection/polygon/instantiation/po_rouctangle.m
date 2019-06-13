function rouctangle = po_rouctangle(center, lengths, tilt, number_of_edges, resolution)
%po_rouctangle: instantiation of a closed polygon sampling a chamfered rectangle
%   p = po_rouctangle(c, l, t, n, s) computes a closed polygon sampling the
%   chamfered rectangle of center c, lengths l, and tilt angle t with either n
%   regularly spaced vertices (or equivalently n edges) or a vertex every s
%   pixels. Resolution s is used unless n is strictly greater than 7. s does not
%   have to be an integer. If n is strictly greater than 7, then it must be
%   equal to 2*(i+j)+4 for some integers i and j. The chamfer at each corner is
%   made by a single edge with an angle of 45 degrees with respect to the
%   rectangle sides.
%   l can be a 1x2 or a 2x1 matrix. t is in degrees.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

if number_of_edges > 7
   resolution = 2 * sum(lengths) / (number_of_edges + 8 / sqrt(2) - 4);
end

half_lengths = lengths / 2;

corner = resolution / sqrt(2);
lengths = round((lengths - 2 * corner) / resolution);

if any(lengths <= 0)
   rouctangle = [];
   return
end

horizontal_side = corner + resolution * (lengths(2):-1:0) - half_lengths(2);
vertical_side   = corner + resolution * (lengths(1):-1:0) - half_lengths(1);
height          = corner + vertical_side(1);

rouctangle = [vertical_side, zeros(1,lengths(2) + 1) - half_lengths(1), ...
              fliplr(vertical_side), height * ones(1,lengths(2) + 1); ...
              (horizontal_side(1) + corner) * ones(1, lengths(1) + 1), horizontal_side, ...
              zeros(1, lengths(1) + 1) - half_lengths(2), fliplr(horizontal_side); ...
              ones(1, 2 * (sum(lengths) + 2))];

tilt = tilt * pi / 180;
cos_of_tilt = cos(tilt);
sin_of_tilt = sin(tilt);

in_place = [cos_of_tilt, - sin_of_tilt, center(1); ...
            sin_of_tilt,   cos_of_tilt, center(2)];
rouctangle = in_place * rouctangle;

rouctangle = [rouctangle rouctangle(:,1)];
