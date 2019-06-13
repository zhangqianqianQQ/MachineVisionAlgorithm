function [ratio1, ratio2, h1, h2, o_ratio]   = computeOverlapArea(bbox1,bbox2)



h1      = bbox1(4)  - bbox1(2);
h2      = bbox2(4)  - bbox2(2);

minx    = max(bbox1(1),bbox2(1));
miny    = max(bbox1(2),bbox2(2));
maxx    = min(bbox1(3),bbox2(3));
maxy    = min(bbox1(4),bbox2(4));
if(minx>maxx || miny>maxy)
    o_area  = 0;
    ratio1  = 0;
    ratio2  = 0;
else
    o_area  = (maxx-minx+1) * (maxy-miny+1);
    area1   = (bbox1(3)-bbox1(1)+1)*(bbox1(4)-bbox1(2)+1);
    area2   = (bbox2(3)-bbox2(1)+1)*(bbox2(4)-bbox2(2)+1);
    ratio1  = o_area/area1;
    ratio2  = o_area/area2;
end

