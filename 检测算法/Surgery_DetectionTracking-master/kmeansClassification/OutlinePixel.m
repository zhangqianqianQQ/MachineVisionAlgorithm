function [ image ] = OutlinePixel( image, s, i, j, height, width )
%  Replace the pixels forming an (s)x(s) box around the i,j s-pixel of the
%  image with black pixels.

image((i-1)*s+1,(j-1)*s+1:j*s,:)=0;
image(i*s,(j-1)*s+1:j*s,:)=0;
image((i-1)*s+1:i*s,(j-1)*s+1,:)=0;
image((i-1)*s+1:i*s,j*s,:)=0;

if (i>1)
    image((i-1)*s,(j-1)*s+1:j*s,:)=0;
end
if (i<height/s)
    image(i*s+1,(j-1)*s+1:j*s,:)=0;
end
if (j>1)
    image((i-1)*s+1:i*s,(j-1)*s,:)=0;
end
if (j<width/s)
    image((i-1)*s+1:i*s,j*s +1,:)=0;
end

end

