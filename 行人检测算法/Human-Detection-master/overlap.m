function map = overlap(rect1, rect2)

% rect1 = [60 60;120 120];
% rect2 = [65 65;150 150];

area1 = (rect1(2,1)-rect1(1,1)+1)*(rect1(2,2)-rect1(1,2)+1);
area2 = (rect2(2,1)-rect2(1,1)+1)*(rect2(2,2)-rect2(1,2)+1);
area = (area1+area2)/2;
map(1,1) = max(rect1(1,1), rect2(1,1));
map(1,2) = max(rect1(1,2), rect2(1,2));
map(2,1) = min(rect1(2,1), rect2(2,1));
map(2,2) = min(rect1(2,2), rect2(2,2));
if (map(1,1)<map(2,1)) && (map(1,2)<map(2,2))
    map = map;
else
    map = [];
end