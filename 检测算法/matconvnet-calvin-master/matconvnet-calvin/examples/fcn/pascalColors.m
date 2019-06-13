function cmap = pascalColors(colorCount)
% cmap = pascalColors(colorCount)
%
% Color scheme for PASCAL VOC
% First color is black for background.
%
% Copyright by MatConvNet

cmap = zeros(colorCount, 3);
for i = 1 : colorCount
    id = i-1;
    r = 0;
    g = 0;
    b = 0;
    for j=0:7
        r = bitor(r, bitshift(bitget(id, 1), 7 - j));
        g = bitor(g, bitshift(bitget(id, 2), 7 - j));
        b = bitor(b, bitshift(bitget(id, 3), 7 - j));
        id = bitshift(id, -3);
    end
    cmap(i, 1) = r;
    cmap(i, 2) = g;
    cmap(i, 3) = b;
end
cmap = cmap / 255;