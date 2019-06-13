function [rgb, iCM, cCM, oCM, Sm, HSI_group,HSI_spectralED, HSI_spectralSAD, ...
          Sm_HSI_IOC, Sm_HSI_IOG, Sm_HSI_IOE, Sm_HSI_IOA, Sm_HSI_EOG, Sm_HSI_EOA, Sm_HSI_GEA]...
          = HSI_Saliency(scene,varargin)
%extract saliency map from hyperspectral data
%input, scene, hyperspectral image in mat format
%output, rgb, rgb image composed from hyperspectral image
%        iCM, intensity conspicuity map
%        cCM, color conspicuity map
%        oCM, orientation conspicuity map 
%        the above conspicuity maps are derived from Itti's saliency model
%        Sm, saliency map buit with iCM,cCM and oCM  

%        HSI_group, conspicuity map with four groups of colors   
%        HSI_spectralED, conspicuity map with Euclidian distance
%        HSI_spectralSAD, conspicuity map with spectral angle distance

%        Sm_HSI_IOG, saliency map buit with iCM, oCM, HSI_group  
%        Sm_HSI_IOE, saliency map buit with iCM, oCM, HSI_spectralED
%        Sm_HSI_IOA, saliency map buit with oCM, HSI_spectralED, HSI_spectralSAD

%        Sm_HSI_EOG, saliency map buit with HSI_spectralED, oCM, HSI_group
%        Sm_HSI_EOA, saliency map buit with HSI_spectralED, oCM, HSI_spectralSAD


clear global
[~,~,b] = size(scene);
data = normalise(scene, '', 1);
% ------------------------------------------------------------------------
% Extract rgb,intensity and all bands
% ------------------------------------------------------------------------
rgb = hyperspectral2RGB(data);
rgb = rgb.^0.4;
bands = cell(1,b);
for i = 1:b 
    bands{i}=data(:,:,i);
end
% ------------------------------------------------------------------------
% RGB Saliency
% ------------------------------------------------------------------------
[iCM, cCM, oCM, Sm] = Itti_Saliency(rgb); %Itti's saliency
% ------------------------------------------------------------------------
% Four spectral groups
% ------------------------------------------------------------------------
bPyr = GaussianPyramid(bands);
[rgFM, byFM] = BandsFeatureMap_1(bPyr);    
HSI_group = ConspicuityMap_1(rgFM, byFM);
% ------------------------------------------------------------------------
% HSI whole spectral bands with Euclidian distance and spectral angle
% distance
% ------------------------------------------------------------------------
% Euclidear distance
FM1 = BandsFeatureMap_2(bPyr);
% Spectral Angle distance
FM2 = BandsFeatureMap_3(bPyr);
HSI_spectralED = ConspicuityMap_2(FM1);
HSI_spectralSAD = ConspicuityMap_2(FM2);
% ------------------------------------------------------------------------
% saliency maps generated from different combinations of conspicuity maps
% ------------------------------------------------------------------------
Sm_HSI_IOC = SaliencyMap(iCM, oCM, cCM);
Sm_HSI_IOG = SaliencyMap(iCM, oCM, HSI_group);
Sm_HSI_IOE = SaliencyMap(iCM, oCM, HSI_spectralED);
Sm_HSI_IOA = SaliencyMap(iCM, oCM, HSI_spectralSAD);
Sm_HSI_EOG = SaliencyMap(HSI_spectralED, oCM, HSI_group);
Sm_HSI_EOA = SaliencyMap(HSI_spectralED, oCM, HSI_spectralSAD);
Sm_HSI_GEA = SaliencyMap(HSI_group, HSI_spectralED, HSI_spectralSAD);


% ------------------------------------------------------------------------
% Normalize to uint8 0-255
% ------------------------------------------------------------------------
iCM=uint8(Normalize(iCM)*255);
oCM=uint8(Normalize(oCM)*255);
cCM=uint8(Normalize(cCM)*255);
Sm=uint8(Normalize(Sm)*255);
HSI_group=uint8(Normalize(HSI_group)*255);
HSI_spectralED=uint8(Normalize(HSI_spectralED)*255);
HSI_spectralSAD=uint8(Normalize(HSI_spectralSAD)*255);

