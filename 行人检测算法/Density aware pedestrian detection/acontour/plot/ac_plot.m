function o_handles = ac_plot(o_axes_handle, acontour, o_window_height, o_format)
%ac_plot: plot of an active contour in a window of given height
%   o_d = ac_plot(o_x, a, o_h, o_f) plots the active contour a in a window of
%   height o_h. If o_h is not given, the default value is 100. This height is
%   not necessarily the actual height of the axes, especially if plotting in an
%   existing, larger window. It is used to flip the active contour upside down
%   to account for the interpretation of coordinates made by the Active contour
%   toolbox (type: 'help acontour' for more information). If the active contour
%   is to be interpreted as a segmentation of an image or a video frame f, then
%   o_h should be equal to size(f,1).
%
%   o_f is the plot format. It is a string composed of 2 to 4-character fields
%   separated by white spaces. If the first character is 'e', a real number can
%   be concatenated to the field.
%   first character of a field:
%      e for edges, v for vertices, t for tangents, n for normals, or i for indices
%   second character:
%      a color among: r, g, b, c, m, y, k, or w (see LineSpec)
%   third character:
%      for v: +, o, *, ., x, s, d, ^, v, >, <, p, or h (see LineSpec)
%      for e: - or :
%   third and fourth characters:
%      for e only: -- or -. (see LineSpec)
%   real number:
%      for e only: LineWidth {1} in points (1 point = 1/72 inch)
%   By default, o_f is taken equal to 'eb vgo'.
%
%   o_x is an axes handle allowing to plot into axes other than the current
%   axes. o_d is an array of the handles of the graphics objects (vertices,
%   indices, tangents, and normals) added to o_x or the current axes by the
%   plotting.
%
%See also acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 4, 2006

if ishandle(o_axes_handle)
   last_optional_but_1 = 3;
else
   last_optional_but_1 = 2;
   if nargin > 2
      o_format = o_window_height;
   end
   if nargin > 1
      o_window_height = acontour;
   end
   acontour = o_axes_handle;
   o_axes_handle = [];
end

if nargin > last_optional_but_1
   o_edge_style    = '';
   o_vertex_style  = '';
   o_tangent_color = '';
   o_normal_color  = '';
   o_index_color   = '';

   separators = strfind(o_format, ' ');
   start_of_style = 1;
   for separator_index = 1:(length(separators)+1)
      if separator_index <= length(separators)
         style = o_format(start_of_style:(separators(separator_index)-1));
      else
         style = o_format(start_of_style:end);
      end

      switch style(1)
         case 'e', o_edge_style    = style(2:end);
         case 'v', o_vertex_style  = style(2:end);
         case 't', o_tangent_color = style(2:end);
         case 'n', o_normal_color  = style(2:end);
         case 'i', o_index_color   = style(2:end);
      end

      if separator_index <= length(separators)
         start_of_style = separators(separator_index) + 1;
      end
   end
else
   o_edge_style    = 'b';
   o_vertex_style  = 'go';
   o_tangent_color = '';
   o_normal_color  = '';
   o_index_color   = '';

   if nargin < last_optional_but_1
      o_window_height = 100;
      disp([mfilename ': missing height of window; default is ' num2str(o_window_height)])
   end
end

if isempty(o_axes_handle)
   parent = gcf;
   o_axes_handle = gca;
else
   parent = get(o_axes_handle, 'Parent');
   %figure(parent)
end
hold_was_off = (ishold(o_axes_handle) == 0);
if hold_was_off
   clf(parent)
   o_axes_handle = axes('Parent', parent);
   hold(o_axes_handle, 'on')
end
previous_handles = findobj(parent, 'Type', 'line', 'Marker', 'none');

for subac_idx = 1:length(acontour)
   acontour(subac_idx) = l_inverse(acontour(subac_idx));
   if isequal(get(o_axes_handle, 'YDir'), 'normal')
      acontour(subac_idx) = l_upside_down(acontour(subac_idx), o_window_height);
      change_of_sign =  1;
   else
      change_of_sign = -1;
   end

   if ~isempty(o_edge_style)
      cursor = length(o_edge_style);
      linewidth = str2num(o_edge_style(cursor:end));
      while ~isempty(linewidth)
         if linewidth < 0
            break
         end
         cursor = cursor - 1;
         linewidth = str2num(o_edge_style(cursor:end));
      end
      points = fnplt(acontour(subac_idx));
      if length(o_edge_style) == cursor
         %fnplt does not allow to specify an axes handle. therefore, instead of:
         %fnplt(acontour(subac_idx), o_edge_style)
         %that would plot in the current figure, the following is used:
         plot(o_axes_handle, points(1,:), points(2,:), o_edge_style)
      else
         while isempty(str2num(o_edge_style(cursor+1)))
            cursor = cursor + 1;
         end
         %fnplt does not allow to specify an axes handle. therefore, instead of:
         %fnplt(acontour(subac_idx), o_edge_style(1:cursor), str2num(o_edge_style(cursor+1:end)))
         %that would plot in the current figure, the following is used:
         plot(o_axes_handle, points(1,:), points(2,:), o_edge_style(1:cursor), 'LineWidth', str2num(o_edge_style(cursor+1:end)))
      end
   end
