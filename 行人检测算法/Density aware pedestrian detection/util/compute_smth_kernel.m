function vote_filter=compute_smth_kernel(scale_height, asp_ratio)

ellipse_b_ratio         = 0.03;
gauss_ellipse_b_ratio   = 0.05;
disc_type = 0; 
disc_sigma_ratio = 0.5; 

smooth_sigma_ratio = 1/3; 

vote_filter = cell(length(scale_height),1);
for ns=1:length(scale_height)
    disc_b = round(scale_height(ns)*ellipse_b_ratio);
    disc_a = round(disc_b*asp_ratio(ns));
    smooth_b = round(scale_height(ns)*gauss_ellipse_b_ratio);
    smooth_a = round(smooth_b*asp_ratio(ns));

    if disc_type == 0 
        disc = double(genEllipse(2*disc_a+1,2*disc_b+1));
    else 
        [x,y] = meshgrid(-disc_b:disc_b,-disc_a:disc_a);
        X = [x(:),y(:)];
        C = [disc_b*disc_sigma_ratio,0;0,disc_a*disc_sigma_ratio].^2;
        disc = gaussian(X, [0;0], C);
        disc = reshape(disc, 2*disc_a+1, 2*disc_b+1); 
    end


    [x,y] = meshgrid(-smooth_b:smooth_b,-smooth_a:smooth_a);
    X = [x(:),y(:)];
    C = [smooth_b*smooth_sigma_ratio,0;0,smooth_a*smooth_sigma_ratio].^2;
    smooth_filter = gaussian(X, [0;0], C);
    smooth_filter = reshape(smooth_filter, 2*smooth_a+1, 2*smooth_b+1); 

    vote_filter{ns} = conv2(disc,smooth_filter);
end
