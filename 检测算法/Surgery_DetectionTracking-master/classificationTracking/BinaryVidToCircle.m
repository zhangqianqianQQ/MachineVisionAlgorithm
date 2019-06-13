function [ meanx, meany, radius ] = BinaryVidToCircle( binary, s )
%  BinaryVidToCircle - Find meanx, meany, and radius of binary image/video
%--------------------------------------------------------------------------
%   Params: binary - binary image or video
%           s - the window size that each frame will be split up in to form
%               histograms
%
%   Returns: meanx - mean x point of circle
%            meany - mean y point of circle
%            radius - radius of circle
%
%--------------------------------------------------------------------------

count=0;
meanx=0;
meany=0;

for k=1:length(binary(1,1,:))
    for i=1:length(binary(:,1,1))
        for j=1:length(binary(1,:, 1))
            if (binary(i,j,k))
                meanx = meanx + (j-1)*s + s/2;
                meany = meany + (i-1)*s + s/2;
                count = count+1;
            end
        end
    end
end

meanx = meanx/count;
meany = meany/count;
divider = count / length(binary(1,1,:));
radius = (0.5)*s*sqrt(divider*pi);

end

