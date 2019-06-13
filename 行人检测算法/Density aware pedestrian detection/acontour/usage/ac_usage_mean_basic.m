function ac_usage_mean_basic
%ac_usage_mean_basic: region competition of mean-based descriptors in grayscale
%   ac_usage_mean_basic implements segmentation of a grayscale image into object
%   and background. Both the object and the background descriptors are based on
%   the mean intensities within their respective regions.
%
%   A first window opens to select a file containing an image to be segmented.
%   It can be .mat file containing an image stored in a variable with any name
%   or it can be an image file 'imread' can read. If this window is cancelled,
%   then ac_usage_mean_basic exists. (Three synthetic test images stored in a
%   variable 'frame' are available in the directory 'usage' of the Active
%   Contour toolbox directory: files ac_frame1.mat, ac_frame2.mat, and
%   ac_frame3.mat.) Then, the gi_shape interface opens to enter an initial
%   active contour. If no active contour is entered, then ac_usage_mean_basic
%   exists.
%
%   The energy and velocity amplitude functions are declared as subfunctions of
%   ac_usage_mean_basic. It has been done to make ac_usage_mean_basic
%   self-contained for presentation purposes. However, these functions can be
%   declared as normal functions.
%
%See also gi_shape, acontour, imread.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 5, 2006

   title = 'Mean in grayscale (basic)';

   %%parameters
   %active contour
   segm_prm.iterations        = 200;

   %interface
   interface_prm.acontour     = @gi_acontour;
   interface_prm.interruption = @gi_acontour;

   %%data
   [filename, pathname] = uigetfile('*.*', 'Image to be segmented');
   if filename == 0, return, end
   if strcmp(filename((end-3):end), '.mat')
      load([pathname filesep filename])
      if ~exist('frame', 'var')%the file must contain a variable 'frame'.
         disp([mfilename ': ' filename ' contains no variable ''' frame ''''])
         return
      end
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
   acontour = gi_shape(frame, 'forced closed', 'forced positive', 'forced spline');
   if isempty(acontour), return, end

   %display
   gi_acontour('initialization', title, frame, acontour)
   drawnow

   %%segmentation process
   [segm_context, algo_context] = ac_segmentation(...
      frame, acontour, @s_energy, @s_amplitude, ...
      segm_prm, [], interface_prm);

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

   mean_of_object     = segm_context.mean_of_object;
   mean_of_background = segm_context.mean_of_background;

   frame_at_samples = interp2(user_data, samples(2,:), samples(1,:));

   amplitude = (mean_of_object^2 - mean_of_background^2) - ...
      (2 * (mean_of_object - mean_of_background)) * frame_at_samples;
