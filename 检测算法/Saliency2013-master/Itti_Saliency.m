function [iCM, cCM, oCM, sm] = Itti_Saliency(img,varargin)

verbose=0;
pictures=0;

% Load image
if verbose
    fprintf('Loading %s\n',filename);
end
image=img;
if pictures
    ShowImage(1,image,'Image');
end
image=double(image);

% Extract luminance and color channels
if verbose
    fprintf('Extracting early channels\n');
end

if length(size(image)) == 3 
	[iIm,rIm,gIm,bIm,yIm]=ExtractChannels(image);
    
   % if max(max(rIm))>0 && max(max(gIm))>0 && max(max(bIm))>0
     if max(max(rIm))>0 && max(max(gIm))>0
        % Create pyramids
        if verbose
            fprintf('Creating pyramids\n');
        end
        iPyr=GaussianPyramid(iIm);
        rPyr=GaussianPyramid(rIm);
        gPyr=GaussianPyramid(gIm);
        bPyr=GaussianPyramid(bIm);
        yPyr=GaussianPyramid(yIm);
        oPyr=OrientationPyramid(iPyr);

        % Create feature maps
        if verbose
            fprintf('Creating feature maps\n');
        end
        iFM=IntensityFeatureMap(iPyr);
        [rgFM byFM]=ColorFeatureMap(rPyr,gPyr,bPyr,yPyr);
        oFM=OrientationFeatureMap(oPyr);

        % Create conspicuity maps
        if verbose
            fprintf('Conspicuity maps\n');
        end
        [iCM cCM oCM]=ConspicuityMap(iFM,oFM, rgFM,byFM);
        if pictures
            ShowImage(2,iCM,'Intensity CM');
            ShowImage(3,cCM,'Color CM');
            ShowImage(4,oCM,'Orientation CM');
        end

        % Create saliency map
        if verbose
            fprintf('Saliency map\n');
        end
        sm=SaliencyMap(iCM,oCM,cCM);

   %     s=size(image);
   %     s=s(1:2);
   %    sm=imresize(sm,s,'bilinear');
   %    sm=sm/max(max(sm))*255;
        if pictures
            ShowImage(5,sm,'Saliency');
        end
    else
        iIm = rgb2hsv(image);
        iIm = iIm(:,:,3);
        iPyr=GaussianPyramid(iIm);
        oPyr=OrientationPyramid(iPyr);
        
        if verbose
            fprintf('Creating feature maps\n');
        end
        iFM=IntensityFeatureMap(iPyr);
        oFM=OrientationFeatureMap(oPyr);
        
        % Create conspicuity maps
        if verbose
            fprintf('Conspicuity maps\n');
        end
        [iCM cCM oCM]=ConspicuityMap(iFM,oFM);
        if pictures
            ShowImage(2,iCM,'Intensity CM');
            ShowImage(3,oCM,'Orientation CM');
        end
        if verbose
            fprintf('Saliency map\n');
        end
        sm=SaliencyMap(iCM,oCM);        
        s=size(image);
        s=s(1:2);
        sm=imresize(sm,s,'bilinear');
        if pictures
            ShowImage(4,sm,'Saliency');
        end
    end
else
        iIm = image;
        iPyr=GaussianPyramid(iIm);
        oPyr=OrientationPyramid(iPyr);
        
        if verbose
            fprintf('Creating feature maps\n');
        end
        iFM=IntensityFeatureMap(iPyr);
        oFM=OrientationFeatureMap(oPyr);
        
        % Create conspicuity maps
        if verbose
            fprintf('Conspicuity maps\n');
        end
        [iCM cCM oCM]=ConspicuityMap(iFM,oFM);
        if pictures
            ShowImage(2,iCM,'Intensity CM');
            ShowImage(3,oCM,'Orientation CM');
        end
        if verbose
            fprintf('Saliency map\n');
        end
        sm=SaliencyMap(iCM,oCM);        
        s=size(image);
        s=s(1:2);
        sm=imresize(sm,s,'bilinear');
        if pictures
            ShowImage(4,sm,'Saliency');
        end
end

% ------------------------------------------------------------------------
% ExtractChannels
% ------------------------------------------------------------------------

function [iIm,rIm,gIm,bIm,yIm]=ExtractChannels(image)

r = image(:,:,1);
g = image(:,:,2);
b = image(:,:,3);

iIm = (r+g+b)/3;

% iIm = rgb2hsv(image);
% iIm = iIm(:,:,3);

% Normalize (see Itti, Koch & Niebur, p. 1255)
normalizer = iIm;
maxIm = max(max(iIm));

