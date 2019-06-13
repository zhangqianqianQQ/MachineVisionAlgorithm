function varargout = ac_energy(task, varargin)
%ac_energy: storage and plot of the energy of a set of active contours and
%           evaluation of a stopping criterion
%   o_e = ac_energy(t, a) performs a task, t, related to the energy of a set of
%   active contours according to some arguments, a. t is a string among
%   'initialization', 'new resolution', 'update', 'Energies', 'energies',
%   'rates', 'slopes', 'plot', and 'clear'. The tasks 'initialization', 'new
%   resolution', and 'update' are meant to be called by ac_segmentation only.
%   The tasks energies, rates, and slopes allow to check intermediate
%   computations and are not yet described here.
%
%   e = ac_energy('Energies') returns the energies computed during the evolution
%   by the function passed to ac_segmentation as the argument energy_function.
%
%   ac_energy('plot') creates a figure and plots the energies as returned by the
%   Energies task.
%
%   ac_energy('clear') clears the persistent variables of ac_energy. Most of the
%   tasks produce an error if called afterward.
%
%   Note:
%   The other tasks should be documented in a later release.
%
%See also ac_segmentation, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 21, 2006

persistent p_resolution_index p_width_of_window p_convergence_slope ...
   p_indices_of_iterations p_sum_of_indices p_difference_of_sums ...
   p_ENERGIES p_energies p_evolution_rate ...
   p_valid_past p_slopes p_valid_slope p_index_of_valid_slope
%{resolution}(iteration)
%
%p_ENERGIES: list of energies for all resolutions
%p_energies: list of normalized energies for all resolutions

switch task
   case 'initialization'%, number of resolutions, width of energy window, convergence slope
      p_resolution_index = 0;

      p_width_of_window   = varargin{2};
      p_convergence_slope = varargin{3};

      p_indices_of_iterations = 1:p_width_of_window;
      p_sum_of_indices        = ((p_width_of_window + 1) * p_width_of_window) / 2;
      sum_of_squared_indices  = ((2 * p_width_of_window + 1) * p_sum_of_indices) / 3;
      p_difference_of_sums    = sum_of_squared_indices - p_sum_of_indices^2 / p_width_of_window;

      p_ENERGIES       = cell(varargin{1},1);
      p_energies       = cell(varargin{1},1);
      p_evolution_rate = cell(varargin{1},1);
      p_slopes         = cell(varargin{1},1);

   case 'new resolution'%
      p_resolution_index = p_resolution_index + 1;

      p_valid_past           = 0;
      p_index_of_valid_slope = 0;

   case 'update'%, energy, evolution rate
      iteration = length(p_ENERGIES{p_resolution_index}) + 1;
      p_ENERGIES{p_resolution_index}(iteration) = varargin{1};

      if iteration == 1
         p_energies{p_resolution_index}(iteration) = varargin{1};
      else
         if varargin{2} < 0.1
            p_evolution_rate{p_resolution_index}(iteration - 1) = 1;
         else
            p_evolution_rate{p_resolution_index}(iteration - 1) = varargin{2};
         end
         change_in_energy = varargin{1} - p_ENERGIES{p_resolution_index}(iteration - 1);
         p_energies{p_resolution_index}(iteration) = p_energies{p_resolution_index}(iteration - 1) ...
            + change_in_energy / p_evolution_rate{p_resolution_index}(iteration - 1);
      end

      p_valid_past = p_valid_past + 1;

      if p_valid_past >= p_width_of_window
         recent_energies = p_energies{p_resolution_index}(end - p_width_of_window + 1:end);

         p_slopes{p_resolution_index}(iteration) = (sum(p_indices_of_iterations .* recent_energies) - ...
            p_sum_of_indices * sum(recent_energies) / p_width_of_window) / p_difference_of_sums;
         if p_index_of_valid_slope == 0
            p_index_of_valid_slope = iteration;
            p_valid_slope = abs(p_slopes{p_resolution_index}(iteration));
            if p_valid_slope == 0
               p_valid_slope = 1;
            end
         end

         if (abs(p_slopes{p_resolution_index}(iteration)) >= p_convergence_slope) || ...
               (p_index_of_valid_slope ~= iteration)
            p_slopes{p_resolution_index}(iteration) = p_slopes{p_resolution_index}(iteration) / p_valid_slope;
         end

         if abs(p_slopes{p_resolution_index}(iteration)) < p_convergence_slope
            varargout{1} = true;
         else
            oscillations = sum(diff(recent_energies) > 0);
            if (oscillations >= (p_width_of_window / 2) - (p_width_of_window / 12)) && ...
               (oscillations <= (p_width_of_window / 2) + (p_width_of_window / 12))
               varargout{1} = true;
            else
               varargout{1} = false;
            end
         end
      else
         p_slopes{p_resolution_index}(iteration) = NaN;
         varargout{1} = false;
      end

   case 'Energies', varargout{1} = [p_ENERGIES{:}];
   case 'energies', varargout{1} = [p_energies{:}];
   case 'rates',    varargout{1} = [p_evolution_rate{:}];
   case 'slopes',   varargout{1} = [p_slopes{:}];

   case 'plot'
      figure('Name', 'Energy')
      plot([p_ENERGIES{:}], 'LineWidth', 1.5)
      set(get(gca, 'XLabel'), 'String', 'Iterations')
      set(get(gca, 'YLabel'), 'String', 'Energy')
      set(gca, 'XLim', [1 length([p_ENERGIES{:}])])

   case 'clear', clear(mfilename)
   otherwise,    help(mfilename)
end
