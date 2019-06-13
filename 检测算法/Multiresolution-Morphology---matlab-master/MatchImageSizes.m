function [im1, im2] = MatchImageSizes(I1, I2)

nrows = max(size(I1,1), size(I2,1));
ncols = max(size(I1,2), size(I2,2));
nchannels = size(I1,3);
if nchannels~=size(I2,3)
    I2=[I2, zeros(size(I2,1)), zeros(size(I2,2))];
end

extendedI1 = [ I1, zeros(size(I1,1), ncols-size(I1,2), nchannels); ...
  zeros(nrows-size(I1,1), ncols, nchannels)];

extendedI2 = [ I2, zeros(size(I2,1), ncols-size(I2,2), nchannels); ...
  zeros(nrows-size(I2,1), ncols, nchannels)];

im1=extendedI1;
im2=extendedI2;

end