function res = matrix_max_percent(mat)
    res = floor(mat/max(mat(:))*100);
end