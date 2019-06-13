function [ out ] = Histograms1D( image, s, w )
%  Histograms1D - %  Create for each pixel three 1D histograms of color intensity in a s by
%  s window around that pixel.  image is a NxNx3 matrix of integers
%  [0,255].  w must divide 256.
%--------------------------------------------------------------------------
%   Params: image - image to be histogramed
%           s - the window size that each frame will be split up in to form
%               histograms
%           w - the width of the bins for the RGB color
%               histograms
%
%   Returns: out - histograms for image
%--------------------------------------------------------------------------
height = length(image(:,1,1));
width = length(image(1,:,1));
discHeight = floor(height/s);
discWidth = floor(width/s);
out = zeros(256/w,3,discHeight,discWidth);

for i=1:discHeight
    for j=1:discWidth
        out(:,:,i,j) = SimpleHist1D(image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:),w);
    end
end

% Complexity: (height)*(width)

end