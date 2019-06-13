function vos_map = obtain_vos_map(img_q,N)
    % build color cube (color histogram)
    [row,col] = size(img_q(:,:,1));
    color_cube = zeros(N,N,N); 
    for i = 1 : row
        for j = 1 : col
            cr = img_q(i,j,1);
            cg = img_q(i,j,2);
            cb = img_q(i,j,3);
            color_cube(cr,cg,cb) = color_cube(cr,cg,cb) + 1;
        end
    end
    
    % label major color
    num_counted_pixels = 0; % record numder of pixels that have been counted
    num_major_color = 0; % record numder of major colors
    prop = 0.95; % care about 95%
    while num_counted_pixels < prop*row*col
        color_most_n = max(max(max(color_cube))); % number of the most color at this iteration
        same_n = length(color_cube(color_cube == color_most_n));
        num_counted_pixels = num_counted_pixels + same_n*color_most_n;
        num_major_color = num_major_color + same_n;
        % label the counted points in color_cube as -1, meaning that these
        % colors are "major"
        color_cube(color_cube == color_most_n) = -1; 
    end
    
    % assign the rest 5% colors to their near major color
    [r_set,g_set,b_set] = ind2sub(size(color_cube),find(color_cube==-1));
    while ~isempty(color_cube(color_cube>0)) 
        color_most_n = max(max(max(color_cube)));
        [cr,cg,cb] = ind2sub(size(color_cube),find(color_cube==color_most_n)); 
        color_cube(color_cube==color_most_n) = -2;
        for i = 1 : length(cr)
            dist = zeros(length(r_set),1);
            for j = 1 : length(r_set) 
                dist(j) = (cr(i)-r_set(j))^2 + (cg(i)-g_set(j))^2 + (cb(i)-b_set(j))^2;
            end
            label = find(dist == min(dist)); 
            r_assign = r_set(label(1));
            g_assign = g_set(label(1));
            b_assign = b_set(label(1)); 
            for m = 1 : row
                for n = 1 : col
                    if img_q(m,n,1) == cr(i) && img_q(m,n,2)==cg(i) && img_q(m,n,3)==cb(i)
                        img_q(m,n,:) = reshape([r_assign,g_assign,b_assign],1,1,3);
                    end
                end
            end
        end
    end
    % compute vos saliency
    [r_set,g_set,b_set] = ind2sub(size(color_cube),find(color_cube==-1));
    sal = zeros(length(r_set),1); 
    vos_map = zeros(row,col); 
    for i = 1 : length(r_set)
        for j = 1 : length(r_set)
            if j == i
                continue
            end
            sal(i) = sal(i) + sqrt((r_set(i)-r_set(j))^2+(g_set(i)-g_set(j))^2+(b_set(i)-b_set(j))^2);
        end
        for m = 1 : row
            for n = 1 : col
                if img_q(m,n,1)==r_set(i) && img_q(m,n,2)==g_set(i) && img_q(m,n,3)==b_set(i)
                    vos_map(m,n) = sal(i);
                end
            end
        end
    end
    vos_map = mat2gray(vos_map);
end

