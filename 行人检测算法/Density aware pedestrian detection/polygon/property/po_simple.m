function simple = po_simple(polygon)
%po_simple: test of closed polygon (non) self-intersection
%   po_simple(p) is equal to true if the closed polygon p is not
%   self-intersecting.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 13, 2006

number_of_edges = size(polygon,2) - 1;

edges = diff(polygon, 1, 2);
lengths = sum(edges.^2);

for current_edge = 1:(number_of_edges - 2)
   current_vertices = polygon(:,[current_edge, current_edge+1]);
   bounding_box = sort(current_vertices, 2);

   if current_edge == 1
      against = 3:(number_of_edges - 1);
   else
      against = current_edge + 2:number_of_edges;
   end
   before = (polygon(1,[against, against(end)+1]) < bounding_box(1,1));
   after  = (polygon(1,[against, against(end)+1]) > bounding_box(1,2));
   out_of_bb = ((before(1:(end-1)) & before(2:end)) | (after(1:(end-1)) & after(2:end)));
   against(out_of_bb) = [];
   if isempty(against)
      continue
   end
   remaining_edges = unique([against, against+1]);
   before = (polygon(2,remaining_edges) < bounding_box(2,1));
   after  = (polygon(2,remaining_edges) > bounding_box(2,2));
   indices = cumsum([1, (diff(against)>1)+1]);
   out_of_bb = ((before(indices) & before(indices+1)) | (after(indices) & after(indices+1)));
   against(out_of_bb) = [];

   for candidate_edge = against
      v1 = current_vertices(:,1) - polygon(:,candidate_edge);
      v2 = current_vertices(:,2) - polygon(:,candidate_edge);

      d1 = v1(1) * edges(2,candidate_edge) - v1(2) * edges(1,candidate_edge);
      d2 = v2(1) * edges(2,candidate_edge) - v2(2) * edges(1,candidate_edge);

      if (d1 ~= 0) && (d1 * d2 <= 0)
         a = abs(d1) / (abs(d1) + abs(d2));
         intersection = current_vertices(:,1) + (a * edges(:,current_edge)) - polygon(:,candidate_edge);

         if (dot(edges(:,candidate_edge), intersection) > 0) && (lengths(candidate_edge) >= sum(intersection.^2))
            simple = false;
            return
         end
      end
   end
end

simple = true;
