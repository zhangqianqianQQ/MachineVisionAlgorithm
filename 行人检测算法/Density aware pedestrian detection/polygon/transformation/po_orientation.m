function orientation_or_polygon = po_orientation(polygon, o_orientation)
%po_orientation: orientation of a closed polygon as a positive or negative real number
%                or setting of orientation of a closed polygon
%   r = po_orientation(p) determines the orientation of polygon p as a real
%   number positive if p is oriented counterclockwise and negative otherwise. In
%   any case, abs(r) should be close to 2*pi.
%
%   l = po_orientation(p, o_o) returns the polygon obtained by setting the
%   orientation of p as follows: if o_o is positive, l is oriented
%   counterclockwise; if o_o is equal to zero, the orientations of p and l are
%   opposite; if o_o is negative, l is oriented clockwise.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

edges = diff(polygon, 1, 2);
length_of_edges = sqrt(sum(edges.^2));

if ~all(length_of_edges)
   disp(['/!\ ' mfilename ': polygon with repeated vertices'])
   if nargin < 2
      orientation_or_polygon = 0;
   else
      orientation_or_polygon = [];
   end
   return
end

edges(:,end+1) = edges(:,1);
length_of_edges(end+1) = length_of_edges(1);

cosines = dot(edges(:,1:end-1), edges(:,2:end)) ./ (length_of_edges(1:end-1) .* length_of_edges(2:end));
cosines(cosines >  1) =  1;%necessary because of possible
cosines(cosines < -1) = -1;%round-off errors leading to complex angles
angles = acos(cosines);

determinant = zeros(1,length(length_of_edges) - 1);
for edge = 1:length(length_of_edges) - 1
   determinant(edge) = det([edges(:,edge) edges(:,edge + 1)]);
end

orientation = sum(sign(determinant) .* angles);

if nargin < 2
   orientation_or_polygon = orientation;
else
   switch sign(o_orientation)
      case 1
         if orientation < 0
            orientation_or_polygon = fliplr(polygon);
         else
            orientation_or_polygon = polygon;
         end

      case 0, orientation_or_polygon = fliplr(polygon);

      case -1
         if orientation > 0
            orientation_or_polygon = fliplr(polygon);
         else
            orientation_or_polygon = polygon;
         end
   end
end
