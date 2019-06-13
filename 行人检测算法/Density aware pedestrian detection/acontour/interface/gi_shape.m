function varargout = gi_shape(varargin)
%gi_shape: graphical interface for instantiating a polygon, a spline, or a mask
%   s = gi_shape(a) opens a graphical interface for instantiating a polygon, a
%   spline, a mask, or returning the parameters of a shape. a is a list of
%   arguments among:
%   Shape: 'free form', 'circle', 'ellipse', 'rouctangle', 'rectangle',
%   'square';
%   Closed or open : 'closed', 'open';
%   Orientation: 'positive', 'counterclockwise', 'trigonometric', 'as is',
%   'negative', 'clockwise';
%   Output: 'parameters' (not valid for 'free form'), 'polygon', 'spline',
%   'mask';
%   Spline building: 'cscvn', 'csape', or equivalent, user-defined function name
%   or handle;
%   Resolution: an integer, r, strictly negative (polygon with r vertices or a
%   spline with r samples) or positive or equal to zero (a vertex/sample every r
%   pixels, approximately);
%   Background: coordinates of the axes ([max_row max_col] for [1 max_row 1
%   max_col], or [min_row max_row min_col max_col]) or a background image (by
%   default, a 100x100 white background);
%   Initialization: an optional initial polygon;
%   Interface: 'persistent' to leave the interface open when done.
%
%   Some arguments can be preceded with 'forced ' to disable the related
%   interface components. For example:
%   s = gi_shape('free form', 'forced spline', 'forced positive', 'forced closed');
%
%   A shape is entered by clicking points, whatever the requested output(s)
%   is(are). Before clicking the first point, one of the shape selectors must be
%   clicked to set the interface in input mode, even if a selector was passed as
%   an argument, disabling the other selectors. The input is ended by clicking a
%   point outside the drawing area. If the closed box is marked, there must be
%   at least 3 points before the input can be ended. The last point entered is
%   automatically connected to, or merged with, the first point entered,
%   depending on their distance.
%   When entering a free form, the left button of the mouse allows to move a
%   point and the middle button allows to delete a point (not only the last
%   one). When entering an ellipse, a rectangle, a rounded rectangle, or a
%   square, the left button allows to rotate the shape (although it is not
%   implemented conveniently).
%   The drawing area can be cleared by pressing the again button.
%
%   If multiple outputs are requested, s is a structure with possible fields
%   parameters, polygon, spline, and mask. By default (no output requested), the
%   polygon is returned.
%
%   Note:
%   This function is only partially described yet. Another short help is
%   available by pressing the help button of the interface. Tooltips are also
%   available.
%
%See also polygon, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 19, 2006

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gi_shape_OpeningFcn, ...
                   'gui_OutputFcn',  @gi_shape_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isvarname(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



function gi_shape_OpeningFcn(hObject, eventdata, handles, varargin)

global g_background g_polygon g_spline_handle g_default_resolution

%default arguments
g_polygon      = [];
g_background   = [];
polygon_type   = '';
axes_intervals = [1 100 1 100];
resolution     = 0;
orientation    = 1;

%processing of optional arguments
for argument_index = 1:(nargin - 3)
   argument = varargin{argument_index};

   if ischar(argument)
      if isequal(strfind(argument, 'forced '), 1)
         forced_characteristic = true;
         argument = argument(8:end);
      else
         forced_characteristic = false;
      end

      switch argument
         case 'free form'
            set(handles.closed_polygon, 'Visible', 'on')
            set(handles.spline_drawing, 'Visible', 'on')
            set([handles.circle_selector handles.ellipse_selector handles.rouctangle_selector ...
               handles.rectangle_selector handles.square_selector], 'Enable', 'off')
            set(handles.resolution_input, 'Enable', 'off')
            set(handles.resolution_accounting, 'String', 'ignored')

         case 'circle'
            set([handles.free_form_selector handles.ellipse_selector handles.rouctangle_selector ...
               handles.rectangle_selector handles.square_selector], 'Enable', 'off')

         case 'ellipse'
            set([handles.free_form_selector handles.circle_selector handles.rouctangle_selector ...
               handles.rectangle_selector handles.square_selector], 'Enable', 'off')

         case 'rouctangle'
            set([handles.free_form_selector handles.circle_selector handles.ellipse_selector ...
               handles.rectangle_selector handles.square_selector], 'Enable', 'off')

         case 'rectangle'
            set([handles.free_form_selector handles.circle_selector handles.ellipse_selector ...
               handles.rouctangle_selector handles.square_selector], 'Enable', 'off')

         case 'square'
            set([handles.free_form_selector handles.circle_selector handles.ellipse_selector ...
               handles.rouctangle_selector handles.rectangle_selector], 'Enable', 'off')

         case 'closed'
            set(handles.closed_polygon, 'Value', 1)
            if forced_characteristic
               set(handles.closed_polygon, 'Enable', 'off')
            end

         case 'open'
            set(handles.closed_polygon, 'Value', 0)
            if forced_characteristic
               set(handles.closed_polygon, 'Enable', 'off')
            end

         case {'positive', 'counterclockwise', 'trigonometric'}
            orientation = 1;
            if forced_characteristic
               set(handles.orientation_selector, 'Enable', 'off')
            end

         case 'as is'
            orientation = 0;
            if forced_characteristic
               set(handles.orientation_selector, 'Enable', 'off')
            end

         case {'negative', 'clockwise'}
            orientation = -1;
            if forced_characteristic
               set(handles.orientation_selector, 'Enable', 'off')
            end

         case 'parameters'
            set(handles.parameters_output, 'Value', 1)
            if forced_characteristic
               set([handles.parameters_output handles.polygon_output ...
                  handles.spline_output handles.mask_output], 'Enable', 'off')
            end

         case 'polygon'
            set(handles.polygon_output, 'Value', 1)
            if forced_characteristic
               set([handles.parameters_output handles.polygon_output ...
                  handles.spline_output handles.mask_output], 'Enable', 'off')
            end

         case 'spline'
            set(handles.spline_output, 'Value', 1)
            set(handles.spline_drawing, 'Value', 1)
            if forced_characteristic
               set([handles.parameters_output handles.polygon_output ...
                  handles.spline_output handles.mask_output], 'Enable', 'off')
               set(handles.spline_drawing, 'Enable', 'off')
            end
            if exist('spline_building', 'var') == 0
               spline_building = @cscvn;
            end

         case 'mask'
            set(handles.mask_output, 'Value', 1)
            if forced_characteristic
               set([handles.parameters_output handles.polygon_output ...
                  handles.spline_output handles.mask_output], 'Enable', 'off')
            end

         case 'persistent'
            set(handles.persistent_end, 'Visible', 'on')
            set(handles.clean_end, 'String', 'Clean end')

         otherwise%case {'cscvn', 'csape'} && otherwise
            if strcmp(argument, 'cscvn')
               spline_building = @cscvn;
            elseif strcmp(argument, 'csape')
               spline_building = @s_csape;
            else
               spline_building = str2func(argument);
            end
      end
   else
      if isa(argument, 'function_handle')
         set(handles.spline_drawing, 'Value', 1)
         spline_building = argument;
      else
         switch numel(argument)
            case 1
               if argument < 0
                  resolution = - argument;
                  set(handles.resolution_input, 'Enable', 'off')
                  set(handles.resolution_input, 'UserData', 0)
                  set(handles.resolution_accounting, 'String', 'forced')
               else
                  resolution = argument;
                  set(handles.resolution_input, 'UserData', 1)
                  set(handles.resolution_accounting, 'String', '')
               end
               set(handles.resolution_input, 'String', num2str(resolution))

            case 2
               axes_intervals = [1 argument(1) 1 argument(2)];

            case 4
               axes_intervals = argument;

            otherwise
               if size(argument,1) == 2
                  g_polygon = argument(:,1:end-1);

                  set(handles.closed_polygon, 'Visible', 'on')
                  set(handles.spline_drawing, 'Visible', 'on')
                  set([handles.circle_selector handles.ellipse_selector handles.rouctangle_selector ...
                     handles.rectangle_selector handles.square_selector], 'Enable', 'off')
                  set(handles.resolution_input, 'Enable', 'off')
                  set(handles.resolution_accounting, 'String', 'ignored')
               else
                  g_background = argument;
                  axes_intervals = [1 size(g_background,1) 1 size(g_background,2)];
               end
         end
      end
   end
end

%layout adjustment
size_of_drawing_area = axes_intervals([2 4]) - axes_intervals([1 3]) + [1 1];
image(zeros(size_of_drawing_area), 'Parent', handles.drawing_area)%do not use 'CData' here
size_of_graduation = get(handles.drawing_area, 'TightInset');
size_of_graduation = size_of_graduation([4 2 1 3]);

zoom_factor = s_layout(hObject, handles, 1, size_of_drawing_area, size_of_graduation);

%background
if isempty(g_background)
   cla
   axis equal
   axis(axes_intervals([3 4 1 2]))
else
   g_background = p_scaling(g_background, 0.7);
   image('CData', g_background, 'Parent', handles.drawing_area)
   colormap('gray')
   axis image
end
hold on

g_default_resolution = floor(mean(size(g_background)) / 15);%from ac_segmentation

%line color
if isempty(g_background)
   line_color = 'k';
else
   line_color = 'w';
end

%storage of global data as global or in structure 'handles'
handles.polygon_type         = polygon_type;
handles.axes_intervals       = axes_intervals;
g_spline_handle              = [];
if exist('spline_building', 'var') == 1
   handles.spline_building   = spline_building;
else
   handles.spline_building   = @cscvn;
end
handles.resolution           = resolution;
handles.orientation          = orientation;
handles.size_of_drawing_area = size_of_drawing_area;
handles.zoom_factor          = zoom_factor;
handles.size_of_graduation   = size_of_graduation;
handles.line_color           = line_color;
if isempty(g_polygon)
   handles.initial_polygon = false;
else
   handles.initial_polygon = true;
end

guidata(hObject, handles)

uiwait(hObject)



function varargout = gi_shape_OutputFcn(hObject, eventdata, handles) 

global g_background g_parameters g_polygon

if isempty(g_polygon)
   varargout{1} = [];
else
%if isempty(g_background)%not necessary because of image() for layout
%   g_polygon(1, :) = handles.axes_intervals(2) + 1 - g_polygon(1, :);
%end%adjustment (inset) which turns the Y axis down

   if get(handles.closed_polygon, 'Value') == 1
      if handles.orientation ~= 0
         g_polygon = po_orientation(g_polygon, handles.orientation);
      end
   end

   outputs = '';
   if get(handles.parameters_output, 'Value') == 1
      outputs(end+1) = 'q';
   end
   if get(handles.polygon_output, 'Value') == 1
      outputs(end+1) = 'p';
   end
   if get(handles.spline_output, 'Value') == 1
      outputs(end+1) = 's';
   end
   if get(handles.mask_output, 'Value') == 1
      outputs(end+1) = 'm';
   end

   if isempty(outputs)
      varargout{1} = g_polygon;
   elseif length(outputs) == 1
      switch outputs
         case 'q', varargout{1} = g_parameters;
         case 'p', varargout{1} = g_polygon;
         case 's', varargout{1} = handles.spline_building(g_polygon);
         case 'm'
            if isempty(g_background)
               mask_size = handles.axes_intervals([2 4]);
            else
               mask_size = size(g_background);
            end
            if get(handles.spline_drawing, 'Value') == 0
               varargout{1} = po_mask(g_polygon, mask_size);
            else
               varargout{1} = ac_mask(handles.spline_building(g_polygon), mask_size);
            end
      end
   else
      spline_out = [];
      for index = 1:length(outputs)
         switch outputs(index)
            case 'q', varargout{1}.parameters = g_parameters;
            case 'p', varargout{1}.polygon    = g_polygon;
            case 's'
               if isempty(spline_out)
                  spline_out = handles.spline_building(g_polygon);
               end
               varargout{1}.spline = spline_out;
            case 'm'
               if isempty(g_background)
                  mask_size = handles.axes_intervals([2 4]);
               else
                  mask_size = size(g_background);
               end
               if get(handles.spline_output, 'Value') == 0
                  varargout{1}.mask = po_mask(g_polygon, mask_size);
               else
                  if isempty(spline_out)
                     spline_out = handles.spline_building(g_polygon);
                  end
                  varargout{1}.mask = ac_mask(spline_out, mask_size);
               end
         end
      end
   end
end

if handles.is_clean_end
   delete(hObject)
end
drawnow



function c_parameters_output(hObject, eventdata, handles)
function c_polygon_output(hObject, eventdata, handles)
function c_spline_output(hObject, eventdata, handles)
function c_mask_output(hObject, eventdata, handles)



function [axes_intervals, line_color] = s_before_input(hObject, handles, free_form)

%exclusive radio button selection
tag = get(hObject, 'Tag');

set([handles.free_form_selector handles.circle_selector handles.ellipse_selector ...
   handles.rouctangle_selector handles.rectangle_selector handles.square_selector], ...
   'Visible', 'off')
set(hObject, 'Enable', 'off', 'Visible', 'on')
handles.to_be_enabled = hObject;
guidata(hObject, handles)

if isempty(handles.polygon_type)
   handles.polygon_type = tag;
   guidata(hObject, handles)
else
   if strcmp(tag, handles.polygon_type)
      set(hObject, 'Value', 1)%because selecting a selected radio button unselects it
   else
      currently_selected = findobj(handles.gi_shape_figure, 'Tag', handles.polygon_type);
      set(currently_selected, 'Value', 0)
      handles.polygon_type = tag;
      guidata(hObject, handles)
   end
end

%resolution
if free_form
   if get(handles.resolution_input, 'UserData') == 1
      set(handles.resolution_input, 'Enable', 'off')
      set(handles.resolution_accounting, 'String', 'ignored')
   end
else
   if get(handles.resolution_input, 'UserData') == 1
      set(handles.resolution_input, 'Enable', 'on')
      if str2double(get(handles.resolution_input, 'String')) == 0
         set(handles.resolution_accounting, 'String', 'automatic')
      else
         set(handles.resolution_accounting, 'String', '')
      end
   end
end

%
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'off')
c_again([], [], handles)
set(handles.gi_shape_figure, 'Pointer', 'fullcross')

