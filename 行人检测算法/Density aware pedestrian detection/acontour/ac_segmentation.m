function [segm_context, algo_context] = ac_segmentation(...
   user_data, initial_segm_context, energy_function, velocity_amplitude, ...
   o_segmentation_prm, o_acontour_prm, o_interface)
%ac_segmentation: segmentation of a (set of) frame(s) by a (set of) active
%                 contour(s)
%   [s, a] = ac_segmentation(d, i, e, v, o_s, o_a, o_i) computes the
%   segmentation of some data, d, defined by the minimum of an energy, e,
%   leading to an active contour velocity of amplitude v in the local normal
%   direction. The initial segmentation is given by a segmentation context, i.
%   Segmentation can be performed with a "multi-resolution" or a
%   "multi-resolution"/multi-scale approach. Multi-resolution refers to the
%   active contour resolution while multi-scale refers to the data to be
%   segmented. Starting with the initial segmentation, the active contour(s),
%   composed of curve segments defined according to the first resolution, evolve
%   until convergence, working on the original data or the data at the coarser
%   scale if multi-scale parameters have been specified. The final segmentation
%   is used as the initial segmentation for the next "active contour
%   resolution/data scale" stage (or same original scale if not in a multi-scale
%   context). The final segmentation is obtained with the last resolution and
%   the original data.
%
%   d can be an image (grayscale, color, or more generally a WxHxT matrix) or
%   several images packed together in a single WxHxU matrix, or a cell array of
%   images, or a structure (normally containing images and other data). If it is
%   a structure, it must contain at least a field 'framesize' equal to [W H].
%   ac_segmentation passes d to the functions e and v.
%
%   i can be an active contour, a cell array of active contours, or a structure
%   containing at least either a field 'acontour' (which contains an active
%   contour) or a field 'acontours' (which contains a cell array of active
%   contours). Note that no validity check is performed on the active contours
%   (see ac_validity).
%
%   e is a handle to a function which computes the energy of a segmentation and
%   has the following arguments:
%   [n, o_g] = e(c, l, d)
%   where c is a segmentation context, l is an algorithmic context, and d is the
%   data passed to ac_segmentation. Whichever form was used to specify the
%   initial segmentation i, c is a structure containing a field 'acontour' or
%   'acontours' whether there is one or several active contours, respectively.
%   If segmentation is performed with a multi-scale approach, then c also
%   contains a field 'scaled_data' containing the data d scaled to the current
%   level (see argument o_s below). In this case, d is probably obsolete
%   throughout the evolution process.
%   l is a structure with the fields resolution, iteration, overall_iteration,
%   and acontour_index. The first 3 fields are current values: the current
%   active contour resolution, the number of iterations so far for the current
%   resolution, and the total number of iterations so far across all
%   resolutions, respectively. The last field is always equal to zero if there
%   is only one active contour. Otherwise, it is equal to the active contour
%   index (ranging from 1 to the number of active contours) being processed. It
%   has a meaning for the velocity amplitude function only since the energy is
%   global for the segmentation, whether it is defined by one or more active
%   contours.
%   n is the energy of the segmentation context c.
%   o_g is either the empty array or a structure whose fields are copied by
%   ac_segmentation to the segmentation context c before calling the velocity
%   amplitude function v (see below). (This implicitly means that, in a given
%   evolution loop, the energy function is called before the velocity amplitude
%   function.) These fields are typically global features computed within each
%   active contour mask (e.g., the mean intensity of the image being segmented).
%   Therefore, function e certainly contains some code similar to:
%      if nargout > 1
%         o_g = [];
%      end
%   or
%      if nargout > 1
%         o_g.feature_1 = ...;
%         o_g.feature_2 = ...;
%         ...
%      end
%
%   v is a handle to a function which computes the velocity amplitude of an
%   active contour in the direction of the local normal, as determined according
%   to, e.g., the shape gradient of the energy. It has the following arguments:
%   m = v(p, c, l, d)
%   where p contains the samples of the current active contour in a 2xN matrix
%   (see the Polygon toolbox for the interpretation of coordinates). In other
%   words, p is a sampling of c.acontour if there is only one active contour or
%   c.acontours{l.acontour_index} if there are several active contours.
%   c is either equal to the argument of the same name passed to function e, or
%   it contains additional fields 'feature_1', 'feature_2'...
%   m is a 1xN matrix of the velocity amplitudes at each sample.
%
%   The parameters used by ac_segmentation have been separated into 3 sets: o_s
%   is a structure of segmentation parameters, o_a is a structure of active
%   contour parameters, and o_i is a structure of interface parameters.
%
%   o_s can contain the following fields:
%      - 'it' or 'iteration' or 'iterations' or 'MaxIter': the maximum number of
%         iterations per resolution. By default, this field is taken equal to
%         repmat(5, 1, length(o_s.resolutions)) where 'o_s.resolutions' is
%         described below.
%      - 'overall_it' or 'overall_iteration' or 'overall_iterations' or
%         'overall_MaxIter': the maximum cumulated number of iterations across
%         all resolutions. By default, this field is taken equal to
%         sum(iterations).
%      - 'res' or 'resolution' or 'resolutions': a 1xN matrix of active contour
%         resolutions for a "multi-resolution" approach. Each resolution can be
%         positive or negative. If negative, it must be an integer and it
%         represents the opposite of the number of samples per active contour.
%         If positive, it can be real and it represents the distance in pixel
%         between the active contour samples (see ac_resampling). By default,
%         this field is taken equal to approximately (W+H)/30.
%         Note that this field can be modified if the segmentation is performed
%         with a multi-scale approach (see below).
%      - 'pyramid' or 'pyramid_function': a handle to a function which scales
%         the data to the current scale, or the empty array if no multi-scale is
%         requested. The function has the following arguments:
%         [t, f] = pyramid(d, z)
%         where z is the requested level, greater or equal to zero. If z is
%         equal to zero, t should be equal to d. Otherwise, t should be a
%         version of d scaled down z^th times. (This implicitly means that t
%         should have the same form as d (see above). However, if t is a
%         structure, it does not have to contain a field 'framesize'.) f is the
%         new framesize: [scaled_W scaled_H]. By default, this field is taken
%         equal to the empty array.
%      - 'level' or 'levels' or 'pyramid_level' or 'pyramid_levels': number of
%         levels for the multi-scale approach. If 'pyramid' is empty, this field
%         is ignored. Otherwise, it corresponds to the number of requested scale
%         levels, not including the original data (level 0). For example, if
%         'level' is equal to 1, there will be 1 level coarser than the original
%         data. If this field is not present, it is taken equal to the number of
%         resolutions minus one.
%         If then 'level' is less or equal to zero, the empty array is assigned
%         to 'pyramid'. Otherwise, it is checked that the number of resolutions
%         is equal to 'level'+1 (one resolution per level plus the last one
%         resolution for the original data). If not, in particular if only one
%         resolution was specified, the last resolution is repeated 'level'+1
%         times and the resulting row array is divided term by term by [q^level
%         q^(level-1) ... q 1] to form the new list of resolutions, the last one
%         being equal to the last resolution originally specified. q was
%         heuristically chosen equal to 1.25.
%
%   o_a can contain the following fields:
%      - 'amp' 'amplitude' 'amplitudes': a 1xN matrix of the maximum velocity
%         amplitudes allowed in absolute value at each resolution. Each maximum
%         x is a real number positive, equal to zero, or negative. If positive,
%         the amplitude array m returned by function v for a given active
%         contour is first divided by its maximum in absolute value and then
%         multiplied by x. The resulting amplitude array is used to deform the
%         active contour. Its maximum displacement, inward or outward, is equal
%         to x pixels in the direction of the local normal. If equal to zero, m
%         is used as is to deform the active contour. If negative, m is first
%         divided by its maximum in absolute value and then an optimal factor is
%         searched for in the interval [0, -x]. Since the optimality criterion
%         is the minimum of energy, this procedure requires energy evaluations
%         in addition to the energy evaluation scheduled on time per evolution
%         loop. However, these additional calls of the energy function e only
%         require the output argument n.
%         By default, 'amplitudes' is the a heuristically-chosen, negative real
%         repeated length(o_s.resolutions) times. This real depends on the first
%         resolution.
%      - 'smoothing': a real between zero and one specifying the amount of
%         smoothing to apply to the velocity amplitude before the
%         above-mentioned amplitude normalization (although it was not
%         mentioned, for simplicity). If 'smoothing' is equal to zero, no
%         smoothing is performed. If it is equal to 1, the amplitude array m is
%         replaced with a linear approximation. By default, 'smoothing' is taken
%         equal to 0.3.
%         Note that a high resolution also plays a role of smoothing of the
%         active contours.
%
%   o_i can contain the following fields:
%      - 'acontour': a handle to a function displaying, textually or
%         graphically, the active contour evolution. By default, no display is
%         done.
%      - 'movie': a handle to a function generating a movie of the active
%         contour evolution. By default, no movie is generated.
%      - 'interruption': a handle to a function allowing to pause or stop the
%         evolution process. By default, the process cannot be stopped.
%      - 'ac_index' or 'ac_indices' or 'acontour_index' or 'acontour_indices':
%         an array of the indices of the active contours to display. The indices
%         range from 1 to the number of active contours. By default,
%         'ac_indices' is taken equal to [1 2 ... number of active contours].
%
%   s is the final segmentation context and 'a' is the final algorithmic
%   context. Compared to the description above, 'a' has an additional field
%   'status' containing a message about how the evolution stopped.
%
%   Note that the notions of object and background are interchangeable.
%   Depending on the initialization, what is considered to be the object might
%   end up segmenting the background.
%   It takes some iterations to detect that the energy has stabilized but the
%   evolution process should eventually stop.
%
%See also ac_validity, ac_resampling, acontour, polygon.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 5, 2006

   %reading of context
   if isstruct(user_data)
      framesize = user_data.framesize;
   else
      if iscell(user_data)
         framesize = size(user_data{1});
      else
         framesize = size(user_data);
      end
      framesize = framesize(1:2);
   end
   original_framesize = framesize;

   [segm_context, algo_context, acontours, ...
      multiple_acontour] = s_context(initial_segm_context);
   clear initial_segm_context

   %reading of parameters
   if nargin < 7
      o_interface = [];
   if nargin < 6
      o_acontour_prm = [];
   if nargin < 5
      o_segmentation_prm = [];
         end
      end
   end
   [resolutions, pyramid_computation, ...
      iteration_limits, iteration_LIMIT, ...
      amplitude_limits, amplitude_smoothing] = ...
      s_parameters(o_segmentation_prm, o_acontour_prm, framesize);
   clear o_segmentation_prm o_acontour_prm

   tasks = {'acontour', 'movie', 'interruption'};
   if isempty(o_interface)
      o_interface = cell2struct(repmat({@s_mute_interface}, 1, length(tasks)), tasks, 2);
   else
      absent_tasks = find(isfield(o_interface, tasks) == false);
      for task_idx = absent_tasks
         o_interface.(tasks{task_idx}) = @s_mute_interface;
      end
   end

   parameter_names = {'ac_index' 'ac_indices' 'acontour_index' 'acontour_indices'};
   which_name = find(isfield(o_interface, parameter_names));
   if isempty(which_name)
      o_interface.acontour_indices = 1:length(acontours);
   else
      o_interface.acontour_indices = o_interface.(parameter_names{which_name(1)});
   end

   %internal parameters
   width_of_energy_window = 15;
   convergence_slope      = 5e-4;

   %beginning of segmentation
   ac_energy('initialization', length(resolutions), width_of_energy_window, convergence_slope)
   ac_evolution('initialization', length(acontours), length(resolutions), amplitude_limits)

   before = now;%for computation time with intermediate times
   patience = true;
   something = true;
   %acontour_index at the last position so that samples and amplitude in the
   %innermost loop have the correct value for display. this list of indices also
   %allows to exclude empty acontours appearing during the evolution
   acontour_indices = [setdiff(1:length(acontours), o_interface.acontour_indices(1)), o_interface.acontour_indices(1)];
   resolution_scaling = 1;
   resolution_index = 1;
   overall_iteration = 1;

   while (resolution_index <= length(resolutions)) && ...
         (overall_iteration <= iteration_LIMIT) && ...
         something && patience
      resolution      = resolutions(resolution_index);
      iteration_limit = iteration_limits(resolution_index);
      amplitude_limit = amplitude_limits(resolution_index);

      if ~isempty(pyramid_computation)
         [segm_context.scaled_data, current_framesize] = pyramid_computation(user_data, length(resolutions) - resolution_index);
         resolution_scaling = mean((current_framesize - 1) ./ (framesize - 1));%to scale the acontours
         framesize = current_framesize;
         for acontour_index = acontour_indices
            for subac_idx = 1:length(acontours{acontour_index})
               acontour = fncmb(acontours{acontour_index}(subac_idx), '-', 1);
               acontour = fncmb(acontour, resolution_scaling);
               acontours{acontour_index}(subac_idx) = fncmb(acontour, '+', 1);
            end
         end
         resolution_scaling = mean((original_framesize - 1) ./ (framesize - 1));%for display (energy + evolution)
      end
      for acontour_index = acontour_indices
         acontours{acontour_index} = ac_resampling(acontours{acontour_index}, resolution, framesize);
      end

      ac_energy('new resolution')
      ac_evolution('new resolution')
      o_interface.acontour('new resolution', acontours{o_interface.acontour_indices(1)}, resolution, iteration_limit)
      algo_context.resolution = resolution;

      descending = true;
      iteration = 1;

      while descending && (iteration <= iteration_limit) && ...
            (overall_iteration <= iteration_LIMIT) && something
         patience = o_interface.interruption('patience');
         if patience == 0, break, end
         if patience < 0
            keyboard
         end

         if multiple_acontour
            segm_context.acontours = acontours;
         else
            segm_context.acontour = acontours{1};
         end
         algo_context.iteration = iteration;
         algo_context.overall_iteration = overall_iteration;

         [energy, global_prm] = energy_function(segm_context, algo_context, user_data);
         if ~isempty(global_prm)
            cells_of_fieldnames = fieldnames(global_prm);
            for fieldname_index = 1:length(cells_of_fieldnames)
               segm_context.(cells_of_fieldnames{fieldname_index}) = ...
                  global_prm.(cells_of_fieldnames{fieldname_index});
            end
         end

         if ac_energy('update', resolution_scaling^2 * energy, ac_evolution('evolution rate'))
            descending = false;
         else
            max_duration = 0;
            for acontour_index = acontour_indices
               acontour = acontours{acontour_index};
               if multiple_acontour
                  algo_context.acontour_index = acontour_index;
               end

               [samples, direction, amplitude, optimal_duration] = n_deformation(acontour, acontour_index, energy);
               acontours{acontour_index} = ac_deformation(acontour, [amplitude; amplitude] .* direction, framesize, resolution);
               %it is safe to re-assign acontours{acontour_index} since the
               %current segmentation is stored in segm_context.acontours

               ac_evolution('update', acontour_index, amplitude, optimal_duration)
               max_duration = max(optimal_duration, max_duration);
            end
            empty_contours = cellfun(@isempty, acontours);
            %setdiff resort in increasing order: acontour_index must be put at the end explicitly 
            acontour_indices = setdiff(acontour_indices, [find(empty_contours) o_interface.acontour_indices(1)]);
            if ~isempty(acontours{o_interface.acontour_indices(1)})
               acontour_indices = [acontour_indices o_interface.acontour_indices(1)];
            end
            something = any(~empty_contours);

            o_interface.acontour('evolution update', 1 + (samples - 1) * resolution_scaling, iteration, amplitude, ac_energy('Energies'))%display
            o_interface.movie('movie update', acontours(o_interface.acontour_indices), overall_iteration)

            descending = (max_duration > 0);
            iteration = iteration + 1;
            overall_iteration = overall_iteration + 1;
         end
      end

      if patience == 0
         convergence_msg = 'cancelled after ';
      elseif ~something
         convergence_msg = 'empty segm. after ';
      elseif descending
         convergence_msg = 'no conv. after ';
      else
         convergence_msg = '';
      end
      duration = now - before;
      disp(['res.' num2str(resolution) ': ' convergence_msg ...
         int2str(iteration - 1) ' evolution(s) - ' ...
         datestr(duration, 'HH') 'h ' ...
         datestr(duration, 'MM') 'm ' ...
         datestr(duration, 'SS.FFF') 's (cumulative)'])

      resolution_index = resolution_index + 1;
   end
   %end of segmentation

   %if the evolution has been stopped before level zero of the pyramid, the
   %acontours should be scaled back to level zero

   %writing of context
   if multiple_acontour
      segm_context.acontours = acontours;
   else
      segm_context.acontour = acontours{1};
   end
   if amplitude_limit > 0
      status = ['fixed step: ' num2str(amplitude_limit)];
   else
      status = ['steps: ' ac_evolution('durations (str)', 1)];
   end
   algo_context.resolution = resolution;
   algo_context.overall_iteration = overall_iteration - 1;
   algo_context.status = status;


      function [samples, direction, amplitude, optimal_duration] = n_deformation(acontour, acontour_index, energy)
         %framesize, resolution,
         %amplitude_limit, amplitude_smoothing,
         %energy_function, velocity_amplitude,
         %segm_context, algo_context, user_data

         [samples, normals] = ac_sampling(acontour, 'sn');
         if iscell(samples)
            samples = [samples{:}];
            normals = [normals{:}];
         end
         %a resampling with clipping does not guarantee that
         %a subsequent sampling respects the following property
         %(it should approximately but not strictly)
         samples(samples < 1) = 1;
         samples(1, samples(1,:) > framesize(1)) = framesize(1);
         samples(2, samples(2,:) > framesize(2)) = framesize(2);

         direction = normals;
         amplitude = velocity_amplitude(samples, segm_context, algo_context, user_data);
         [amplitude, maximum_amplitude] = n_reshaping(samples, amplitude);
         if maximum_amplitude > 0
            optimal_duration = n_duration(acontour, amplitude, maximum_amplitude, ...
               direction, ac_evolution('durations', acontour_index), energy);
            amplitude = optimal_duration * amplitude;
         else
            optimal_duration = 0;
         end
      end


      function [reshaped, maximum] = n_reshaping(samples, amplitude)
         %amplitude_smoothing, framesize

         reshaped = amplitude;

         %slowing down of samples on the edges
         edge_samples = find((samples(1,:) < 2) | (samples(1,:) > framesize(1) - 1));
         edge_samples = unique([edge_samples, find((samples(2,:) < 2) | (samples(2,:) > framesize(2) - 1))]);
         reshaped(edge_samples) = 0.1 * reshaped(edge_samples);

         %smoothing
         if amplitude_smoothing ~= 1
            reshaped = csaps(0:length(reshaped), [reshaped reshaped(1)], amplitude_smoothing);
            reshaped = ppval(reshaped, ppbrk(reshaped, 'breaks'));
            reshaped(end) = [];
         end

         %normalization
         maximum = max(abs(reshaped));
         if maximum > 0
            reshaped = reshaped / maximum;
         end
      end


      function optimal_duration = n_duration(acontour, ...
         amplitude, maximum_amplitude, direction, previous_steps, energy)
         %framesize, resolution, amplitude_limit,
         %energy_function, segm_context, algo_context, user_data

         %fast or full computation
         if amplitude_limit >= 0
            if amplitude_limit > 0
               optimal_duration = amplitude_limit;
            else
               optimal_duration = maximum_amplitude;
            end
            return
         end
         current_limit = - amplitude_limit;

         %internal parameters
         increment_limit  = 0.1;%in pixels
         intervals        = 5;
         allowed_increase = 1.7;%to allow a bigger step than the recent ones
         ad_hoc           = 5;

         %list of energy discretization steps
         accounting_since = max(1, length(previous_steps) - floor(min(framesize) / (ad_hoc * mean(previous_steps))));
         current_limit  = min(current_limit, allowed_increase * mean(previous_steps(accounting_since:end)));
         increment = max((current_limit - increment_limit) / intervals, increment_limit);
         list_of_steps = increment_limit:increment:current_limit;

         %energy discretization
         current_acontour = acontour;
         energies = [energy zeros(size(list_of_steps))];
         energy_index = 1;
         for step = list_of_steps
            trial = step * amplitude;
            deformation = direction .* [trial; trial];
            try
               acontour = ac_deformation(current_acontour, deformation, framesize, resolution);
               if isempty(acontour)
                  break
               end
            catch
               break
            end

            if algo_context.acontour_index == 0
               segm_context.acontour = acontour;
            else
               segm_context.acontours{algo_context.acontour_index} = acontour;
            end
            energy_index = energy_index + 1;
            energies(energy_index) = energy_function(segm_context, algo_context, user_data);
         end

         %polynomial fit and minimization
         if energy_index == 1
            optimal_duration = 0;
         else
            energies = energies(1:energy_index);
            list_of_steps = [0 list_of_steps(1:(energy_index-1))];
            energies = (energies - mean(energies)) / std(energies);

            if energy_index == 2
               degree = 1;
            elseif energy_index < 5
               degree = 2;
            else
               degree = 4;
            end
            fit = polyfit(list_of_steps, energies, degree);
            options = optimset('Display', 'off', 'TolX', 0.1 * increment_limit);
            optimal_duration = fminbnd(@(s) polyval(fit,s), 0, list_of_steps(end), options);
         end
      end
