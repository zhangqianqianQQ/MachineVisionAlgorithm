function clipped = ac_clipping(acontour, framesize)
%ac_clipping: clipping of an active contour
%   c = ac_clipping(a, f) clips an active contour, a, so that it fits in the
%   rectangle defined by the corners (1,1) and f. f can be either a 2x1 or a 1x2
%   matrix. Actually, the clipping only guarantees that the endpoints of the
%   active contour segments lie within the rectangle. The active contour, as a
%   curve, may go outside and back inside the rectangle.
%
%See also acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 22, 2006

clipped = [];

for subac_idx = 1:length(acontour)
   samples = ppval(acontour(subac_idx), ppbrk(acontour(subac_idx), 'breaks'));

   %this projection should be replaced with a real clipping (see also: ac_mask
   %and po_isocontour). a po_clipping function could also be written
   samples(samples < 1) = 1;
   samples(1, samples(1,:) > framesize(1)) = framesize(1);
   samples(2, samples(2,:) > framesize(2)) = framesize(2);

   %several samples outside the frame domain may have been projected into
   %identical samples by the above clipping
   samples(:,sum(abs(diff(samples, 1, 2))) < 0.1) = [];

   if size(samples,2) > 3
      clipped = [clipped cscvn([samples samples(:,1)])];
   end
end