axes_intervals = handles.axes_intervals;
line_color     = handles.line_color;



function c_free_form_selector(hObject, eventdata, handles)

global g_background g_parameters g_polygon g_spline_handle

[axes_intervals, line_color] = s_before_input(hObject, handles, true);
handles = guidata(hObject);
set(handles.closed_polygon, 'Visible', 'on')
set(handles.spline_drawing, 'Visible', 'on')

neighborhood = 0.03;

if handles.initial_polygon
   vertex = size(g_polygon,2);
   line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Marker', 'o', 'Color', line_color)
   handles.initial_polygon = false;
   guidata(hObject, handles)
else
   vertex = 0;
end

while true
   if vertex == 0
      pointer = s_click(axes_intervals, line_color, 1, handles.current);
      button = 1;
   elseif vertex < 3
      if get(handles.closed_polygon, 'Value') == 0
         [pointer, button] = s_click(g_polygon(:,end), line_color, handles.current);
         if (pointer(1) < axes_intervals(1)) || (pointer(1) > axes_intervals(2)) || ...
            (pointer(2) < axes_intervals(3)) || (pointer(2) > axes_intervals(4))
            break
         end
      else
         [pointer, button] = s_click(axes_intervals, g_polygon(:,end), line_color, handles.current);
      end
   else
      [pointer, button] = s_click(g_polygon(:,end), line_color, handles.current);
      if (pointer(1) < axes_intervals(1)) || (pointer(1) > axes_intervals(2)) || ...
         (pointer(2) < axes_intervals(3)) || (pointer(2) > axes_intervals(4))
         break
      end
   end
   pointer = transpose(pointer);

   set(handles.initial, 'String', ['(' num2str(pointer(1), '%.2f') ' , ' num2str(pointer(2), '%.2f') ')'])

   switch button
      case 1
         g_polygon = [g_polygon pointer];
         vertex    = vertex + 1;

         if vertex > 1
            line('XData', g_polygon(2, [end-1, end]), 'YData', g_polygon(1, [end-1, end]), 'Marker', 'o', 'Color', line_color)
            if (vertex > 2) && (get(handles.spline_drawing, 'Value') == 1)
               if ~isempty(g_spline_handle)
                  delete(g_spline_handle)
               end
               if get(handles.closed_polygon, 'Value') == 1
                  g_spline_handle = ac_plot(handles.spline_building([g_polygon g_polygon(:,1)]), size(g_background,1), 'eb--0.5');
               else
                  g_spline_handle = ac_plot(handles.spline_building(g_polygon), size(g_background,1), 'eb--0.5');
               end
            end
         else
            line('XData', pointer(2), 'YData', pointer(1), 'Marker', 'o', 'Color', line_color)
         end

      case {2, 3}
         distances = sqrt(sum((g_polygon - pointer * ones(1, vertex)).^2));
         closest   = find(distances == min(distances));
         if distances(closest) / max(abs(axes_intervals)) < neighborhood
            if button == 3
               line('XData', g_polygon(2, closest), 'YData', g_polygon(1, closest), 'Marker', 'o', 'Color', 'g')

               attachment = [];
               if closest ~= 1
                  attachment = [attachment, g_polygon(:, closest - 1)];
               end
               if closest ~= vertex
                  attachment = [attachment, g_polygon(:, closest + 1)];
               end
               pointer = s_click(axes_intervals, attachment, 'g', 3, handles.current);

               if ~isempty(g_background)
                  g_polygon(:, closest) = pointer;
                  image('CData', g_background, 'Parent', handles.drawing_area)
                  line('XData', g_polygon(2, :), 'YData', g_polygon(1, :), 'Marker', 'o', 'Color', line_color)
               else
                  if vertex == 1
                     line('XData', g_polygon(2, 1), 'YData', g_polygon(1, 1), 'Marker', 'o', 'Color', 'w')
                     line('XData', pointer(2),      'YData', pointer(1),      'Marker', 'o', 'Color', line_color)
                  else
                     if closest ~= 1
                        line('XData', g_polygon(2, [closest - 1, closest]),    'YData', g_polygon(1, [closest - 1, closest]),    'Marker', 'o', 'Color', 'w')
                        line('XData', [g_polygon(2, closest - 1), pointer(2)], 'YData', [g_polygon(1, closest - 1), pointer(1)], 'Marker', 'o', 'Color', line_color)
                     end
                     if closest ~= vertex
                        line('XData', g_polygon(2, [closest, closest + 1]),    'YData', g_polygon(1, [closest, closest + 1]),    'Marker', 'o', 'Color', 'w')
                        line('XData', [pointer(2), g_polygon(2, closest + 1)], 'YData', [pointer(1), g_polygon(1, closest + 1)], 'Marker', 'o', 'Color', line_color)
                     end
                  end
                  g_polygon(:, closest) = pointer;
               end
            else
               if ~isempty(g_background)
                  g_polygon(:, closest) = [];
                  vertex = vertex - 1;
                  image('CData', g_background, 'Parent', handles.drawing_area)
                  if vertex ~= 0
                     line('XData', g_polygon(2, :), 'YData', g_polygon(1, :), 'Marker', 'o', 'Color', line_color)
                  end
               else
                  if vertex == 1
                     line('XData', g_polygon(2, 1), 'YData', g_polygon(1, 1), 'Marker', 'o', 'Color', 'w')
                  else
                     if closest ~= 1
                        line('XData', g_polygon(2, [closest - 1, closest]), 'YData', g_polygon(1, [closest - 1, closest]), 'Marker', 'o', 'Color', 'w')
                     end
                     if closest ~= vertex
                        line('XData', g_polygon(2, [closest, closest + 1]), 'YData', g_polygon(1, [closest, closest + 1]), 'Marker', 'o', 'Color', 'w')
                     end
                     if closest == 1
                        line('XData', g_polygon(2, 2), 'YData', g_polygon(1, 2), 'Marker', 'o', 'Color', line_color)
                     elseif ...
                           closest == vertex
                        line('XData', g_polygon(2, vertex - 1), 'YData', g_polygon(1, vertex - 1), 'Marker', 'o', 'Color', line_color)
                     else
                        line('XData', g_polygon(2, [closest - 1, closest + 1]), 'YData', g_polygon(1, [closest - 1, closest + 1]), 'Marker', 'o', 'Color', line_color)
                     end
                  end
                  g_polygon(:, closest) = [];
                  vertex = vertex - 1;
               end
            end
         end
         if ~isempty(g_spline_handle)
            delete(g_spline_handle)
            g_spline_handle = [];
         end
         if (vertex > 2) && (get(handles.spline_drawing, 'Value') == 1)
            if get(handles.closed_polygon, 'Value') == 1
               g_spline_handle = ac_plot(handles.spline_building([g_polygon g_polygon(:,1)]), size(g_background,1), 'eb--0.5');
            else
               g_spline_handle = ac_plot(handles.spline_building(g_polygon), size(g_background,1), 'eb--0.5');
            end
         end
   end
