function varargout = ac_evolution(task, about_acontours, varargin)
%ac_evolution: storage, properties, and plot of the evolution of a set of active
%              contours
%   o_e = ac_evolution(t, b, a) performs a task, t, related to the evolution of
%   a set of active contours according to some arguments, a. t is a string among
%   'initialization', 'new resolution', 'update', 'evolution rate', 'durations',
%   'durations (str)', 'plot', and 'clear'. The tasks 'initialization', 'new
%   resolution', 'update', and 'evolution rate' are meant to be called by
%   ac_segmentation only.
%
%   d = ac_evolution('durations', b) returns the optimal evolution steps
%   computed for active contour b during the last resolution/scale, or an empty
%   array if the constant step mode was chosen. At each iteration, the velocity
%   computed by the function passed to ac_segmentation as the argument
%   velocity_amplitude is multiplied by a constant or optimal evolution step
%   representing time, hence the name duration.
%
%   d = ac_evolution('durations (str)', b) returns the optimal evolution steps
%   of active contour b as a formatted string.
%
%   ac_evolution('plot', b) creates a figure and plots the optimal steps (or the
%   constant function 1 for constant step) and the mean abs-amplitude of active
%   contour b during the last resolution/scale.
%
%   ac_evolution('clear') clears the persistent variables of ac_evolution. Most
%   of the tasks produce an error if called afterward.
%
%   Note:
%   The other tasks should be documented in a later release.
%
%See also ac_segmentation, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 21, 2006

persistent p_resolution_idx p_mean_amplitudes...
   p_storage_per_resolution p_duration_storage p_durations
%{resolution}(acontour index, iteration)

switch task
   case 'initialization'%, number of acontours, number of resolutions, fake "previous" durations
      p_resolution_idx = 0;

      p_mean_amplitudes = cell(varargin{1}, 1);

      p_storage_per_resolution = (varargin{2} <= 0);
      if any(p_storage_per_resolution)
         p_durations = cell(varargin{1}, 1);
      end

      for resolution_idx = 1:varargin{1}
         p_mean_amplitudes{resolution_idx} = zeros(about_acontours, 1);
         p_mean_amplitudes{resolution_idx}(:,1) = 1;%fake "previous" mean amplitudes
         if p_storage_per_resolution(resolution_idx)
            p_durations{resolution_idx} = zeros(about_acontours, 1);
            p_durations{resolution_idx}(:,1) = - varargin{2}(resolution_idx);%fake "previous" duration
         end
      end

   case 'new resolution'%
      p_resolution_idx = p_resolution_idx + 1;
      p_duration_storage = p_storage_per_resolution(p_resolution_idx);

   case 'update'%, acontour index, amplitude, duration
      if ~any(p_mean_amplitudes{p_resolution_idx}(:,end) < 0)
         p_mean_amplitudes{p_resolution_idx}(:,end+1) = -1;
         if p_duration_storage
            p_durations{p_resolution_idx}(:,end+1) = 0;
         end
      end
      p_mean_amplitudes{p_resolution_idx}(about_acontours,end) = mean(abs(varargin{1}));
      if p_duration_storage
         p_durations{p_resolution_idx}(about_acontours,end) = varargin{2};
      end

   case 'evolution rate'%
      varargout{1} = mean(p_mean_amplitudes{p_resolution_idx}(:,end));

   case 'durations'%, acontour index
      if p_duration_storage
         varargout{1} = p_durations{p_resolution_idx}(about_acontours,:);
      else
         varargout{1} = [];
      end

   case 'durations (str)'%, acontour index
      if p_duration_storage
         varargout{1} = num2str(p_durations{p_resolution_idx}(about_acontours,2:end), '%.3g, ');%the fake duration is not output
         varargout{1}([end-1 end]) = [];
      else
         varargout{1} = 'constant step';
      end

   case 'plot'%, acontour index
      if nargin < 2
         about_acontours = 1;
      end
      figure('Name', ['Evolution of acontour ' int2str(about_acontours)])
      subplot(2, 1, 1);
      if p_duration_storage
         plot(p_durations{p_resolution_idx}(about_acontours,2:end), 'LineWidth', 1.5)%the fake duration is not plotted
      else
         plot(ones(1, size(p_mean_amplitudes{p_resolution_idx},2)-1), 'LineWidth', 1.5)
      end
      set(get(gca, 'XLabel'), 'String', 'Iterations')
      set(get(gca, 'YLabel'), 'String', 'Durations')
      set(gca, 'XLim', [1, size(p_mean_amplitudes{p_resolution_idx},2)-1])
      subplot(2, 1, 2);
      plot(p_mean_amplitudes{p_resolution_idx}(about_acontours,2:end), 'LineWidth', 1.5)%the fake mean amplitude is not plotted
      set(get(gca, 'XLabel'), 'String', 'Iterations')
      set(get(gca, 'YLabel'), 'String', 'Mean amplitudes')
      set(gca, 'XLim', [1, size(p_mean_amplitudes{p_resolution_idx},2)-1])

   case 'clear', clear(mfilename)
   otherwise,    help(mfilename)
end
