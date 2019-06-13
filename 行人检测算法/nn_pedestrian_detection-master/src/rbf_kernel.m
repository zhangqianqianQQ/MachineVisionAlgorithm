function [ points ] = rbf_kernel( data, c, v )
    
    points = zeros(size(data,1), size(c,1));
    
    for i = 1:size(c,1)
        points(:, i) = ...
            exp(-sum((data - ones(size(data,1), 1) * c(i,:)) .^ 2 ./ ...
                     (ones(size(data,1), 1) * v(i,:)), 2) / size(c, 2));
    end

end