end

if get(handles.closed_polygon, 'Value') == 1
   if norm(g_polygon(:, 1) - g_polygon(:, end)) / max(abs(axes_intervals)) < neighborhood
      g_polygon(:, 1) = g_polygon(:, end);
   else
      g_polygon = [g_polygon, g_polygon(:, 1)];
      line('XData', g_polygon(2, [end - 1, end]), 'YData', g_polygon(1, [end - 1, end]), 'Marker', 'o', 'Color', line_color)
   end
end

g_parameters = [];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')
set(handles.closed_polygon, 'Visible', 'off')
set(handles.spline_drawing, 'Visible', 'off')



function c_closed_polygon(hObject, eventdata, handles)

global g_background g_polygon g_spline_handle

if (size(g_polygon,2) > 2) && (get(handles.spline_drawing, 'Value') == 1)
   if ~isempty(g_spline_handle)
      delete(g_spline_handle)
   end
   if get(handles.closed_polygon, 'Value') == 1
      g_spline_handle = ac_plot(handles.spline_building([g_polygon g_polygon(:,1)]), size(g_background,1), 'eb--0.5');
   else
      g_spline_handle = ac_plot(handles.spline_building(g_polygon), size(g_background,1), 'eb--0.5');
   end
end



function c_spline_drawing(hObject, eventdata, handles)

