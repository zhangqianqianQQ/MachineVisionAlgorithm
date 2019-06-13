function ac_usage_mean
%ac_usage_mean: region competition of mean-based descriptors in grayscale
%   ac_usage_mean implements segmentation of a grayscale image into object and
%   background. Both the object and the background descriptors are based on the
%   mean intensities within their respective regions. Segmentation is performed
%   using a multi-scale approach with 3 levels.
%
%   A first window opens to select a file containing an image to be segmented.
%   It can be .mat file containing an image stored in a variable with any name
%   or it can be an image file 'imread' can read. If this window is cancelled,
%   then ac_usage_mean exists. (Three synthetic test images stored in a variable
%   'frame' are available in the directory 'usage' of the Active Contour toolbox
%   directory: files ac_frame1.mat, ac_frame2.mat, and ac_frame3.mat.) Then, a
%   list selection dialog box opens. It offers 4 possible active contour
%   initializations: (1) manual = graphical initialization with gi_shape (only
%   single active contours can be entered this way), (2) islands = a blind,
%   "uniform", random initialization (this option is time consuming if the image
%   to be segmented is large.), (3) circles = a blind, "uniform", deterministic
%   initialization, and (4) file = a .mat file containing an active contour
%   stored in a variable with any name. If no active contour is entered, then
%   ac_usage_mean exists.
%
%   The energy and velocity amplitude functions are declared as subfunctions of
%   ac_usage_mean. It has been done to make ac_usage_mean self-contained for
%   presentation purposes. However, these functions can be declared as normal
%   functions.
%
%See also gi_shape, acontour, imread.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 5, 2006

   title = 'Mean in grayscale';

   %%parameters
   %active contour
   segm_prm.resolutions       = [4 8 5];
   segm_prm.pyramid           = @s_laplacian_pyramid;
   segm_prm.iterations        = 200;

   acontour_prm.amplitudes    = -10;

   %interface
   interface_prm.acontour     = @gi_acontour;
   interface_prm.interruption = @gi_acontour;

   %%data
   [filename, pathname] = uigetfile('*.*', 'Image to be segmented');
   if filename == 0, return, end
   if strcmp(filename((end-3):end), '.mat')
      content = load([pathname filesep filename]);
      variable_name = fieldnames(content);
      frame = content.(variable_name{1});
   else
      frame = double(imread([pathname filesep filename]));
   end
   if size(frame, 3) > 1
      %energy and velocity amplitude are written for grayscale images, not for
      %color.
      frame = frame(:,:,1);
   end

   %%initial segmentation
   %instantiation
   [selection_idx, valid_selection] = listdlg('Name', 'Initialization', ...
      'ListString', {'manual', 'islands', 'circles', 'file'}, 'SelectionMode', 'single');
   if valid_selection == 0, return, end
   switch selection_idx
      case 1
         acontour = gi_shape(frame, 'forced closed', 'forced positive', 'forced spline');

      case 2
         random = rand(size(frame));
         acontour = ac_isocontour(random, 1.05 * mean(random(:)), 1, ...
            segm_prm.resolutions(1), {1 0}, fspecial('gaussian', 6, 2));
         clear random

      case 3
         seeds = zeros(size(frame));
         interval = round(size(frame) / 8);
         first = ceil(interval / 2) + 1;
         seeds(first(1):interval(1):end,first(2):interval(2):end) = 1;
         distance = bwdist(seeds);
         acontour = ac_isocontour(distance, min(interval)/3, 1, ...
            segm_prm.resolutions(1), {1 max(distance(:))});
         clear seeds interval first distance

      case 4
         [filename, pathname] = uigetfile('*.*', 'File of initial active contour');
         if filename == 0, return, end
         content = load([pathname filesep filename]);
         variable_name = fieldnames(content);
         acontour = content.(variable_name{1});
   end
   if isempty(acontour), return, end

   %display
   gi_acontour('initialization', title, frame, acontour)
   drawnow

   %%segmentation process
   [segm_context, algo_context] = ac_segmentation(...
      frame, acontour, @s_energy, @s_amplitude, ...
      segm_prm, acontour_prm, interface_prm);

   %%final segmentation
   algo_context
   segm_context
   gi_acontour('result', frame, acontour, segm_context.acontour)



function [energy, o_global_prm] = s_energy(segm_context, algo_context, user_data)
%s_energy computes the current segmentation energy as:
%e = \int_maskofobject (f(x) - meanofobject)^2 dx ...
%  + \int_maskofbackground (f(x) - meanofbackground)^2 dx
%where f is the frame to be segmented.
%meanofobject and meanofbackground are auxiliary variables also involved in the
%velocity amplitude expression.

   %in a multiscale approach (as opposed to monoscale-multiresolution and
   %monoscale-monoresolution), the scaled data are passed as the field
   %scaled_data of segm_context (user_data always contains the original data).
   %the following is a trick to keep on using the name user_data in the
   %subsequent computation.
   if isfield(segm_context, 'scaled_data')
      user_data = segm_context.scaled_data;
   end

   mask_of_object = ac_mask(segm_context.acontour, size(user_data));
   area_of_object = sum(mask_of_object(:));
   mean_of_object = sum(sum(user_data .* mask_of_object)) / area_of_object;

   mean_of_background = sum(sum(user_data .* (1 - mask_of_object))) / (numel(user_data) - area_of_object);

   %auxiliary variables useful for the computation of the velocity amplitude, to
   %be passed to the velocity amplitude function by ac_segmentation as new
   %fields of segm_context.
   if nargout > 1
      o_global_prm.mean_of_object     = mean_of_object;
      o_global_prm.mean_of_background = mean_of_background;
   end

   energy = sum(sum((user_data - mean_of_background - ...
      (mean_of_object - mean_of_background) * mask_of_object).^2));



function amplitude = s_amplitude(samples, segm_context, algo_context, user_data)
%s_amplitude computes the discrete active contour velocity amplitude as:
%a(sample) = (f(sample) - meanofobject)^2 - (f(sample) - meanofbackground)^2
%meanofobject and meanofbackground come from s_energy.

   %see note on scaled data in s_energy.
   if isfield(segm_context, 'scaled_data')
      user_data = segm_context.scaled_data;
   end

   mean_of_object     = segm_context.mean_of_object;
   mean_of_background = segm_context.mean_of_background;

   frame_at_samples = interp2(user_data, samples(2,:), samples(1,:));

   amplitude = (mean_of_object^2 - mean_of_background^2) - ...
      (2 * (mean_of_object - mean_of_background)) * frame_at_samples;



function [smaller, framesize] = s_laplacian_pyramid(frame, level)
%s_laplacian_pyramid computes the scale 'level' of frame 'frame' as described
%in: Peter J. Burt and Edward H. Adelson, "The laplacian pyramid as a compact
%image code", IEEE Transactions on Communications, Vol. COM-3l, No. 4, April
%1983.
%if level is equal to zero, the original frame is returned. otherwise the
%processing filtering+subsampling_by_2 is repeated 'level' times. framesize is
%the size of the output of the last processing, or size(frame) if level is equal
%to zero.

   persistent filter

   if isempty(filter)
      filter = zeros(1,5);
      filter(3) = 0.6;
      filter([2 4]) = 0.25;
      filter([1 5]) = 0.25 - filter(3)/2;
   end

   smaller = frame;

   for current_level = 1:level
      if min(size(smaller)) < 100
         break
      end
      smaller = conv2(smaller, filter, 'same');
      smaller = conv2(smaller, transpose(filter), 'same');
      smaller(1:2:end,:) = [];
      smaller(:,1:2:end) = [];
   end

   framesize = size(smaller);
