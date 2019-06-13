function deformed = ac_deformation(acontour, deformation, framesize, resolution)
%ac_deformation: deformation of an active contour with topology management
%   e = ac_deformation(a, d, f, r) applies a deformation, d, to an active
%   contour, a, and clips it according to some corner coordinates, f (see
%   ac_clipping), while maintaining (or imposing) a resolution of r. d is a 2xN
%   array where N is the number of segments of the active contour (or,
%   equivalently, its number of samples). If the active contour is composed of m
%   single active contours, then N is the sum of the N_i's for i ranging from 1
%   to m, where N_i is the number of segments of the i^th single active contour.
%   d is then equal to [d_1 d_2 ... d_i ...], where d_i is the deformation to
%   be applied to the i^th single active contour.
%
%   The i^th single active contour of a is sampled and its j^th sample is
%   translated by d_i(:,j). d_i(1,j) is applied to the first coordinate of the
%   sample. If the orientation of the deformed single active contour is opposite
%   to its original orientation, the deformation has transformed the contour
%   into a point and then further into some "anticontour". Therefore, the
%   contour has disappeared. If all of the single active contours disappear, e
%   is the empty array. Otherwise, each non-empty deformed single active contour
%   is tested for self-intersection and split into several simple single active
%   contours if needed. Finally, the set of deformed single active contours,
%   either originally present or resulting from a splitting, is tested for
%   cross-intersection and merging are performed if needed.
%
%   f is either a 2x1 or a 1x2 matrix. If r is positive, the length of each
%   active contour segment is approximately of r pixels. If negative, the active
%   contour is composed of abs(r) segments (or, equivalently, samples).
%
%   Known bug: in some cases of self-intersection, an active contour might
%   disappear due to a wrong estimation of the contour orientation. The active
%   contour deformation (or velocity) can be smoothed a little to try to avoid
%   this phenomenon, either through the smoothing parameter of ac_segmentation
%   or by adding a minimum length constraint to the segmentation energy.
%
%See also po_orientation, ac_clipping, ac_segmentation, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: July 5, 2006

deformed = [];
deformation_idx = 1;
for subac_idx = 1:length(acontour)
   breaks = ppbrk(acontour(subac_idx), 'breaks');
   previous_samples = ppval(acontour(subac_idx), breaks(1:end - 1));
   orientation = sign(po_orientation([previous_samples previous_samples(:,1)]));

   current_deformation = deformation(:,deformation_idx:(deformation_idx+length(breaks)-2));
   samples = previous_samples + current_deformation;
   new_orientation = po_orientation([samples samples(:,1)]);
   %if the polygon is not simple, in some cases (in particular, a single
   %self-intersection), the orientation is not close to 2*pi in absolute value.
   %then, the signed area is used to find an orientation anyway (is it really
   %robust?)
   if (abs(new_orientation) < 1.8 * pi) || (abs(new_orientation) > 2.2 * pi)
      new_orientation = sign(ac_area(cscvn([samples samples(:,1)])));
   else
      new_orientation = sign(new_orientation);
   end

   if new_orientation == orientation
      hires_samples = fnplt(cscvn([samples samples(:,1)]));
      %fnplt may output repeated or almost identical samples, disturbing
      %po_simple (or po_orientation)
      hires_samples(:,sum(abs(diff(hires_samples, 1, 2))) < 0.1) = [];
      %what if a contour is so unsmooth that fnplt returns only tiny edges
      %(length<0.1) while being non-negligible?

      if (size(hires_samples,2) < 5) || po_simple(hires_samples)
         samples = [samples samples(:,1)];
      else%splitting management
         mask = po_mask(hires_samples, framesize);
         [labels, number_of_regions] = bwlabeln(1 - mask, 4);
         if number_of_regions > 1
            mask = logical(mask);
            for label = 1:number_of_regions
               [coord_1, coord_2] = find(labels == label);
               if inpolygon(coord_1(round(end/2)), coord_2(round(end/2)), hires_samples(1,:), hires_samples(2,:))
                  mask = imfill(mask, [coord_1(round(end/2)) coord_2(round(end/2))], 4);
               end
            end
            mask = double(mask);
         end
         samples = po_isocontour(mask, 0.5, orientation, {1 0}, fspecial('gaussian', 5, 2));
      end

      if iscell(samples)
         deformed = [deformed cellfun(@cscvn, samples)];
      else
         deformed = [deformed cscvn(samples)];
      end
   end

   deformation_idx = deformation_idx + length(breaks) - 1;
end

if ~isempty(deformed)
   if length(deformed) > 1%merging management
      deformed = ac_isocontour(ac_mask(deformed, framesize), 0.5, 1, resolution, {1 0}, [], true);
   else
      deformed = ac_resampling(deformed, resolution, framesize);
   end
end
