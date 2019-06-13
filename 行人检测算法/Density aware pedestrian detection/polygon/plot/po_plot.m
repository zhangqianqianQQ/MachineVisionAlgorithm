function po_plot(polygon, o_window_height, o_format)
%po_plot: plot of an open or a closed polygon in a window of given height
%   po_plot(p, o_h, o_f) plots the open or closed polygon p in a window of
%   height o_h. If o_h is not given, the default value is 2 times the mean value
%   of the first coordinates of the vertices. This height is not necessarily the
%   actual height of the axes, especially if plotting in an existing, larger
%   window. It is used to flip the polygon upside down to account for the
%   interpretation of vertex coordinates made by the Polygon toolbox (type:
%   'help polygon' for more information). If the polygon is to be interpreted as
%   a contour segmenting an image or a video frame f, then o_h should be equal
%   to size(f,1).
%
%   o_f is the plot format. It is a string composed of 2 to 4-character fields
%   separated by white spaces.
%   first character of a field:
%      e for edges, v for vertices, or i for indices
%   second character:
%      a color among: r, g, b, c, m, y, k, or w (see LineSpec)
%   third character:
%      for v: +, o, *, ., x, s, d, ^, v, >, <, p, or h (see LineSpec)
%      for e: - or :
%   third and fourth characters:
%      for e only: -- or -. (see LineSpec)
%   By default, o_f is taken equal to 'eb vgo'.
%
%   Note:
%   This function should be modified to take as first argument a window handle
%   to plot in (instead of plotting in the current figure if it exists or a new
%   one otherwise) and to return, if requested, the handles of the created
%   graphic objects.
%
%See also polygon.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 15, 2006

if nargin < 3
   o_edge_style   = 'b';
   o_vertex_style = 'go';
   o_index_color  = '';

   if nargin < 2
      if isequal(polygon(:,1), polygon(:,end))
         o_window_height = 2 * mean(polygon(1,1:end-1));
      else
         o_window_height = 2 * mean(polygon(1,:));
      end
      disp([mfilename ': missing height of window; default is ' num2str(o_window_height)])
   end
else
   o_edge_style   = '';
   o_vertex_style = '';
   o_index_color  = '';

   separators = strfind(o_format, ' ');
   start_of_style = 1;
   for separator_index = 1:(length(separators)+1)
      if separator_index <= length(separators)
         style = o_format(start_of_style:(separators(separator_index)-1));
      else
         style = o_format(start_of_style:end);
      end

      switch style(1)
         case 'e', o_edge_style   = style(2:end);
         case 'v', o_vertex_style = style(2:end);
         case 'i', o_index_color  = style(2:end);
      end

      if separator_index <= length(separators)
         start_of_style = separators(separator_index) + 1;
      end
   end
end

hold_was_off = (ishold == 0);
if hold_was_off
   clf
   hold on
end

if isequal(get(gca, 'YDir'), 'normal')
   polygon(1,:) = o_window_height + 1 - polygon(1,:);
   change_of_sign =  1;
else
   change_of_sign = -1;
end

if ~isempty(o_edge_style)
   plot(polygon(2,:), polygon(1,:), o_edge_style)
end

if ~isempty(o_vertex_style)
   plot(polygon(2,:), polygon(1,:), o_vertex_style)
end

if ~isempty(o_index_color)
   edges = diff(polygon, 1, 2);
   edges = edges ./ repmat(sqrt(sum(edges.^2)), 2, 1);
   edges = [edges(:,end) edges];

   normals = zeros(size(polygon));
   for vertex_index = 1:(size(polygon,2) - 1)
      normals([2 1],vertex_index) = edges(:,vertex_index) + edges(:,vertex_index + 1);
      normals(2,vertex_index) = - normals(2,vertex_index);
      normals(:,vertex_index) = normals(:,vertex_index) / norm(normals(:,vertex_index));
   end

   polygon = polygon - 2 * change_of_sign * normals;

   for vertex_index = 1:(size(polygon,2) - 1)
      %hold on before: quiver(polygon(2,vertex_index), polygon(1,vertex_index), normals(2,vertex_index), normals(1,vertex_index), 4, 'g')
      text(polygon(2,vertex_index), polygon(1,vertex_index), int2str(vertex_index), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', o_index_color)
   end
end

if hold_was_off
   hold off
end
