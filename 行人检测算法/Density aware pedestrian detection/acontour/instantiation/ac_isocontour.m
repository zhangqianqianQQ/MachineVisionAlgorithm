function isocontour = ac_isocontour(frame, level, o_main_orientation, o_resolution, o_padding, o_filter, o_clipping)
%ac_isocontour: instantiation of an active contour describing a level set of a frame
%   a = ac_isocontour(f, l, o_o, o_r, o_d, o_i, o_c) computes an active contour
%   describing the level set l of frame f. Such a level set can be composed of
%   several single contours, possibly nested if a connected set of the set {x |
%   f(x)<l} (or equivalently the set {x | f(x)>l}) has holes. a is either an
%   empty array or an active contour derived from the polygon(s) computed by
%   po_isocontour.
%
%   o_o specifies the orientation of the single contours that are not nested in
%   other single contours. If o_o is positive or equal to zero, these contours
%   are oriented counterclockwise. Nested contours get the orientation
%   (-1)^(nesting_level+offset) where offset is equal to zero if o_o is positive
%   or equal to zero, and equal to 1 otherwise. By default, o_o is taken equal
%   to 1.
%
%   o_r is the resolution of the active contour. If positive, the length of each
%   active contour segment is approximately of o_r pixels. If equal to zero, the
%   active contour is derived from the polygon(s) computed by po_isocontour
%   without control of the resolution. If negative, the active contour is
%   composed of abs(o_r) segments (or, equivalently, samples). By default, o_r
%   is taken equal to approximately (w+h)/30 where w and h are the width and
%   height of f, respectively.
%
%   o_d is the padding to be performed (uniformly around the frame) before
%   extracting the level set. It is a cell array containing 2 integers. The
%   first one is the padding width in pixels and the second one is the padding
%   value. No padding is performed by default or if isempty(o_d) is true.
%
%   o_i is a 2-D convolution filter (normally, a smoothing kernel) to be applied
%   after the (optional) padding. If isempty(o_d) is true, no padding is
%   performed before filtering. Otherwise, the padding size in o_d is replaced
%   by the halfsize in both directions (rounded to the nearest lower integers)
%   of o_i. The top and bottom paddings are equal; so are the left and right
%   paddings; however, the top and left paddings are different if the filter is
%   not square. No filtering is performed by default or if isempty(o_i) is true.
%
%   o_c is a boolean indicating whether the active contour must be clipped to
%   the frame size. Clipping does not guarantee that the active contour entirely
%   lies within the frame domain. It only guarantees that the endpoints of its
%   segments belong to this domain (actually, it seems that this could be
%   violated: to be checked).
%
%   The level set extraction is performed by contourc(f, [l l]) in
%   po_isocontour. The open polygons are discarded. To ensure that all of the
%   polygons computed by contourc are closed, padding can be used.
%
%See also po_isocontour, po_orientation, ac_clipping, ac_resampling, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 15, 2006

if nargin < 7
   o_clipping = true;
if nargin < 6
   o_filter = [];
if nargin < 5
   o_padding = [];
if nargin < 4
   o_resolution = floor(mean(size(frame)) / 15);%from ac_segmentation
if nargin < 3
   o_main_orientation = 1;
            end
         end
      end
   end
end

isocontour = [];

isopolygon = po_isocontour(frame, level, o_main_orientation, o_padding, o_filter);

if ~isempty(isopolygon)
   if iscell(isopolygon)
      isocontour = cellfun(@cscvn, isopolygon);
   else
      isocontour = cscvn(isopolygon);
   end

   if o_resolution ~= 0
      if o_clipping
         isocontour = ac_resampling(isocontour, o_resolution, size(frame));
      else
         isocontour = ac_resampling(isocontour, o_resolution);
      end
   elseif o_clipping
      isocontour = ac_clipping(isocontour, size(frame));
   end
end
