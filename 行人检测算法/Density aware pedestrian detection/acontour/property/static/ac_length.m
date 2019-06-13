function aclength = ac_length(acontour)
%ac_length: length of an active contour
%   l = ac_length(a) computes the length, l, of an active contour, a.
%
%See also acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 15, 2006

aclength = 0;

for subac_idx = 1:length(acontour)
   interval = ppbrk(acontour(subac_idx), 'interval');
   tangent  = fnder(acontour(subac_idx));

   aclength = aclength + quad(@n_velocity, 0, interval(2));
end


   function velocity = n_velocity(t)
      velocity = sqrt(sum(ppval(tangent, t).^2));
   end
end