global g_spline_handle

if get(handles.spline_drawing, 'Value') == 0
   if ~isempty(g_spline_handle)
      delete(g_spline_handle)
      g_spline_handle = [];
   end
else
   c_closed_polygon(hObject, eventdata, handles)
end



function c_circle_selector(hObject, eventdata, handles)

global g_parameters g_polygon g_default_resolution

[axes_intervals, line_color] = s_before_input(hObject, handles, false);
handles = guidata(hObject);

center = s_click(axes_intervals, line_color, 1, handles.current);
set(handles.initial, 'String', ['(' num2str(center(1), '%.2f') ' , ' num2str(center(2), '%.2f') ')'])

on_circle = s_click(axes_intervals, transpose(center), line_color, 1, 'circle', handles.current);

radius = 0.5 * round(2 * norm(on_circle - center));
if radius ~= 0
   resolution = str2double(get(handles.resolution_input, 'String'));
   if isnan(resolution) || (resolution == 0)
      g_polygon = po_circle(center, radius, round(radius), g_default_resolution);
   else
      g_polygon = po_circle(center, radius, 0, resolution);
   end
   line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Color', line_color)
else
   g_polygon = [];
end

g_parameters = [center(1) center(2) radius];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')



function c_ellipse_selector(hObject, eventdata, handles)

global g_parameters g_polygon g_default_resolution

[axes_intervals, line_color] = s_before_input(hObject, handles, false);
handles = guidata(hObject);

tilt = 0;

first_corner = s_click(axes_intervals, line_color, 1, handles.current);
set(handles.initial, 'String', ['(' num2str(first_corner(1), '%.2f') ' , ' num2str(first_corner(2), '%.2f') ')'])

button = 0;
while button ~= 1
   [second_corner, button] = s_click(axes_intervals, [first_corner(1), tilt; first_corner(2), tilt], line_color, 'ellipse', handles.current);
   if button == 3
      tilt_angle = s_click(axes_intervals, [first_corner(1), second_corner(1), tilt; first_corner(2), second_corner(2), tilt], line_color, 3, 'ellipse');
      center = 0.5 * (first_corner + second_corner);
      start_angle = second_corner - center;
      final_angle = tilt_angle    - center;
      if any(start_angle) && any(final_angle)
         tilt = - sign(det([start_angle; final_angle])) * 180 * acos(start_angle * transpose(final_angle) / (norm(start_angle) * norm(final_angle))) / pi;
         second_corner = tilt_angle;
      end
   end
end

center = 0.5 * (first_corner + second_corner);
radii  = 0.5 * abs(first_corner - second_corner);
if all(radii)
   resolution = str2double(get(handles.resolution_input, 'String'));
   if isnan(resolution) || (resolution == 0)
      g_polygon = po_ellipse(center, radii, - tilt, round(4 * sum(radii)), g_default_resolution);
   else
      g_polygon = po_ellipse(center, radii, - tilt, 0, resolution);
   end
   line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Color', line_color)
