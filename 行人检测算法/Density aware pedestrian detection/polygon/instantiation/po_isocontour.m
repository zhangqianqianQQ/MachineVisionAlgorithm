function isopolygon = po_isocontour(frame, level, o_orientation, o_padding, o_filter)
%po_isocontour: instantiation of a (set of) closed polygon(s) sampling a level set of a frame
%   p = po_isocontour(f, l, o_o, o_d, o_i) computes a (set of) closed polygon(s)
%   sampling the level set l of frame f. Such a level set can be composed of
%   several polygons, possibly nested if a connected set of the set {x | f(x)<l}
%   (or equivalently the set {x | f(x)>l}) has holes.
%   p is either an empty cell, a closed polygon or a cell array of closed polygons.
%
%   o_o specifies the orientation of the polygons that are not nested in other
%   polygons. If o_o is positive or equal to zero, these polygons are oriented
%   counterclockwise. Nested polygons get the orientation
%   (-1)^(nesting_level+offset) where offset is equal to zero if o_o is positive
%   or equal to zero, and equal to 1 otherwise. By default, o_o is taken equal
%   to 1.
%
%   o_d is the padding to be performed (uniformly around the frame) before
%   extracting the level set. It is a cell array containing 2 integers. The
%   first one is the padding width in pixels and the second one is the padding
%   value. No padding is performed by default or if isempty(o_d) is true.
%
%   o_i is a 2-D convolution filter (normally, a smoothing kernel) to be applied
%   after the (optional) padding. If isempty(o_d) is true, no padding is
%   performed before filtering. Otherwise, the padding size in o_d is replaced
%   by the halfsize in both directions (rounded to the nearest lower integers)
%   of o_i. The top and bottom paddings are equal; so are the left and right
%   paddings; however, the top and left paddings are different if the filter is
%   not square. No filtering is performed by default or if isempty(o_i) is true.
%
%   The level set extraction is performed by contourc(f, [l l]). The open
%   polygons are discarded. To ensure that all of the polygons computed by
%   contourc are closed, padding can be used.
%
%See also po_orientation, polygon, contourc.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 14, 2006

if nargin < 5
   o_filter = [];
if nargin < 4
   o_padding = [];
if nargin < 3
   o_orientation = 1;
      end
   end
end

isopolygon = {};

if isempty(o_padding)
   o_padding = 0;
else
   padval = o_padding{2};
   if isempty(o_filter)
      o_padding = o_padding{1};
      padsize = [o_padding o_padding];
   else
      padsize = floor(0.5 * size(o_filter));
      o_padding = padsize(1);
   end
   frame = padarray(frame, padsize, padval);
end

if ~isempty(o_filter)
   frame = imfilter(frame, o_filter);
end

polygons = contourc(frame, [level level]);
if isempty(polygons)
   return
end

polygon_idx = 1;

while polygon_idx < size(polygons,2)
   polygon = flipud(polygons(:, polygon_idx+1:polygon_idx+polygons(2, polygon_idx))) - o_padding;

   if isequal(polygon(:,1), polygon(:,end))
      if o_padding > 0
         polygon(polygon < 1) = 1;
         polygon(1, polygon(1,:) > size(frame,1)) = size(frame,1);
         polygon(2, polygon(2,:) > size(frame,2)) = size(frame,2);
      end

      %contourc may output repeated or almost identical vertices, disturbing
      %po_orientation (or po_simple)
      %and
      %several vertices outside the frame domain may have been projected into
      %identical vertices by the above clipping
      polygon(:,sum(abs(diff(polygon, 1, 2))) < 0.1) = [];
      %what if a polygon is so unsmooth that contourc returns only tiny edges
      %(length<0.1) while being non-negligible?

      if size(polygon,2) > 3
         isopolygon{end+1} = polygon;
      end
   end

   polygon_idx = polygon_idx + polygons(2, polygon_idx) + 1;
end

inclusion = cell(1,length(isopolygon));
for contour_index = 1:length(isopolygon)
   for other_index = (contour_index+1):length(isopolygon)
      inside = inpolygon(isopolygon{contour_index}(1,:), isopolygon{contour_index}(2,:), ...
         isopolygon{other_index}(1,:), isopolygon{other_index}(2,:));
      if all(inside)
         inclusion{contour_index}(end+1) = other_index;
      else
         inside = inpolygon(isopolygon{other_index}(1,:), isopolygon{other_index}(2,:), ...
            isopolygon{contour_index}(1,:), isopolygon{contour_index}(2,:));
         if all(inside)
            inclusion{other_index}(end+1) = contour_index;
         end
      end
   end
end

if o_orientation < 0
   offset = 1;
else
   offset = 0;
end
for contour_index = 1:length(isopolygon)
   isopolygon{contour_index} = po_orientation(isopolygon{contour_index}, ...
      (-1)^(length(inclusion{contour_index})+offset));
end

if length(isopolygon) == 1
   isopolygon = isopolygon{1};
end
