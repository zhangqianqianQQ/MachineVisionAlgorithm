function [normed_data] = min_max_all(data)
max_val = max(data);
min_val = min(data);
range = max_val - min_val;
normed_data = bsxfun(@minus,data,min_val);
normed_data = bsxfun(@rdivide,normed_data,range);