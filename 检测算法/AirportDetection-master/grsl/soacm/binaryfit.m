function [c1,c2]= binaryfit(phi,U,epsilon) 
% compute c1 c2 for optimal binary fitting 
% input: 
%    U: input image
%    phi: level set function
%    epsilon: parameter for computing smooth Heaviside and dirac function
% output: 
%    c1: a constant to fit the image U in the region phi>0
%    c2: a constant to fit the image U in the region phi<0

H = Heaviside(phi,epsilon); % compute the Heaveside function values 

a = H .* U;
numer_1 = sum(a(:)); 
denom_1 = sum(H(:));
c1 = numer_1 / denom_1;

b = (1-H) .* U;
numer_2 = sum(b(:));
c = 1-H;
denom_2 = sum(c(:));
c2 = numer_2 / denom_2;
