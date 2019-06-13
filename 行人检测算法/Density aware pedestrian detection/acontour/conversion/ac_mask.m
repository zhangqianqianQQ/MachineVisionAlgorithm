function mask = ac_mask(acontour, mask_size)
%ac_mask: conversion of an active contour into a binary mask
%   m = ac_mask(a, m_size) computes the binary mask, m, of an active contour, a.
%   The size of m is given by m_size.
%   m_size can be a 1x2 or a 2x1 matrix. The class of m is double.
%
%   Validity of the active contour is not checked. In particular, if it is
%   composed of intersecting single contours, the mask is not binary since it is
%   computed as the sum of the masks of the single contours.
%
%See also ac_validity, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 15, 2006

mask = zeros(mask_size);

for subac_idx = 1:length(acontour)
   samples = fnplt(acontour(subac_idx));

   samples(samples < 1) = 1;
   samples(1, samples(1,:) > mask_size(1)) = mask_size(1);
   samples(2, samples(2,:) > mask_size(2)) = mask_size(2);

   %fnplt may output repeated or almost identical samples, disturbing
   %po_orientation (or po_simple)
   %and
   %several samples outside the frame domain may have been projected into
   %identical samples by the above clipping
   samples(:,sum(abs(diff(samples, 1, 2))) < 0.1) = [];
   %what if a contour is so unsmooth that fnplt returns only tiny edges
   %(length<0.1) while being non-negligible?

   if size(samples,2) > 3
      mask = mask + sign(po_orientation(samples)) * po_mask(samples, mask_size);
   end
end
