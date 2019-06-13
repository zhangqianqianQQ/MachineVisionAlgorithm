function kos_map = obtain_kos_map(lines_refined,img_size)
    lines = lines_refined;
    init_map = double(zeros(img_size(1),img_size(2)));
    shortest = min(lines(5,:));
    longest = max(lines(5,:));
    lines(5,:) = (lines(5,:)-shortest) ./ (longest-shortest);
    for lidx = 1 : size(lines,2)
        y = sort(lines([1,2],lidx));
        x = sort(lines([3,4],lidx));
        expand_factor = 0.2; % expand 20%
        x_min = round( x(1)*(1-expand_factor) );
        x_max = round( x(2)*(1+expand_factor) );
        y_min = round( y(1)*(1-expand_factor) );
        y_max = round( y(2)*(1+expand_factor) );
        [x_min,x_max,y_min,y_max] = handle_cross_boundary(x_min,x_max,y_min,y_max,img_size);
        s = lines(5,lidx); 
        init_map(x_min:x_max,y_min:y_max) = init_map(x_min:x_max,y_min:y_max) + s;
    end
    w = ones(5,5) / 25;
    kos_map = imfilter(mat2gray(init_map),w);
end

