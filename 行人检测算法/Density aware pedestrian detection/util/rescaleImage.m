function image2 = rescaleImage(image1,bounds);

if nargin<2
    bounds=[0,1];
end
m2=bounds(1);
M2=bounds(2);

m = min(image1(:));
M = max(image1(:));

a=(M2-m2)/(M-m+eps);
b=(m2*M-m*M2)/(M-m+eps);

image2 = a*image1+b;
image2(image2<m2)=m2;
image2(image2>M2)=M2;

image2 = (image1 - m ) / (M+eps);
image2(image2<0)=0;
image2(image2>1)=1;