zeroentry = find(normalizer == 0);
normalizer(zeroentry) = 1e-10;
t = iIm < maxIm/10;
r = r ./ normalizer;
g = g ./ normalizer;
b = b ./ normalizer; 
r(t) = 0;
g(t) = 0;
b(t) = 0;

% Channels R,G,B,Y
rIm = r - (g + b)/2;
gIm = g - (r + b)/2;
bIm = b - (r + g)/2; % negtive 
yIm = (r + g)/2 - abs(r - g)/2 - b;
rIm(rIm<0) = 0;
gIm(gIm<0) = 0;
bIm(bIm<0) = 0;
yIm(yIm<0) = 0;

% ------------------------------------------------------------------------
% GaussianPyramid
% ------------------------------------------------------------------------

function pyramid = GaussianPyramid(image)

pyramid{1} = image;

for level=2:9
    im = gausmooth(pyramid{level-1});
    s=ceil(size(pyramid{level-1})/2.0);
	pyramid{level} = imresize(im,s);
end

% ------------------------------------------------------------------------
% GaussianSmooth
% ------------------------------------------------------------------------
function im = gausmooth(im)

[m,n] = size(im);
GaussianDieOff = .0001;  
pw = 1:30; 
ssq = 2;
width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
if isempty(width)
    width = 1;  % the user entered a really small sigma
end
t = (-width:width);
gau = exp(-(t.*t)/(2*ssq))/sum(exp(-(t.*t)/(2*ssq)));     

im = imfilter(im, gau,'conv','replicate');   % run the filter accross rows
im = imfilter(im, gau','conv','replicate'); % and then accross columns
% im = im/max(max(im));

% ------------------------------------------------------------------------
% OrientationPyramid
% ------------------------------------------------------------------------

function oPyr = OrientationPyramid(iPyr)

gabor{1}=gabor_fn(1,0.5,0,2,0);
gabor{2}=gabor_fn(1,0.5,0,2,pi/4);
gabor{3}=gabor_fn(1,0.5,0,2,pi/2);
gabor{4}=gabor_fn(1,0.5,0,2,pi*3/4);

% gabor{1}=gabor_fn(1,1,0,2.333,0);
% gabor{2}=gabor_fn(1,1,0,2.333,pi/4);
% gabor{3}=gabor_fn(1,1,0,2.333,pi/2);
% gabor{4}=gabor_fn(1,1,0,2.333,pi*3/4);

for l=3:9
    for o=1:4
        oPyr{l,o}=imfilter(iPyr{l},gabor{o},'symmetric');
    end
end

% ------------------------------------------------------------------------
% GaborFilterBank (with complex Gabors)
% ------------------------------------------------------------------------


function gb=gabor_fn(bw,gamma,psi,lambda,theta)
% bw    = bandwidth, (1)
% gamma = aspect ratio, (0.5)
% psi   = phase shift, (0)
% lambda= wave length, (>=2)
% theta = angle in rad, [0 pi)
 
sigma = lambda/pi*sqrt(log(2)/2)*(2^bw+1)/(2^bw-1);
sigma_x = sigma;
sigma_y = sigma/gamma;

sz=fix(8*max(sigma_y,sigma_x));
if mod(sz,2)==0, sz=sz+1;end

% alternatively, use a fixed size
% sz = 60;
 
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(sz/2):-1:fix(-sz/2));
% x (right +)
% y (up +)

% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
gb=exp(-0.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);
%imshow(gb/2+0.5);

function gabor = GaborFilterBank

% low-pass filter for 5 x 5 kernels
l=[1 3 8 3 1]/16.0;
lpf = l'*l;
ssd = 1;

%4 orientations
% for o=1:4
%     angle=(o-1)*pi/4;
%     c=cos(angle);
%     s=sin(angle);
%     for x=1:5
%         for y=1:5
%             m=pi/2*(c*(x-3)+s*(y-3));
%             kernel(y,x)=cos(m)+i*sin(m);
%         end
%     end
%     gabor{o}=kernel .* lpf;
% end


for o = 1:4
    sz_x=fix(6*sqrt(ssd));
    sz_y=fix(6*sqrt(ssd));

    [x y]=meshgrid(-fix(sz_x/2):fix(sz_x/2),fix(-sz_y/2):fix(sz_y/2));

    % Rotation 
    angle=(o-1)*pi/4;
    x_theta=x*cos(angle)+y*sin(angle);
    y_theta=-x*sin(angle)+y*cos(angle);

    match = find(x_theta==0);
    x_theta(match) = x_theta(match) + 1e-10;
    gabor{o}=exp(-.5*(x_theta.^2/ssd+y_theta.^2/ssd)).*cos(2*pi./x_theta);
end

% ------------------------------------------------------------------------
% IntensityFeatureMap
% ------------------------------------------------------------------------

function iFM = IntensityFeatureMap(iPyr)

