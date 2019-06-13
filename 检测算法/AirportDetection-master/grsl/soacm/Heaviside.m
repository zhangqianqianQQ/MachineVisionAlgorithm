function H = Heaviside(phi,epsilon) 
% compute the smooth Heaviside function
    H = 0.5 * (1+ (2/pi) * atan(phi./epsilon));
end