end

if isempty(o_vertex_style)
   vertices_handles = [];
else
   vertex_color = intersect(o_vertex_style, 'rgbcmykw');
   if isempty(vertex_color)
      vertex_color = 'r';
   end
   samples = ac_sampling(acontour, 's');
   if iscell(samples)
      acontour_lengths = [0 cellfun(@length, samples)];
      samples = [samples{:}];
   else
      acontour_lengths = [0 length(samples)];
   end
   if nargout > 0
      %plot does not accept (o_axes_handle, samples(1,:), samples(2,:), o_vertex_style,
      %'MarkerFaceColor', vertex_color)
      %??? really ??? that should be checked
      %so instead of:
      %vertices_handles = plot(samples(1,:), samples(2,:), o_vertex_style, 'MarkerFaceColor', vertex_color);
      %the following is used:
      vertices_handles = plot(o_axes_handle, samples(1,:), samples(2,:), o_vertex_style);
      set(vertices_handles, 'MarkerFaceColor', vertex_color);
   else
      plot(o_axes_handle, samples(1,:), samples(2,:), o_vertex_style, 'MarkerFaceColor', vertex_color)
   end
end

indices_handles = [];
if ~isempty(o_index_color)
   if exist('samples', 'var')
      normals = ac_sampling(acontour, 'n');
   else
      [samples, normals] = ac_sampling(acontour, 'sn');
      if iscell(samples)
         acontour_lengths = [0 cellfun(@length, samples)];
         samples = [samples{:}];
      else
         acontour_lengths = [0 length(samples)];
      end
   end

   if iscell(normals)
      normals = change_of_sign * [normals{:}];
   else
      normals = change_of_sign * normals;
   end
   origins = samples - 2 * normals;

   subac_idx = 2;
   for sample_index = 1:size(samples,2)
      if nargout > 0
         indices_handles = [indices_handles; ...
            text(origins(1,sample_index), origins(2,sample_index), ...
            int2str(sample_index - acontour_lengths(subac_idx-1)), ...
            'Parent', o_axes_handle, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Color', o_index_color)];
      else
         text(origins(1,sample_index), origins(2,sample_index), ...
            int2str(sample_index - acontour_lengths(subac_idx-1)), ...
            'Parent', o_axes_handle, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'Color', o_index_color)
      end
      if sample_index == acontour_lengths(subac_idx)
         subac_idx = subac_idx + 1;
      end
   end
end

if isempty(o_tangent_color)
   tangents_handles = [];
else
   if exist('samples', 'var')
      tangents = ac_sampling(acontour, 't');
   else
      [samples, tangents] = ac_sampling(acontour, 'st');
      if iscell(samples)
         samples = [samples{:}];
      end
   end

   if iscell(tangents)
      tangents = [tangents{:}];
   end
   origins = samples - 2 * tangents;
   if nargout > 0
      tangents_handles = quiver(o_axes_handle, ...
         origins(1,:), origins(2,:), tangents(1,:), tangents(2,:), 'c');
   else
      quiver(o_axes_handle, ...
         origins(1,:), origins(2,:), tangents(1,:), tangents(2,:), 'c')
   end
end

if isempty(o_normal_color)
   normals_handles = [];
else
   if ~(exist('samples', 'var') || exist('normals', 'var'))
      [samples, normals] = ac_sampling(acontour, 'sn');
      if iscell(samples)
         samples = [samples{:}];
         normals = change_of_sign * [normals{:}];
      else
         normals = change_of_sign * normals;
      end
   else
      if ~exist('samples', 'var')
         samples = ac_sampling(acontour, 's');
         if iscell(samples)
            samples = [samples{:}];
         end
      end
      if ~exist('normals', 'var')
         normals = ac_sampling(acontour, 'n');
         if iscell(normals)
            normals = change_of_sign * [normals{:}];
         else
            normals = change_of_sign * normals;
         end
      end
   end

   if nargout > 0
      normals_handles = quiver(o_axes_handle, ...
         samples(1,:), samples(2,:), normals(1,:),  normals(2,:), 'm');
   else
      quiver(o_axes_handle, ...
         samples(1,:), samples(2,:), normals(1,:),  normals(2,:), 'm')
   end
end

if hold_was_off
   hold(o_axes_handle, 'off')
end

if nargout > 0
   o_handles = [...
      setdiff(findobj(parent, 'Type', 'line', 'Marker', 'none'), previous_handles); ...
      vertices_handles; indices_handles; tangents_handles; normals_handles];
end



function inverse = l_inverse(acontour)

coefs = ppbrk(acontour, 'coefs');

even_coefs = coefs(2:2:end,:);
coefs(2:2:end,:) = coefs(1:2:end,:);
coefs(1:2:end,:) = even_coefs;

inverse = mkpp(ppbrk(acontour, 'breaks'), coefs, 2);



function upsidedown = l_upside_down(acontour, height_of_window)

coefs = ppbrk(acontour, 'coefs');

coefs(2 :2: end, :) = - coefs(2 :2: end, :);
coefs(2 :2: end, 4) =   coefs(2 :2: end, 4) + height_of_window + 1;

upsidedown = mkpp(ppbrk(acontour, 'breaks'), coefs, 2);