end



function [segm_context, algo_context, acontours, multiple_acontour] = ...
   s_context(initial_segm_context)

   if iscell(initial_segm_context)
      segm_context.acontours = initial_segm_context;
   elseif isfield(initial_segm_context, 'form')
      segm_context.acontour = initial_segm_context;
   else
      segm_context = initial_segm_context;
   end

   if isfield(segm_context, 'acontour')
      acontours = {segm_context.acontour};
      multiple_acontour = false;
   else
      acontours = segm_context.acontours;
      multiple_acontour = true;
   end

   algo_context.acontour_index = 0;
end



function [resolutions, pyramid_computation, ...
   iteration_limits, iteration_LIMIT, ...
   amplitude_limits, amplitude_smoothing] = ...
   s_parameters(segmentation_prm, acontour_prm, framesize)

   parameter_names = {'res' 'resolution' 'resolutions'};
   which_name = find(isfield(segmentation_prm, parameter_names));
   if isempty(which_name)
      resolutions = floor(mean(framesize) / 15);
   else
      resolutions = segmentation_prm.(parameter_names{which_name(1)});
   end

   parameter_names = {'pyramid' 'pyramid_function'};
   which_name = find(isfield(segmentation_prm, parameter_names));
   if isempty(which_name)
      pyramid_computation = [];
   else
      pyramid_computation = segmentation_prm.(parameter_names{which_name(1)});
   end

   if ~isempty(pyramid_computation)
      parameter_names = {'level' 'levels' 'pyramid_level' 'pyramid_levels'};
      which_name = find(isfield(segmentation_prm, parameter_names));
      if isempty(which_name)
         pyramid_levels = length(resolutions) - 1;
      else
         pyramid_levels = segmentation_prm.(parameter_names{which_name(1)});
      end
      if pyramid_levels < 1
         pyramid_computation = [];
      elseif length(resolutions) ~= pyramid_levels + 1
         resolution_scaling = ones(1, pyramid_levels+1);
         for resolution_index = pyramid_levels:-1:1
            resolution_scaling(1:resolution_index) = 1.25 * resolution_scaling(1:resolution_index);
            %it should be a factor of 2 but 1.25 might be better in practice (to be checked)
         end
         resolutions = repmat(resolutions(end), 1, pyramid_levels+1) ./ resolution_scaling;
         resolutions = max(resolutions, 2);
      end
   end

   parameter_names = {'it' 'iteration' 'iterations' 'MaxIter'};
   which_name = find(isfield(segmentation_prm, parameter_names));
   if isempty(which_name)
      iteration_limits = 5;
   else
      iteration_limits = segmentation_prm.(parameter_names{which_name(1)});
   end
   if length(iteration_limits) ~= length(resolutions)
      iteration_limits = repmat(iteration_limits(1), 1, length(resolutions));
   end

   parameter_names = {'overall_it' 'overall_iteration' 'overall_iterations' 'overall_MaxIter'};
   which_name = find(isfield(segmentation_prm, parameter_names));
   if isempty(which_name)
      iteration_LIMIT = sum(iteration_limits);
   else
      iteration_LIMIT = segmentation_prm.(parameter_names{which_name(1)});
   end

   parameter_names = {'amp' 'amplitude' 'amplitudes'};
   which_name = find(isfield(acontour_prm, parameter_names));
   if isempty(which_name)
      amplitude_limits = - abs(resolutions(1)) / 2.5;
   else
      amplitude_limits = acontour_prm.(parameter_names{which_name(1)});      
   end
   if length(amplitude_limits) ~= length(resolutions)
      amplitude_limits = repmat(amplitude_limits(1), 1, length(resolutions));
   end

   if isfield(acontour_prm, 'smoothing')
      amplitude_smoothing = 1 - acontour_prm.smoothing;
   else
      amplitude_smoothing = 0.7;
   end
end



function o_patience = s_mute_interface(task, varargin)
   if strcmp(task, 'patience'), o_patience = true; end
end
