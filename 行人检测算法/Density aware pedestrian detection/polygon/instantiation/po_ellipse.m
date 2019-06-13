function ellipse = po_ellipse(center, radii, tilt, number_of_edges, resolution)
%po_ellipse: instantiation of a closed polygon sampling an ellipse
%   p = po_ellipse(c, r, t, n, s) computes a closed polygon sampling the ellipse
%   of center c, radii r, and tilt angle t with either n vertices (or
%   equivalently n edges) or a vertex every s pixels in average. The vertices
%   are regularly spaced in angle. Resolution s is used unless n is greater than
%   or equal to 3. s does not have to be an integer.
%   r can be a 1x2 or a 2x1 matrix. t is in degrees.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

if number_of_edges < 3
   h = (diff(radii) / sum(radii))^2;
   arclength = pi * sum(radii) * (1 + 3 * h / (10 + sqrt(4 - 3 * h)));%Ramanujan, 1914

   number_of_edges = round(arclength / resolution);
   if number_of_edges < 3
      number_of_edges = 3;
   end
end

sampling_angles = 2 * pi / number_of_edges * (number_of_edges:-1:1);

ellipse = [radii(1) * sin(sampling_angles); ...
           radii(2) * cos(sampling_angles); ...
           ones(1,number_of_edges)];

tilt = tilt * pi / 180;
cos_of_tilt = cos(tilt);
sin_of_tilt = sin(tilt);

in_place = [cos_of_tilt, - sin_of_tilt, center(1); ...
            sin_of_tilt,   cos_of_tilt, center(2)];
ellipse = in_place * ellipse;

ellipse = [ellipse ellipse(:,1)];