else
   g_polygon = [];
end

g_parameters = [center(1) center(2) radii(1) radii(2) -tilt];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')



function c_rouctangle_selector(hObject, eventdata, handles)

global g_parameters g_polygon g_default_resolution

[axes_intervals, line_color] = s_before_input(hObject, handles, false);
handles = guidata(hObject);

tilt = 0;

first_corner = s_click(axes_intervals, line_color, 1, handles.current);
set(handles.initial, 'String', ['(' num2str(first_corner(1), '%.2f') ' , ' num2str(first_corner(2), '%.2f') ')'])

button = 0;
while button ~= 1
   [second_corner, button] = s_click(axes_intervals, [first_corner(1), tilt; first_corner(2), tilt], line_color, 'rouctangle', handles.current);
   if button == 3
      tilt_angle = s_click(axes_intervals, [first_corner(1), second_corner(1), tilt; first_corner(2), second_corner(2), tilt], line_color, 3, 'rouctangle');
      center = 0.5 * (first_corner + second_corner);
      start_angle = second_corner - center;
      final_angle = tilt_angle    - center;
      if any(start_angle) && any(final_angle)
         tilt = - sign(det([start_angle; final_angle])) * 180 * acos(start_angle * transpose(final_angle) / (norm(start_angle) * norm(final_angle))) / pi;
         second_corner = tilt_angle;
      end
   end
end

center  = 0.5 * (first_corner + second_corner);
lengths = abs(first_corner - second_corner);
if all(lengths)
   resolution = str2double(get(handles.resolution_input, 'String'));
   if isnan(resolution) || (resolution == 0)
      g_polygon = po_rouctangle(center, lengths, - tilt, round(2 * sum(lengths)) + 4, g_default_resolution);
   else
      g_polygon = po_rouctangle(center, lengths, - tilt, 0, resolution);
   end
   if ~isempty(g_polygon)
      line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Color', line_color)
   end
else
   g_polygon = [];
end

g_parameters = [center(1) center(2) lengths(1) lengths(2) -tilt];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')



function c_rectangle_selector(hObject, eventdata, handles)

global g_parameters g_polygon g_default_resolution

[axes_intervals, line_color] = s_before_input(hObject, handles, false);
handles = guidata(hObject);

tilt = 0;

first_corner = s_click(axes_intervals, line_color, 1, handles.current);
set(handles.initial, 'String', ['(' num2str(first_corner(1), '%.2f') ' , ' num2str(first_corner(2), '%.2f') ')'])

button = 0;
while button ~= 1
   [second_corner, button] = s_click(axes_intervals, [first_corner(1), tilt; first_corner(2), tilt], line_color, 'rectangle', handles.current);
   if button == 3
      tilt_angle = s_click(axes_intervals, [first_corner(1), second_corner(1), tilt; first_corner(2), second_corner(2), tilt], line_color, 3, 'rectangle');
      center = 0.5 * (first_corner + second_corner);
      start_angle = second_corner - center;
      final_angle = tilt_angle    - center;
      if any(start_angle) && any(final_angle)
         tilt = - sign(det([start_angle; final_angle])) * 180 * acos(start_angle * transpose(final_angle) / (norm(start_angle) * norm(final_angle))) / pi;
         second_corner = tilt_angle;
      end
   end
end

center  = 0.5 * (first_corner + second_corner);
lengths = abs(first_corner - second_corner);
if all(lengths)
   resolution = str2double(get(handles.resolution_input, 'String'));
   if isnan(resolution) || (resolution == 0)
      g_polygon = po_rectangle(center, lengths, - tilt, round(2 * sum(lengths)) + 4, g_default_resolution);
   else
      g_polygon = po_rectangle(center, lengths, - tilt, 0, resolution);
   end
   if ~isempty(g_polygon)
      line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Color', line_color)
   end
else
   g_polygon = [];
end

g_parameters = [center(1) center(2) lengths(1) lengths(2) -tilt];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')



function c_square_selector(hObject, eventdata, handles)

global g_parameters g_polygon g_default_resolution

[axes_intervals, line_color] = s_before_input(hObject, handles, false);
handles = guidata(hObject);

tilt = 0;

first_corner = s_click(axes_intervals, line_color, 1, handles.current);
set(handles.initial, 'String', ['(' num2str(first_corner(1), '%.2f') ' , ' num2str(first_corner(2), '%.2f') ')'])

button = 0;
while button ~= 1
   [second_corner, button] = s_click(axes_intervals, [first_corner(1), tilt; first_corner(2), tilt], line_color, 'square', handles.current);
   if button == 3
      tilt_angle = s_click(axes_intervals, [first_corner(1), second_corner(1), tilt; first_corner(2), second_corner(2), tilt], line_color, 3, 'square');
      width  = max(abs(first_corner - second_corner));
      center = first_corner - 0.5 * width * sign(first_corner - second_corner);
      start_angle = second_corner - center;
      final_angle = tilt_angle    - center;
      if any(start_angle) && any(final_angle)
         tilt = - sign(det([start_angle; final_angle])) * 180 * acos(start_angle * transpose(final_angle) / (norm(start_angle) * norm(final_angle))) / pi;
         second_corner = tilt_angle;
      end
   end
end

width  = max(abs(first_corner - second_corner));
center = first_corner - 0.5 * width * sign(first_corner - second_corner);
if width ~= 0
   resolution = str2double(get(handles.resolution_input, 'String'));
   if isnan(resolution) || (resolution == 0)
      g_polygon = po_square(center, width, - tilt, round(4 * width) + 4, g_default_resolution);
   else
      g_polygon = po_square(center, width, - tilt, 0, resolution);
   end
   if ~isempty(g_polygon)
      line('XData', g_polygon(2,:), 'YData', g_polygon(1,:), 'Color', line_color)
   end
else
   g_polygon = [];
end

g_parameters = [center(1) center(2) width -tilt];

set(handles.gi_shape_figure, 'Pointer', 'default')
set([handles.again handles.persistent_end handles.clean_end], 'Enable', 'on')



function resolution_input_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end



function c_resolution_input(hObject, eventdata, handles)



function c_orientation_selector_instantiation(hObject, eventdata, handles)

if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end



