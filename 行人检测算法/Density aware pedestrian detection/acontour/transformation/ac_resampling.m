function resampled = ac_resampling(acontour, resolution, o_framesize)
%ac_resampling: approximately regular resampling of an active contour using a
%               given number of samples or a sample every some pixels
%   e = ac_resampling(a, r, o_f) resamples an active contour, a, according to a
%   target resolution, r, and optionally clips it.
%   If r is positive, the length of each active contour segment is approximately
%   of r pixels. If negative, the active contour is composed of abs(r) segments
%   (or, equivalently, samples).
%
%   If isempty(o_f) is true, no clipping is performed. Otherwise, o_f is a 2x1
%   or a 1x2 matrix and a clipping is performed after resampling (see
%   ac_clipping). By default, o_f is taken equal to the empty array.
%
%See also ac_clipping, acontour.
%
%Active Contour Toolbox by Eric Debreuve
%Last update: June 22, 2006

if nargin < 3
   o_framesize = [];
end

breaks          = cell(1,length(acontour));
sqrt_of_lengths = cell(1,length(acontour));
lengths         = cell(1,length(acontour));
for subac_idx = 1:length(acontour)
   breaks{subac_idx} = ppbrk(acontour(subac_idx), 'breaks');
   sqrt_of_lengths{subac_idx} = diff(breaks{subac_idx});
   lengths{subac_idx} = sqrt_of_lengths{subac_idx}.^2;
end
total_length = sum([lengths{:}]);

number_of_edges = cell(1,length(acontour));
resolution = num2cell(repmat(resolution, 1, length(acontour)));
for subac_idx = 1:length(acontour)
   if resolution{subac_idx} < 0
      aclength = sum(lengths{subac_idx});
      number_of_edges{subac_idx} = - resolution{subac_idx} * aclength / total_length;
      if number_of_edges{subac_idx} < 3
         number_of_edges{subac_idx} = 3;
      end
      resolution{subac_idx} = aclength / number_of_edges{subac_idx};%mean(lengths{subac_idx});
   end
end

resampled = [];
for subac_idx = 1:length(acontour)
   if max(abs(lengths{subac_idx} - resolution{subac_idx})) > 0.1 * resolution{subac_idx}
      distances = [0, cumsum(lengths{subac_idx})];

      if isempty(number_of_edges{subac_idx})
         number_of_edges{subac_idx} = round(distances(end) / resolution{subac_idx});
         if number_of_edges{subac_idx} < 3
            number_of_edges{subac_idx} = 3;
            %or is it better to set resampled to []?
            %check with what processing follows
         end
      end
      desired_distances = (distances(end) / number_of_edges{subac_idx}) * (0:number_of_edges{subac_idx}-1);

      pieces = sorted(distances, desired_distances);
      relative_error = (sqrt_of_lengths{subac_idx}(pieces) .* ...
         (desired_distances - distances(pieces))) ./ lengths{subac_idx}(pieces);

      samples = ppval(acontour(subac_idx), breaks{subac_idx}(pieces) + relative_error);

      if ~isempty(o_framesize)
         samples(samples < 1) = 1;
         samples(1, samples(1,:) > o_framesize(1)) = o_framesize(1);
         samples(2, samples(2,:) > o_framesize(2)) = o_framesize(2);
      end

      resampled = [resampled cscvn([samples samples(:,1)])];
   else
      resampled = [resampled acontour(subac_idx)];
   end
end
