function pos = sample_location_in_mask(mask, sample_step)

[y, x] = find(mask);
idx = find(mod(x, sample_step)==0 & mod(y, sample_step)==0);
pos = [x(idx), y(idx)];