function varargout = ac_sampling(acontour, o_properties)
%ac_sampling: sampling of an active contour
%   s = ac_sampling(a, o_p) samples an active contour, a, returning the
%   requested properties, o_p. o_p is a string of up to 6 characters among B, b,
%   s, t, n, and c, without repetition, corresponding to the breaks (B or b),
%   the samples, the tangents, the normals, and the curvatures of the active
%   contour, respectively. 'B' corresponds to the complete list of breaks with
%   a(breaks(end)) being equal to a(breaks(1)) while 'b' corresponds to the
%   complete list of breaks but the last one. The other properties are computed
%   at the breaks of this latter list. The tangents are not normalized. The
%   normals are normalized and point inward if the active contour is oriented
%   counterclockwise.
%   The properties are returned in the same order as o_p spells. By default, o_p
%   is taken equal to 'bsn'.
%
%See also acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 15, 2006

if nargin < 2
   o_properties = 'bsn';
end

breaks = cell(1,length(acontour));
for subac_idx = 1:length(acontour)
   breaks{subac_idx} = ppbrk(acontour(subac_idx), 'breaks');
end

where = find(o_properties == 'B');
if ~isempty(where)
   varargout{where} = breaks;
end

for subac_idx = 1:length(acontour)
   breaks{subac_idx}(end) = [];
end

where = find(o_properties == 'b');
if ~isempty(where)
   varargout{where} = breaks;
end

where = find(o_properties == 's');
if ~isempty(where)
   samples = cell(1,length(acontour));
   for subac_idx = 1:length(acontour)
      samples{subac_idx} = ppval(acontour(subac_idx), breaks{subac_idx});
   end
   varargout{where} = samples;
end

if ~isempty(intersect(o_properties, 'tnc'))
   tangents = cell(1,length(acontour));
   for subac_idx = 1:length(acontour)
      tangents{subac_idx} = ppval(fnder(acontour(subac_idx)), breaks{subac_idx});
   end
   where = find(o_properties == 't');
   if ~isempty(where)
      varargout{where} = tangents;
   end

   if ~isempty(intersect(o_properties, 'nc'))
      tangent_norms = cell(1,length(acontour));
      for subac_idx = 1:length(acontour)
         tangent_norms{subac_idx} = sqrt(sum(tangents{subac_idx}.^2));
      end

      where = find(o_properties == 'n');
      if ~isempty(where)
         normals = cell(1,length(acontour));
         for subac_idx = 1:length(acontour)
            normals{subac_idx} = flipud(tangents{subac_idx}) ./ ...
               [- tangent_norms{subac_idx}; tangent_norms{subac_idx}];
         end
         varargout{where} = normals;
      end

      where = find(o_properties == 'c');
      if ~isempty(where)
         curvatures = cell(1,length(acontour));
         for subac_idx = 1:length(acontour)
            second_derivatives = ppval(fnder(acontour(subac_idx), 2), breaks{subac_idx});
            curvatures{subac_idx} = diff(flipud(tangents{subac_idx}) .* second_derivatives) ...
               ./ (tangent_norms{subac_idx}.^3);
         end
         varargout{where} = curvatures;
      end
   end
end

if length(varargout{1}) == 1
   for a = 1:length(varargout)
      varargout{a} = varargout{a}{1};
   end
end
