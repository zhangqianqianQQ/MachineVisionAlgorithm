function ac_usage_minlength
%ac_usage_minlength: curvature flow
%   ac_usage_minlength implements the curvature flow which minimizes the
%   length of the active contour. It can be linearly combined with a
%   segmentation energy to smooth the active contour when the image to be
%   segmented is noisy.
%
%   A first window opens to allow to select a .mat file containing at least an
%   initial active contour stored in a variable 'acontour'. (An initial active
%   contour stored in a variable 'acontour' is available in the directory
%   'usage' of the Active Contour toolbox directory: file ac_contour.mat.) If
%   this window is cancelled, then the gi_shape interface opens to enter an
%   initial active contour. If no active contour is entered, then
%   ac_usage_minlength exists.
%
%   The energy and velocity amplitude functions are declared as subfunctions of
%   ac_usage_minlength. It has been done to make ac_usage_minlength
%   self-contained for presentation purposes. However, these functions can be
%   declared as normal functions.
%
%See also gi_shape, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 5, 2006

   title = 'Min curvature flow';

   %%parameters
   %active contour
   segm_prm.iterations        = 1000;

   acontour_prm.amplitudes    = 1;

   %interface
   interface_prm.acontour     = @gi_acontour;
   interface_prm.interruption = @gi_acontour;
   interface_prm.movie        = @gi_acontour;

   %%initial contour
   %instantiation
   [filename, pathname] = uigetfile('*.*', 'Initial contour');
   if filename == 0
      acontour = gi_shape(zeros([100 100]), 'forced closed', 'forced positive', 'forced spline');
      if isempty(acontour)
         return
      end
   else
      load([pathname filesep filename])
      if ~exist('acontour', 'var')%the file must contain a variable 'acontour'.
         disp([mfilename ': ' filename ' contains no variable ''' acontour ''''])
         return
      end
   end
   if ~ac_validity(acontour)
      disp([mfilename ': variable ''' acontour ''' does not contain a valid active contour'])
      return
   end

   %display
   gi_acontour('initialization', title, zeros([100 100]), acontour, 'undecided', 3)
   drawnow

   %%segmentation process
   [segm_context, algo_context] = ac_segmentation(...
      zeros([100 100]), acontour, @s_energy, @s_amplitude, ...
      segm_prm, acontour_prm, interface_prm);

   %%final segmentation
   algo_context
   segm_context
   gi_acontour('result', zeros([100 100]), acontour, segm_context.acontour)



function [energy, o_global_prm] = s_energy(segm_context, algo_context, user_data)
%s_energy computes the current segmentation energy as:
%e = length of acontour.

   energy = ac_length(segm_context.acontour);

   %there are no auxiliary variables useful for the computation of the velocity
   %amplitude
   if nargout > 1
      o_global_prm = [];
   end



function amplitude = s_amplitude(samples, segm_context, algo_context, user_data)
%s_amplitude computes the discrete active contour velocity amplitude as:
%a(sample) = curvature of the active contour(sample).
%since the active contour shrinks, turning into a circle, and then disappears,
%the velocity is artificially set to zero if the active contour area is less
%than 1% of the background area.

   if ac_area(segm_context.acontour) < 0.01 * prod([100 100])
      amplitude = zeros(1,size(samples,2));
   else
      amplitude = ac_sampling(segm_context.acontour, 'c');
   end
