% drawLineSegments draws Lines using given set of points.
% Input     - MapSize : The size of EdgeMap which can be expressed as
%                       [ROW COL]
%             LineSegments : The set of points which will be drawn.
%                           EdgeContour can be used as input as well.
function drawLineSegments(MapSize, LineSegments)

%% Initialize
NumberOfSegments = length(LineSegments);

% Default setting for plot.
hold on;
minx = 1; maxx = MapSize(2);
miny = 1; maxy = MapSize(1);
axis([minx maxx miny maxy]);
axis off;
set(gca, 'Ydir', 'reverse')

% Use different colors to distinguish each edge.
ColorSet = [
0.00 0.00 1.00 % Data 1 - blue
0.00 1.00 0.00 % Data 2 - green
1.00 0.00 0.00 % Data 3 - red
0.00 1.00 1.00 % Data 4 - cyan
1.00 0.00 1.00 % Data 5 - magenta
0.75 0.75 0.00 % Data 6 - RGB
0.25 0.25 0.25 % Data 7
0.75 0.25 0.25 % Data 8
0.95 0.95 0.00 % Data 9
0.25 0.25 0.75 % Data 10
0.75 0.75 0.75 % Data 11
0.00 0.50 0.00 % Data 12
0.76 0.57 0.17 % Data 13
0.54 0.63 0.22 % Data 14
0.34 0.57 0.92 % Data 15
1.00 0.10 0.60 % Data 16
0.88 0.75 0.73 % Data 17
0.10 0.49 0.47 % Data 18
0.66 0.34 0.65 % Data 19
0.99 0.41 0.23 % Data 20
];


%% Draw each Segement.
for i=1:NumberOfSegments
    Segment = LineSegments{i};
    x = Segment(:,2);
    y = Segment(:,1);
    plot(x, y, 'LineWidth', 2, 'Color', ColorSet(mod(i,20)+1,:));
end

end
