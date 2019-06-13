function [density_hist] = density_histogram(I, block)
    
no_of_edgepixels_in_image = sum(sum(I));

for i = 1:16
    no_of_edgepixels_in_subblock = sum(sum(block{i}{:}));
    density_hist(i) = no_of_edgepixels_in_subblock ./no_of_edgepixels_in_image;
end
    
    