function [orientim, G_xx, G_yy, G_xy, cos_2_theta, sin_2_theta, denom] = orient(or_im, g_sigma, b_sigma, o_smooth)
        
  
    % Calculate image gradients.
    hsize = fix(6*g_sigma);   
    if ~mod(hsize,2); hsize = hsize+1; end
    f = fspecial('gaussian', hsize, g_sigma);
    [f_x,f_y] = gradient(f);
    
    
    G_x = filter2(f_x, or_im);
    G_y = filter2(f_y, or_im);
    
    G_xx = G_x.^2;
    G_xy = G_x.*G_y;
    G_yy = G_y.^2;
    
    % to smooth the covariance data
    
    hsize = fix(6*b_sigma);   
    if ~mod(hsize,2); hsize = hsize+1; end    
    f = fspecial('gaussian', hsize, b_sigma);
    
    G_xx = filter2(f, G_xx);
    G_xy = 2*filter2(f, G_xy);
    G_yy = filter2(f, G_yy);
    
    
    denom = sqrt(G_xy.^2 + (G_xx - G_yy).^2) + eps;
    sin_2_theta = G_xy./denom;            % Sin of angle
    cos_2_theta = (G_xx-G_yy)./denom;     % Cos of angle
 
    
    %Smooth
        hsize = fix(6*o_smooth);   
        if ~mod(hsize,2); hsize = hsize+1; end    
        f = fspecial('gaussian', hsize, o_smooth);    
        cos_2_theta = filter2(f, cos_2_theta);
        sin_2_theta = filter2(f, sin_2_theta);
    
    a = pi/2;
    orientim = a + atan2(sin_2_theta,cos_2_theta)/2;
