function [nxx,nyy] =  zoom_size(nx,ny,factor)
nxx = nx*factor + 0.5;
nyy = ny*factor +0.5;
end