Sm_HSI_IOC=uint8(Normalize(Sm_HSI_IOC)*255);
Sm_HSI_IOG=uint8(Normalize(Sm_HSI_IOG)*255);
Sm_HSI_IOE=uint8(Normalize(Sm_HSI_IOE)*255);
Sm_HSI_IOA=uint8(Normalize(Sm_HSI_IOA)*255);
Sm_HSI_EOG=uint8(Normalize(Sm_HSI_EOG)*255);
Sm_HSI_EOA=uint8(Normalize(Sm_HSI_EOA)*255);
Sm_HSI_GEA=uint8(Normalize(Sm_HSI_GEA)*255);
% ------------------------------------------------------------------------
% GaussianPyramid
% ------------------------------------------------------------------------
function pyramid = GaussianPyramid(image)
b = size(image,2);

if iscell(image) == 0
    pyramid=cell(1,9);
    pyramid{1} = image;
    for level=2:9
        im = gausmooth(pyramid{level-1});
        s=ceil(size(pyramid{level-1})/2.0);
        pyramid{level} = imresize(im,s);
    end
else  
    pyramid=cell(b,9);
    for i =1:b
        pyramid{i,1}= image{i};
        for level=2:9;
            im = gausmooth(pyramid{i,level-1});
            s=ceil(size(pyramid{i,level-1})/2.0);
            pyramid{i,level} = imresize(im,s);
        end
    end
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



function [rgFM, byFM] = BandsFeatureMap_1(bPyr)
b=size(bPyr,1);
for c=3:5
    for delta = 3:4
        s = c + delta;
        rg1FM = abs(Subtract(bPyr{b,c}-bPyr{floor(b/2),c}, bPyr{b,s}-bPyr{floor(b/2),s}));
        rg2FM = abs(Subtract(bPyr{b-1,c}-bPyr{floor(b/2)-1,c}, bPyr{b-1,s}-bPyr{floor(b/2)-1,s}));
        rg3FM = abs(Subtract(bPyr{b-2,c}-bPyr{floor(b/2)-2,c}, bPyr{b-2,s}-bPyr{floor(b/2)-2,s}));
        rg4FM = abs(Subtract(bPyr{b-3,c}-bPyr{floor(b/2)-3,c}, bPyr{b-3,s}-bPyr{floor(b/2)-3,s}));
        rg5FM = abs(Subtract(bPyr{b-4,c}-bPyr{floor(b/2)-4,c}, bPyr{b-4,s}-bPyr{floor(b/2)-4,s}));
        rg6FM = abs(Subtract(bPyr{b-5,c}-bPyr{floor(b/2)-5,c}, bPyr{b-5,s}-bPyr{floor(b/2)-5,s}));
        rg7FM = abs(Subtract(bPyr{b-6,c}-bPyr{floor(b/2)-6,c}, bPyr{b-6,s}-bPyr{floor(b/2)-6,s}));
        
        by1FM = abs(Subtract(bPyr{floor(b*3/4),c}-bPyr{floor(b/4),c}, bPyr{floor(b*3/4),s}-bPyr{floor(b/4),s}));
        by2FM = abs(Subtract(bPyr{floor(b*3/4)-1,c}-bPyr{floor(b/4)-1,c}, bPyr{floor(b*3/4)-1,s}-bPyr{floor(b/4)-1,s}));
        by3FM = abs(Subtract(bPyr{floor(b*3/4)-2,c}-bPyr{floor(b/4)-2,c}, bPyr{floor(b*3/4)-2,s}-bPyr{floor(b/4)-2,s}));
        by4FM = abs(Subtract(bPyr{floor(b*3/4)-3,c}-bPyr{floor(b/4)-3,c}, bPyr{floor(b*3/4)-3,s}-bPyr{floor(b/4)-3,s}));
        by5FM = abs(Subtract(bPyr{floor(b*3/4)-4,c}-bPyr{floor(b/4)-4,c}, bPyr{floor(b*3/4)-4,s}-bPyr{floor(b/4)-4,s}));
        by6FM = abs(Subtract(bPyr{floor(b*3/4)-5,c}-bPyr{floor(b/4)-5,c}, bPyr{floor(b*3/4)-5,s}-bPyr{floor(b/4)-5,s}));
        by7FM = abs(Subtract(bPyr{floor(b*3/4)-6,c}-bPyr{floor(b/4)-6,c}, bPyr{floor(b*3/4)-6,s}-bPyr{floor(b/4)-6,s}));
        
        rgFM{c,s} = sqrt(rg1FM.^2+rg2FM.^2+rg3FM.^2+rg4FM.^2+rg5FM.^2+rg6FM.^2+rg7FM.^2);
        byFM{c,s} = sqrt(by1FM.^2+by2FM.^2+by3FM.^2+by4FM.^2+by5FM.^2+by6FM.^2+by7FM.^2);
    end
    
