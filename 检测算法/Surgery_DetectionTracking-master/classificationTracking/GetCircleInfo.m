function [meanx, meany, radius] = GetCircleInfo( ComponentVideo, s)
%  GetCircleInfo - Find meanx, meany, and radius of circle from component video
%--------------------------------------------------------------------------
%   Params: ComponentVideo - binary component video/image
%           s - the window size that each frame will be split up in to form
%               histograms
%
%   Returns: meanx - mean x point of circle
%            meany - mean y point of circle
%            radius - radius of circle
%
%--------------------------------------------------------------------------

[meanx,meany,radius] = BinaryVidToCircle(ComponentVideo(:,:,:),s); %all
meanx = round(meanx);
meany = round(meany);
radius = round(radius);


end
