% extractFeatureImage extracts Feature Image in circle-coordinate from the
% n-st stacked dish image in ellipse-coordinate.
% Input     - ResizedIm : (possibly) Resized image.
%           - Ellipses : The list of ellipses.
%           - n : Dish number.
% output    - FeatureImage : The Feature Image in circle-coordinate
%                   extracted from the dish image in ellipse-coordinate.
function FeatureImage = extractFeatureImage(ResizedIm, Ellipses, n, showFigures)

%% Check if n is correct input
if n < 1 || n > length(Ellipses)
    error('Error. Incorrect input n in the function extractFeatureImage.')
end

%% Initialize.

% Radius of the Feature Image.
FeatureRadius = 50;
extractBoundaryRadius = floor(FeatureRadius*2/3);
% Take n-st ellipse
ellipse = Ellipses{n};

FeatureImage = uint8(zeros(2*FeatureRadius+1, 2*FeatureRadius+1, 3));
[ROW, COL, k] = size(ResizedIm);

% Get Transformation matrix T.
T = transformEllipseIntoCircle(ellipse, FeatureRadius);

%% Warp the ellipse part in the given image into the circle part
% in the Feature Image.
for i = -FeatureRadius:FeatureRadius
    for j = -FeatureRadius:FeatureRadius
        
        % Transformed point p(x,y) from circle-coordinate into
        % ellipse-coordinate.
        p = (T\[i;j;1])';
        p = p/p(3);
        x = p(1); y = p(2);
        x_floor = ceil(x)-1; y_floor = ceil(y)-1;
        a = x-x_floor; b = y-y_floor;
        
        % Check if this point is inside of the valid extraction area.
        
        CheckInsideExtractionArea = (i*i + j*j >= extractBoundaryRadius*extractBoundaryRadius);
        CheckInsideEllipse = (i*i + j*j <= FeatureRadius*FeatureRadius);
        CheckInsideEntireImage = x_floor > 0 && y_floor > 0 && x_floor < COL && y_floor < ROW;
        % Assume that the dish is occluded only by the upper dish.
        if n == length(Ellipses)
            CheckNotOccluded = true;
        else
            CheckNotOccluded = ~checkPointInEllipse (Ellipses{n+1}, x_floor, y_floor);
        end
        

        
        % If this point is inside of the valid extraction area.
        if (CheckInsideExtractionArea &&  CheckInsideEllipse && CheckNotOccluded && CheckInsideEntireImage)
            
            % Calculate feature value using bilinear interpolation.
            for k = 1:3
                
                sum = (1-a)*(1-b)*ResizedIm(y_floor, x_floor, k);
                sum = sum + (1-a)*b*ResizedIm(y_floor+1, x_floor, k);
                sum = sum + (1-b)*a*ResizedIm(y_floor, x_floor+1, k);
                sum = sum + a*b*ResizedIm(y_floor+1, x_floor+1, k);
        
                FeatureImage(j+FeatureRadius+1,i+FeatureRadius+1,k) = uint8(sum);
            end
            % If this point is outside of the valid extraction area.
        else
            FeatureImage(j+FeatureRadius+1,i+FeatureRadius+1,:) = [-1 -1 -1];
            
        end
    end
end

if showFigures
    figure;
    imshow(FeatureImage);
end

end

% checkPointInEllipse check if given point is inside of given ellipse.
% Input     - ellipse : Ellipse structure which consists of 
%                   [Z, A, B, ALPHA], where 
%                   X = Z + Q(ALPHA) * [A * cos(theta); B * sin(theta)],
%                  Q(ALPHA) = [cos(ALPHA), -sin(ALPHA); 
%                               sin(ALPHA), cos(ALPHA)]
%             x : x-coordinate of the point
%             y : y-coordinate of the point
% output    - b : Boolean value. True if the point is inside of ellipse.
function b = checkPointInEllipse (ellipse, x, y)

% Get Transformation Matrx of ellipse into the circle of radius 1.
T = transformEllipseIntoCircle(ellipse, 1);

% Transform given point (x,y) into the circle map.
TransformedPoint = T*[x;y;1];
x = TransformedPoint(1);
y = TransformedPoint(2);

% Check if the transformed point is inside of the circle.
b = (x*x+y*y<=1);

end

% transformEllipseIntoCircle calculate transformation matrix T.
% T transforms given ellipse into the circle with given radius at origin.
% Input     - ellipse : Ellipse structure which consists of 
%                   [Z, A, B, ALPHA], where 
%                   X = Z + Q(ALPHA) * [A * cos(theta); B * sin(theta)],
%                  Q(ALPHA) = [cos(ALPHA), -sin(ALPHA); 
%                               sin(ALPHA), cos(ALPHA)]
%             radius : Radius of transformed circle
% output    - T : Transformation matrix from ellipse into the circle.
function T = transformEllipseIntoCircle(ellipse, radius)

% Initialize.
ScaleMatrix = zeros(3,3);
RotationAngle = -ellipse.Alpha;

% Set ScaleMatrix.
ScaleMatrix(1,1) =  radius/ellipse.A;
ScaleMatrix(2,2) =  radius/ellipse.B;
ScaleMatrix(3,3) = 1;

% Set RotationMatrix.
RotationMatrix = [cosd(RotationAngle), -sind(RotationAngle), 0;
    sind(RotationAngle), cosd(RotationAngle), 0;
    0 0 1];

% Set TranslationMatrix.
TranslationMatrix = [1 0 -ellipse.Z(2);
    0 1 -ellipse.Z(1);
    0 0 1];

% Get Transformation matrix.
T = ScaleMatrix * RotationMatrix * TranslationMatrix;

end