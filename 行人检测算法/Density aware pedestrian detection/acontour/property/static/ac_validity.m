function validity = ac_validity(acontour)
%ac_validity: check for validity of an active contour
%   v = ac_validity(a) checks the validity, v (either true or false), of an
%   active contour, a. An empty contour (isempty(a) is true) is not considered
%   valid. Otherwise, the contour is valid if it is a struct array (possibly
%   containing a single structure) of polynomial, 2-D-valued univariate splines
%   in ppform. The splines must be closed, non self-intersecting, and without
%   intersections between each other. Moreover, the splines that are not nested
%   in other splines must be oriented counterclockwise. Nested splines get the
%   orientation (-1)^nesting_level.
%
%   Note:
%   Among the previous properties, the closure and non self-intersection are in
%   fact not tested. Self-intersection could be implemented using some code
%   taken from ac_deformation. Is the following test for closure compromised by
%   roundoff errors: isequal(ppval(a, breaks(1)/interval(1)), ppval(a,
%   breaks(end)/interval(2)))? or, equivalently, isequal(diff(ppval(s,
%   interval), 1, 2), [0;0])?
%   Also, the intersections between splines is not done properly. Only the
%   endpoints of the spline segments are tested for inclusion. Computing the
%   mask of the active contour and checking its maximum value is another way to
%   test for intersections. However, it would rely on an "incorrect" behavior of
%   the current version of ac_mask.
%
%See also po_orientation, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 15, 2006

if isempty(acontour)
   validity = false;
else
   validity = all(arrayfun(@(a) (isfield(a, 'form') && strcmp(a.form, 'pp')), acontour));

   breaks = cell(1,length(acontour));
   subac_idx = 1;
   while validity && (subac_idx <= length(acontour))
      breaks{subac_idx} = ppbrk(acontour(subac_idx), 'breaks');
      validity = (length(breaks{subac_idx}) > 3);
      subac_idx = subac_idx + 1;
   end

   if validity
      samples = cell(1,length(acontour));
      for subac_idx = 1:length(acontour)
         samples{subac_idx} = ppval(acontour(subac_idx), breaks{subac_idx});
      end

      inclusion = cell(1,length(acontour));
      for sample_index = 1:length(acontour)
         for other_index = (sample_index+1):length(acontour)
            inside = inpolygon(samples{sample_index}(1,:), samples{sample_index}(2,:), ...
               samples{other_index}(1,:), samples{other_index}(2,:));
            if all(inside)
               inclusion{sample_index}(end+1) = other_index;
            elseif any(inside)
               validity = false;
               return
            else
               inside = inpolygon(samples{other_index}(1,:), samples{other_index}(2,:), ...
                  samples{sample_index}(1,:), samples{sample_index}(2,:));
               if all(inside)
                  inclusion{other_index}(end+1) = sample_index;
               end
            end
         end
      end

      subac_idx = 1;
      while validity && (subac_idx <= length(acontour))
         validity = (sign(po_orientation(samples{subac_idx})) == (-1)^length(inclusion{subac_idx}));
         subac_idx = subac_idx + 1;
      end
   end
end