end

function FM = BandsFeatureMap_2(bPyr)

for c=3:5
    for delta = 3:4
        s = c + delta;
        FM{c,s} = abs(Subtract_cell(bPyr(:,c), bPyr(:,s)));
    end
end


function FM = BandsFeatureMap_3(bPyr)

for c=3:5
    for delta = 3:4
        s = c + delta;
        b = size(bPyr,1);
        [mc, nc] = size(bPyr{1,c});
        [ms, ns] = size(bPyr{1,s});
        
        matc=cell2matrix(bPyr(:,c),mc,nc,b);
        mats=cell2matrix(bPyr(:,s),ms,ns,b);
        mats=imresize(mats,[mc,nc],'bilinear');
        N_matc=sqrt(sum(matc.^2,3));
        N_mats=sqrt(sum(mats.^2,3));
        pro=dot(matc,mats,3)./(N_matc.*N_mats);
        FM{c,s} = acos(pro);
    end
end

% ------------------------------------------------------------------------
% ConspicuityMap
% ------------------------------------------------------------------------
function HSI_group = ConspicuityMap_1(varargin)

rgFM = varargin{1};
byFM = varargin{2};

dim=size(rgFM{3,6});

HSI_group=zeros(dim);


    
    for c=3:5
        for delta = 3:4
            s = c + delta;
    %         weight=s*c;
            weight=1;
            HSI_group = Add(HSI_group,weight*Normalize(rgFM{c,s}));
            HSI_group = Add(HSI_group,weight*Normalize(byFM{c,s}));
        end
    end

    
    
function HSI_spectralED = ConspicuityMap_2(varargin)
FM = varargin{1};
dim=size(FM{3,6});

HSI_spectralED=zeros(dim);
for c=3:5
    for delta = 3:4
        s = c + delta;
%         weight=s*c;
        weight=1;
        HSI_spectralED=Add(HSI_spectralED,weight*Normalize(FM{c,s}));
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

function result = Subtract_cell(im1, im2)
b=size(im1,1);
result=zeros(size(im1{1}));
for i=1:b
    im2{i} = imresize(im2{i}, size(im1{i}), 'bilinear');
    result_temp = im1{i} - im2{i};
    result_temp = result_temp.^2;
    result=result+result_temp;  
end

% ------------------------------------------------------------------------
% SaliencyMap
% ------------------------------------------------------------------------

function sm=SaliencyMap(varargin)

iCM = varargin{1};
oCM = varargin{2};

if length(varargin) == 2
    sm=(Normalize(iCM)+Normalize(oCM))/2;
elseif length(varargin) == 3
    cCM = varargin{3};
    sm = (Normalize(iCM)+Normalize(cCM)+Normalize(oCM))/3;
elseif length(varargin) == 4
    sm = (Normalize(iCM)+Normalize(oCM)+Normalize(varargin{3})+Normalize(varargin{4}))/4;    
end

% ------------------------------------------------------------------------
% ShowImage
% ------------------------------------------------------------------------

function ShowImage(image,fTitle)

% figure(nFigure);
figure;
imshow(image);
axis image;
title(fTitle);

function matrix = cell2matrix(cell,m,n,b)
matrix=zeros(m,n,b);
for i=1:b
    matrix(:,:,i)= cell{i,1};
end



