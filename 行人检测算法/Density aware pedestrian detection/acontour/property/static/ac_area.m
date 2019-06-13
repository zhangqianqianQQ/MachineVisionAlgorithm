function acarea = ac_area(acontour)
%ac_area: signed area of an active contour
%   r = ac_area(a) computes the signed area, r, of an active contour, a, using
%   the Green's theorem. If a is oriented counterclockwise, r is positive.
%
%See also po_orientation, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 20, 2006

acarea = 0;

for subac_idx = 1:length(acontour)
   [breaks, coefs, interval] = ppbrk(acontour(subac_idx), 'breaks', 'coefs', 'interval');

   %/!\ this might not be valid if the ppform structure changes
   first_coordinate  = mkpp(breaks, coefs(1:2:end,:));
   second_coordinate = mkpp(breaks, coefs(2:2:end,:));

   acarea = acarea + 0.5 * fnval(fnint(...
      fncmb(...
         fncmb(first_coordinate,  '*', fnder(second_coordinate)), ...
         '-', ...
         fncmb(second_coordinate, '*', fnder(first_coordinate))...
      )), interval(2));
end
