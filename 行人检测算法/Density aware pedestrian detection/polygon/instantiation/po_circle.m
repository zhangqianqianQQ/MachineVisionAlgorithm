function circle = po_circle(center, radius, number_of_edges, resolution)
%po_circle: instantiation of a closed polygon sampling a circle
%   p = po_circle(c, r, n, s) computes a closed polygon sampling the circle of
%   center c and radius r with either n regularly spaced vertices (or
%   equivalently n edges) or a vertex every s pixels. Resolution s is used
%   unless n is greater than or equal to 3. s does not have to be an integer.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

if number_of_edges < 3
   number_of_edges = round(2 * pi * radius / resolution);
   if number_of_edges < 3
      number_of_edges = 3;
   end
end

sampling_angles = 2 * pi / number_of_edges * (number_of_edges:-1:1);

circle = [center(1) + radius * sin(sampling_angles); ...
          center(2) + radius * cos(sampling_angles)];

circle = [circle circle(:,1)];
