function D = reinitialization(D,dt)
% reinitialize the distance map for active contour

% Copyright (c) 2009, 
% Yue Wu @ ECE Department, Tufts University
% All Rights Reserved  

T = padarray(D,[1,1],0,'post');
T = padarray(T,[1,1],0,'pre');
% differences on all directions
a = D-T(1:end-2,2:end-1);
b = T(3:end,2:end-1)-D;
c = D-T(2:end-1,1:end-2);
d = T(2:end-1,3:end)-D;

a_p = max(a,0);
a_m = min(a,0);
b_p = max(b,0);
b_m = min(b,0);
c_p = max(c,0);
c_m = min(c,0);
d_p = max(d,0);
d_m = min(d,0);

G = zeros(size(D));
ind_plus = find(D>0);
ind_minus = find(D<0);
G(ind_plus) = sqrt(max(a_p(ind_plus).^2,b_m(ind_plus).^2)+max(c_p(ind_plus).^2,d_m(ind_plus).^2))-1;
G(ind_minus) = sqrt(max(a_m(ind_minus).^2,b_p(ind_minus).^2)+max(c_m(ind_minus).^2,d_p(ind_minus).^2))-1;

sign_D = D./sqrt(D.^2+1);
D = D-dt.*sign_D.*G;