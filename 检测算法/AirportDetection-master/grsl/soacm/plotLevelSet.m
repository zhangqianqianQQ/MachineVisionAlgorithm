function [c,h] = plotLevelSet(u,zLevel,style)
% plot the level contour of function u at the zero-Level.
    [c,h] = contour(u,[zLevel zLevel],style);  
end