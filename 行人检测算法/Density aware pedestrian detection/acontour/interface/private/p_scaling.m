function scaled = p_scaling(unscaled, o_factor)

if nargin < 2
   o_factor = 1;
end

minimum = min(min(unscaled));
maximum = max(max(unscaled));
if length(maximum) == 1%grayscale
   figure('Visible', 'off')
   gray_colormap = colormap('gray');
   close
   new_maximum = o_factor * (size(gray_colormap,1) - 1);
else%color
   minimum = min(minimum);
   maximum = max(maximum);
   new_maximum = o_factor * 255;
end

if minimum == maximum
   scaled = unscaled;
else
   scaled = uint8(round((new_maximum / (maximum - minimum)) * (unscaled - minimum)));
end
