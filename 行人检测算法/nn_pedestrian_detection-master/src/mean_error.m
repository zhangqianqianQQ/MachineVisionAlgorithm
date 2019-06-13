function [ Em ] = mean_error( d, u )

    Em = sum(sum((d - u) .^ 2));

end