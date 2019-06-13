function  center = get_mask_center(mask)

[y, x] = find(mask);

center(1) = (min(x)+max(x))/2;
center(2) = (min(y)+max(y))/2;