for c=3:5
    for delta = 3:4
        s = c + delta;
        iFM{c,s} = abs(Subtract(iPyr{c}, iPyr{s}));
    end
end

% ------------------------------------------------------------------------
% ColorFeatureMap
function [rgFM, byFM] = ColorFeatureMap(rPyr, gPyr, bPyr, yPyr)

for c=3:5
    for delta = 3:4
        s = c + delta;
        rgFM{c,s} = abs(Subtract(rPyr{c}-gPyr{c}, gPyr{s}-rPyr{s}));
        byFM{c,s} = abs(Subtract(bPyr{c}-yPyr{c}, yPyr{s}-bPyr{s}));
    end
end

% ------------------------------------------------------------------------
% OrientationFeatureMap
% ------------------------------------------------------------------------

function oFM = OrientationFeatureMap(oPyr)

for c=3:5
    for delta = 3:4
        s = c + delta;
        for o=1:4
            oFM{c,s,o}=abs(Subtract(oPyr{c,o},oPyr{s,o}));
        end
    end
end

% ------------------------------------------------------------------------
% ConspicuityMap
% ------------------------------------------------------------------------

function [iCM,cCM,oCM] = ConspicuityMap(varargin)

iFM = varargin{1};
oFM = varargin{2};

dim=size(iFM{3,6});
iCM=zeros(dim);
for c=3:5
    for delta = 3:4
        s = c + delta;
%         weight=s*c;
        weight=1;
        iCM = Add(iCM,weight*Normalize(iFM{c,s}));
    end
end

oCM=zeros(dim);
for c=3:5
    for delta = 3:4
        s = c + delta;
%         weight=s*c;
        weight=1;
        for o=1:4
            oCM=Add(oCM,weight*Normalize(oFM{c,s,o}));
        end
    end
end

cCM=zeros(dim);
if length(varargin) == 4
    rgFM = varargin{3};
    byFM = varargin{4};    
    for c=3:5
        for delta = 3:4
            s = c + delta;
    %         weight=s*c;
            weight=1;
            cCM = Add(cCM,weight*Normalize(rgFM{c,s}));
            cCM = Add(cCM,weight*Normalize(byFM{c,s}));
        end
    end
end

% ------------------------------------------------------------------------
% Normalize
% ------------------------------------------------------------------------

function normalized = Normalize(map)

% Normalize map to range [0..1]
minValue = min(min(map));
map = map-minValue;
maxValue = max(max(map));
if maxValue>0
    map = map/maxValue;
end

% Position of local maxima
lmax = LocalMaxima(map);

% Position of global maximum
gmax = (map==1.0);

% Local maxima excluding global maximum
lmax = lmax .* (gmax==0);

% Average of local maxima excluding global maximum
nmaxima=sum(sum(lmax));
if nmaxima>0
    m = sum(sum(map.*lmax))/nmaxima;
else
    m = 0;
end
normalized = map*(1.0-m)^2;

% ------------------------------------------------------------------------
% LocalMaxima
% ------------------------------------------------------------------------

function maxima = LocalMaxima(A)

nRows=size(A,1);
nCols=size(A,2);
% compare with bottom, top, left, right
maxima =           (A > [A(2:nRows, :);   zeros(1, nCols)]);
maxima = maxima .* (A > [zeros(1, nCols); A(1:nRows-1, :)]);
maxima = maxima .* (A > [zeros(nRows, 1), A(:, 1:nCols-1)]);
maxima = maxima .* (A > [A(:, 2:nCols),   zeros(nRows, 1)]);

% ------------------------------------------------------------------------
% Subtract
% ------------------------------------------------------------------------

function result = Subtract(im1, im2)

im2 = imresize(im2, size(im1), 'bilinear');
result = im1 - im2;

% ------------------------------------------------------------------------
% Add
% ------------------------------------------------------------------------

function result = Add(im1, im2)

im2 = imresize(im2, size(im1), 'bilinear');
result = im1 + im2;

% ------------------------------------------------------------------------
% SaliencyMap
% ------------------------------------------------------------------------

function sm=SaliencyMap(varargin)

iCM = varargin{1};
oCM = varargin{2};
if length(varargin) == 2
    sm=(Normalize(iCM)+Normalize(oCM))/2;
else
    cCM = varargin{3};
    sm=(Normalize(iCM)+Normalize(cCM)+Normalize(oCM))/3;
end

% ------------------------------------------------------------------------
% ShowImage
% ------------------------------------------------------------------------

function ShowImage(nFigure,image,fTitle)

% figure(nFigure);
figure;
imagesc(image);
if (size(image, 3) == 1)
    colormap('gray');
    colorbar;
end
axis image;
title(fTitle);