function c_orientation_selector(hObject, eventdata, handles)

%Order must be: 'Positive', 'As is', 'Negative' <=> 1, 2, 3
handles.orientation = 2 - get(hObject, 'Value');
guidata(hObject, handles)



function c_again(hObject, eventdata, handles)

global g_background g_polygon g_spline_handle

if isempty(hObject)
   set(handles.initial, 'String', '')
   set(handles.current, 'String', '')

   if get(handles.resolution_input, 'UserData') == 1
      set(handles.resolution_input, 'Enable', 'on')
      if str2double(get(handles.resolution_input, 'String')) == 0
         set(handles.resolution_accounting, 'String', 'automatic')
      else
         set(handles.resolution_accounting, 'String', '')
      end
   end
else
   set(hObject, 'Enable', 'off')

   set([handles.free_form_selector handles.circle_selector handles.ellipse_selector ...
      handles.rouctangle_selector handles.rectangle_selector handles.square_selector], ...
      'Visible', 'on')
   set(handles.to_be_enabled, 'Enable', 'on')

   set(handles.initial, 'String', 'about initial')
   set(handles.current, 'String', 'about current')

   currently_selected = findobj(handles.gi_shape_figure, 'Tag', handles.polygon_type);
   set(currently_selected, 'Value', 0)
   handles.polygon_type = '';
   g_spline_handle = [];
   guidata(hObject, handles)
end

if ~isempty(g_polygon) && ~handles.initial_polygon
   if isempty(g_background)
      cla
   else
      hold off
      image('CData', g_background, 'Parent', handles.drawing_area)
   end
   hold on

   g_polygon = [];
end



function c_persistent_end(hObject, eventdata, handles)

set(findobj(handles.gi_shape_figure, 'Type', 'uicontrol'), 'Enable', 'off')

handles.is_clean_end = false;
guidata(hObject, handles)
uiresume(handles.gi_shape_figure)



function c_clean_end(hObject, eventdata, handles)

handles.is_clean_end = true;
guidata(hObject, handles)
uiresume(handles.gi_shape_figure)



function c_help(hObject, eventdata, handles)

persistent p_help_figure

