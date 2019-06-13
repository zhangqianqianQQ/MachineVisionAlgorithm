function RGB=hyperspectral2RGB(reflectances)

b=size(reflectances,3);
[r c w] = size(reflectances);
reflectances = reshape(reflectances, r*c, w);

load xyzbar.mat;
xyzbar_variable = xyzbar(1:b,:);
XYZ = ((xyzbar_variable)'*reflectances')';

XYZ = reshape(XYZ, r, c, 3);
XYZ = max(XYZ, 0);
XYZ = XYZ/max(XYZ(:));

RGB = XYZ2sRGB_exgamma(XYZ);
RGB = max(RGB, 0);
RGB = min(RGB, 1);
