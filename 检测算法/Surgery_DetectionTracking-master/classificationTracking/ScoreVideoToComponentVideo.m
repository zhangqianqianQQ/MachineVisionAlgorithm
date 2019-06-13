function [ out, component ] = ScoreVideoToComponentVideo( scoreVideo )
%  ScoreVideoToComponentVideo - use component analysis to only retain
%  largest component
%--------------------------------------------------------------------------
%   Params: scoreVideo - the score video
%
%   Returns: out - component video only containing biggest component
%            component - number for max component or 0 if no component was
%            large enough
%--------------------------------------------------------------------------

out = 0;
[L,num] = bwlabeln(scoreVideo);
max = 0;
component = 0;

for i = 1:num
    temp = sum(sum(sum(L==i)));
    if (temp>max)
        component=i;
        max = temp;
    end
end
if component == 0
    out = scoreVideo;
else
    %check if a good portion of biggest component is classified correct.
    %If not then don't show it on screen
    %Good values are 0.007, .006, .0065, .005, .004
    percentage = 0.006 * ( size(scoreVideo,1) * size(scoreVideo,2) * size(scoreVideo,3) );
    %display(max);
    %display(percentage);
    if (max < percentage)
        component = 0;
    else
        out = (L==component);
    end
end

end