if isempty(p_help_figure) || ~ishandle(p_help_figure)
   p_help_figure = msgbox({['A point is entered by a complete mouse click: Button down and up. ' ...
      'Pressing a button, moving the mouse, and releasing the button does not enter the expected edge.'] ...
      ' ' ...
      '-- Free-form polygon --' ...
      ['A free-form polygon is the only type of polygon which can be closed or opened. ' ...
      'The other available types are always closed. ' ...
      'The polygon drawing is ended when a point is entered outside the drawing area. ' ...
      'If the closed option is selected, the last point entered within the drawing area ' ...
      'is automatically connected to, or merged with, the first point entered if ' ...
      'these 2 points are far from each other, or not, respectively. ' ...
      'They are far from each other if they are farther apart than 3% of the ' ...
      'largest dimension of the drawing area.'] ...
      ' ' ...
      '-- Polygon orientation --' ...
      ['The orientation of a polygon can be positive (i.e., counterclockwise), ' ...
      '''as is'' (i.e., respecting the drawing order), or negative (i.e., clockwise).'] ...
      'To be continued'}, ...
      'Creation of a Polygon', 'help');
else
   figure(p_help_figure)
end



function c_zoom_increase(hObject, eventdata, handles)

if s_layout(handles.gi_shape_figure, handles, handles.zoom_factor + 0.1) > 0
   handles.zoom_factor = handles.zoom_factor + 0.1;
   guidata(hObject, handles)
end



function c_zoom_decrease(hObject, eventdata, handles)

if s_layout(handles.gi_shape_figure, handles, handles.zoom_factor - 0.1) > 0
   handles.zoom_factor = handles.zoom_factor - 0.1;
   guidata(hObject, handles)
end



function zoom_factor = s_layout(hObject, handles, zoom_factor_in, o_size_of_drawing_area, o_size_of_graduation)

if nargin < 4
   size_of_drawing_area = zoom_factor_in * handles.size_of_drawing_area;
   size_of_graduation   = handles.size_of_graduation;
else
   size_of_drawing_area = zoom_factor_in * o_size_of_drawing_area;
   size_of_graduation   = o_size_of_graduation;
end

%size constraints
min_width_of_gui  = 550;%coherent with guide design
min_height_of_gui = 425;%coherent with guide design

margin = 10;%coherent with guide design

origin_of_drawing_area      = [115 240];%coherent with guide design
normal_size_of_drawing_area = [300 300];%coherent with guide design
min_size_of_drawing_area    = [ 50  50];%user defined

graduation_padding = [sum(size_of_graduation([1 2])) sum(size_of_graduation([3 4]))];

%size of gui
size_of_area_with_graduation = size_of_drawing_area + graduation_padding;

width_of_gui  = max(origin_of_drawing_area(2) + size_of_area_with_graduation(2) + margin, min_width_of_gui);
height_of_gui = max(origin_of_drawing_area(1) + size_of_area_with_graduation(1) + margin, min_height_of_gui);
size_of_gui   = [width_of_gui height_of_gui];

size_of_screen = s_screensize;
size_of_screen = size_of_screen([2 1]);

too_big   = (any(size_of_gui ~= min(size_of_gui, round(0.75 * size_of_screen))));
too_small = (any(size_of_drawing_area ~= max(size_of_drawing_area, min_size_of_drawing_area)));

if (too_big || too_small) && (nargin < 4)
   if too_big
      set(handles.zoom_increase, 'Enable', 'off')
   else
      set(handles.zoom_decrease, 'Enable', 'off')
   end

   zoom_factor = -1;
else
   if nargin < 4
      zoom_factor = zoom_factor_in;
   else
      size_of_drawing_area = size_of_drawing_area / zoom_factor_in;
      zoom_factor = min((normal_size_of_drawing_area - graduation_padding) ./ size_of_drawing_area);
      zoom_factor = 0.1 * floor(10 * zoom_factor);

      size_of_drawing_area = zoom_factor * size_of_drawing_area;
      size_of_area_with_graduation = size_of_drawing_area + graduation_padding;

      width_of_gui  = max(origin_of_drawing_area(2) + size_of_area_with_graduation(2) + margin, min_width_of_gui);
      height_of_gui = max(origin_of_drawing_area(1) + size_of_area_with_graduation(1) + margin, min_height_of_gui);
      size_of_gui   = [width_of_gui height_of_gui];
   end

   %size and position of gui
   set(hObject, 'Position', [round(0.5 * (size_of_screen - size_of_gui)), size_of_gui]);

   %size and position of elements
   set(handles.drawing_area, 'Position', [origin_of_drawing_area(2) + size_of_graduation(3), ...
      origin_of_drawing_area(1) + size_of_graduation(2), size_of_drawing_area(2), size_of_drawing_area(1)])

   %status of zoom buttons
   set([handles.zoom_decrease handles.zoom_increase], 'Enable', 'on')
   set(handles.zoom_factor_display, 'String', num2str(zoom_factor))
end



function spline_out = s_csape(polygon)

if isequal(polygon(:,1), polygon(:,end))
   spline_out = csape(0:size(polygon,2)-1, polygon, 'periodic');
else
   spline_out = csape(0:size(polygon,2)-1, polygon);
end



function varargout = s_click(varargin)

global g_text_area g_elastic_bands ...
   g_first_corner g_second_corner g_tilt g_tilting

if nargin == 1
   if ischar(varargin{1})
      feval(varargin{1})
      return
   end
end

intervals_of_axes = [];
anchors = [];
button_required = 0;
g_text_area = pi;

for argument_index = 1:nargin
   if ischar(varargin{argument_index})
      if length(varargin{argument_index}) == 1
         line_color = varargin{argument_index};
      else
         anchor_type = varargin{argument_index};
      end
   else
      is_handle = false;
      if ishandle(varargin{argument_index})
         if strcmp(get(varargin{argument_index}, 'Type'), 'uicontrol')
            if strcmp(get(varargin{argument_index}, 'Style'), 'text')
               is_handle = true;
            end
         end
      end

      if is_handle
         g_text_area = varargin{argument_index};
      else
         if size(varargin{argument_index},1) == 1
            if size(varargin{argument_index},2) == 1
               button_required = varargin{argument_index};
            else
               intervals_of_axes = varargin{argument_index};
            end
         else
            anchors = flipud(varargin{argument_index});
            if ~exist('anchor_type', 'var')
               anchor_type = 'line';
            end
         end
      end
   end
end

if isempty(anchors)
   if ishandle(g_text_area)
      original_WBMF = get(gcf, 'WindowButtonMotionFcn');
      set(gcf, 'WindowButtonMotionFcn', 's_click(''pointer_position'');')
   end
else
   original_WBMF = get(gcf, 'WindowButtonMotionFcn');

   g_elastic_bands = [];

   switch anchor_type
      case 'line'
         for current_band = 1:size(anchors,2)
            g_elastic_bands(current_band) = line(...
               'XData', anchors(1, current_band), 'YData', anchors(2, current_band), ...
               'Clipping', 'off', 'LineStyle', '--', 'Color', line_color);
         end
         set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_line'');')

      case 'circle'
         g_elastic_bands(1) = line(...
            'XData', anchors(1), 'YData', anchors(2), ...
            'Clipping', 'off', 'LineStyle', '--', 'Color', line_color);
         g_elastic_bands(2) = line(...
            'XData', anchors(1), 'YData', anchors(2), ...
            'Clipping', 'off', 'LineStyle', '--', 'Color', line_color);
         set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_circle'');')

      case {'ellipse', 'rouctangle', 'rectangle', 'square'}
         g_first_corner = anchors(:,1);

         switch size(anchors,2)
            case 1
               g_tilting = false;
               g_tilt = 0;

            case 2
               g_tilting = false;
               g_tilt = anchors(1,2);

            case 3
               g_tilting = true;
               g_second_corner = anchors(:,2);
               g_tilt = anchors(1,3);
         end

         g_elastic_bands(1) = line('XData', [], 'YData', [], ...
            'Clipping', 'off', 'LineStyle', '--', 'Color', line_color);

         switch anchor_type
            case 'ellipse',    set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_ellipse'');')
            case 'rouctangle', set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_rouctangle'');')
            case 'rectangle',  set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_rectangle'');')
            otherwise,         set(gcf, 'WindowButtonMotionFcn', 's_click(''s_live_square'');')
         end
   end
end

while true
   if waitforbuttonpress == 0
      switch get(gcf, 'SelectionType')
         case 'normal', button_pressed = 1;
         case 'extend', button_pressed = 2;
         case 'alt',    button_pressed = 3;
         otherwise,     button_pressed = 1;
      end

      if (button_pressed == button_required) || (button_required == 0)
         pointer = get(gca, 'CurrentPoint');
         pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);
         pointer_x = pointer(1);
         pointer_y = pointer(2);

         if isempty(intervals_of_axes)
            break
         else
            if (pointer_x >= intervals_of_axes(3)) && (pointer_x <= intervals_of_axes(4)) && ...
               (pointer_y >= intervals_of_axes(1)) && (pointer_y <= intervals_of_axes(2))
               break
            end
         end
      end
   end
end

if isempty(anchors)
   if ishandle(g_text_area)
      set(gcf, 'WindowButtonMotionFcn', original_WBMF)
   end
else
   set(gcf, 'WindowButtonMotionFcn', original_WBMF)
   delete(g_elastic_bands)
end

varargout{1} = [pointer_y pointer_x];
if nargout >= 2
   varargout{2} = button_pressed;
end



function pointer_position

global g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);
set(g_text_area, 'String', ['(' num2str(pointer(2), '%.2f') ' , ' num2str(pointer(1), '%.2f') ')'])

drawnow



function s_live_line

global g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);

if ishandle(g_text_area)
   set(g_text_area, 'String', ['(' num2str(pointer(2), '%.2f') ' , ' num2str(pointer(1), '%.2f') ')'])
end

for current_band = 1:length(g_elastic_bands)
   elastic_band_x = get(g_elastic_bands(current_band), 'XData');
   elastic_band_y = get(g_elastic_bands(current_band), 'YData');

   elastic_band_x(2) = pointer(1);
   elastic_band_y(2) = pointer(2);

   set(g_elastic_bands(current_band), 'XData', elastic_band_x, 'YData', elastic_band_y)
end

drawnow



function s_live_circle

global g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');

center_x = get(g_elastic_bands(1), 'XData');
center_y = get(g_elastic_bands(1), 'YData');

center    = [center_x(1)  center_y(1)];
on_circle = [pointer(1,1) pointer(1,2)];

radius = 0.5 * round(2 * norm(on_circle - center));

if ishandle(g_text_area)
   set(g_text_area, 'String', num2str(radius, '%.2f'))
end

if radius ~= 0
   polygon = po_circle(center, radius, round(radius), 5);

   set(g_elastic_bands(1), 'XData', [center(1) on_circle(1)], 'YData', [center(2) on_circle(2)])
   set(g_elastic_bands(2), 'XData', polygon(1,:), 'YData', polygon(2,:))
else
   set(g_elastic_bands(1), 'XData', center(1), 'YData', center(2))
   set(g_elastic_bands(2), 'XData', [], 'YData', [])
end

drawnow



function s_live_ellipse

global g_first_corner g_second_corner g_tilt g_tilting g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);

if g_tilting
   second_corner   = g_second_corner;
   current_pointer = pointer;
else
   second_corner = pointer;
end

radii = 0.5 * abs(g_first_corner - second_corner);

if ishandle(g_text_area)
   set(g_text_area, 'String', [num2str(radii(2), '%.2f') ' / ' num2str(radii(1), '%.2f')])
end

if all(radii)
   center = 0.5 * (g_first_corner + second_corner);
   if g_tilting
      start_angle = second_corner   - center;
      final_angle = current_pointer - center;
      if any(start_angle) && any(final_angle)
         g_tilt = sign(det([start_angle final_angle])) * 180 * acos(transpose(start_angle) * final_angle / (norm(start_angle) * norm(final_angle))) / pi;
      end
   end
   polygon = po_ellipse(center, radii, g_tilt, round(4 * sum(radii)), 5);

   set(g_elastic_bands(1), 'XData', polygon(1,:), 'YData', polygon(2,:))
else
   set(g_elastic_bands(1), 'XData', [], 'YData', [])
end

drawnow



function s_live_rouctangle

global g_first_corner g_second_corner g_tilt g_tilting g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);

if g_tilting
   second_corner   = g_second_corner;
   current_pointer = pointer;
else
   second_corner = pointer;
end

lengths = abs(g_first_corner - second_corner);

if ishandle(g_text_area)
   set(g_text_area, 'String', [num2str(lengths(2), '%.2f') ' / ' num2str(lengths(1), '%.2f')])
end

if all(lengths)
   center = 0.5 * (g_first_corner + second_corner);
   if g_tilting
      start_angle = second_corner   - center;
      final_angle = current_pointer - center;
      if any(start_angle) && any(final_angle)
         g_tilt = sign(det([start_angle final_angle])) * 180 * acos(transpose(start_angle) * final_angle / (norm(start_angle) * norm(final_angle))) / pi;
      end
   end
   polygon = po_rouctangle(center, lengths, g_tilt, round(2 * sum(lengths)) + 4, 5);

   if isempty(polygon)
      set(g_elastic_bands(1), 'XData', [], 'YData', [])
   else
      set(g_elastic_bands(1), 'XData', polygon(1,:), 'YData', polygon(2,:))
   end
else
   set(g_elastic_bands(1), 'XData', [], 'YData', [])
end

drawnow



function s_live_rectangle

global g_first_corner g_second_corner g_tilt g_tilting g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);

if g_tilting
   second_corner   = g_second_corner;
   current_pointer = pointer;
else
   second_corner = pointer;
end

lengths = abs(g_first_corner - second_corner);

if ishandle(g_text_area)
   set(g_text_area, 'String', [num2str(lengths(2), '%.2f') ' / ' num2str(lengths(1), '%.2f')])
end

if all(lengths)
   center = 0.5 * (g_first_corner + second_corner);
   if g_tilting
      start_angle = second_corner   - center;
      final_angle = current_pointer - center;
      if any(start_angle) && any(final_angle)
         g_tilt = sign(det([start_angle final_angle])) * 180 * acos(transpose(start_angle) * final_angle / (norm(start_angle) * norm(final_angle))) / pi;
      end
   end
   polygon = po_rectangle(center, lengths, g_tilt, round(2 * sum(lengths)) + 4, 5);

   if isempty(polygon)
      set(g_elastic_bands(1), 'XData', [], 'YData', [])
   else
      set(g_elastic_bands(1), 'XData', polygon(1,:), 'YData', polygon(2,:))
   end
else
   set(g_elastic_bands(1), 'XData', [], 'YData', [])
end

drawnow



function s_live_square

global g_first_corner g_second_corner g_tilt g_tilting g_elastic_bands g_text_area

pointer = get(gca, 'CurrentPoint');
pointer = 0.5 * round(2 * [pointer(1,1); pointer(1,2)]);

if g_tilting
   second_corner   = g_second_corner;
   current_pointer = pointer;
else
   second_corner = pointer;
end

width = max(abs(g_first_corner - second_corner));

if ishandle(g_text_area)
   set(g_text_area, 'String', num2str(width, '%.2f'))
end

if width ~= 0
   center = g_first_corner - 0.5 * width * sign(g_first_corner - second_corner);
   if g_tilting
      start_angle = second_corner   - center;
      final_angle = current_pointer - center;
      if any(start_angle) && any(final_angle)
         g_tilt = sign(det([start_angle final_angle])) * 180 * acos(transpose(start_angle) * final_angle / (norm(start_angle) * norm(final_angle))) / pi;
      end
   end
   polygon = po_square(center, width, g_tilt, round(4 * width) + 4, 5);

   if isempty(polygon)
      set(g_elastic_bands(1), 'XData', [], 'YData', [])
   else
      set(g_elastic_bands(1), 'XData', polygon(1,:), 'YData', polygon(2,:))
   end
else
   set(g_elastic_bands(1), 'XData', [], 'YData', [])
end

drawnow



function varargout = s_screensize

default_unit = get(0, 'Units');
set(0, 'Units', 'pixels')

size_of_screen = get(0, 'ScreenSize');
size_of_screen = size_of_screen([4 3]);

set(0, 'Units', default_unit)

if nargout < 1
   disp(size_of_screen)
else
   varargout{1} = size_of_screen;
end



%[pointer_x, pointer_y]
%[pointer_x, pointer_y, button_pressed]
%()
%(intervals_of_axes)
%(intervals_of_axes, anchors, color)
%(intervals_of_axes, anchors, color, button_required)
%(intervals_of_axes, anchors, color, button_required, anchor_type)
%
%It is not allowed to pass only one string
