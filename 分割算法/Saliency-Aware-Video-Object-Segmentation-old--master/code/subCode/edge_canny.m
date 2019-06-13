function [eout,thresh,mag] = edge_canny(varargin)


[a,method,thresh,sigma,thinning,H,kx,ky] = parse_inputs(varargin{:});

% Check that the user specified a valid number of output arguments


% Transform to a double precision intensity image if necessary
if ~isa(a,'double') && ~isa(a,'single') 
  a = im2single(a);
end

[m,n] = size(a);

% The output edge map:
e = false(m,n);

if strcmp(method,'canny')
  % Magic numbers
  GaussianDieOff = .0001;  
  PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
  ThresholdRatio = .4;          % Low thresh is this fraction of the high.
  
  % Design the filters - a gaussian and its derivative
  
  pw = 1:30; % possible widths
  ssq = sigma^2;
  width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
  if isempty(width)
    width = 1;  % the user entered a really small sigma
  end

  t = (-width:width);
  gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq);     % the gaussian 1D filter

  % Find the directional derivative of 2D Gaussian (along X-axis)
  % Since the result is symmetric along X, we can get the derivative along
  % Y-axis simply by transposing the result for X direction.
  [x,y]=meshgrid(-width:width,-width:width);
  dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);
  
  % Convolve the filters with the image in each direction
  % The canny edge detector first requires convolution with
  % 2D gaussian, and then with the derivitave of a gaussian.
  % Since gaussian filter is separable, for smoothing, we can use 
  % two 1D convolutions in order to achieve the effect of convolving
  % with 2D Gaussian.  We convolve along rows and then columns.

  %smooth the image out
  aSmooth=imfilter(a,gau,'conv','replicate');   % run the filter across rows
  aSmooth=imfilter(aSmooth,gau','conv','replicate'); % and then across columns
  
  %apply directional derivatives
  ax = imfilter(aSmooth, dgau2D, 'conv','replicate');
  ay = imfilter(aSmooth, dgau2D', 'conv','replicate');

  mag = sqrt((ax.*ax) + (ay.*ay));
  magmax = max(mag(:));
  if magmax>0
    mag = mag / magmax;   % normalize
  end
  
  % Select the thresholds
  if isempty(thresh) 
    counts=imhist(mag, 64);
    highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
                      1,'first') / 64;
    lowThresh = ThresholdRatio*highThresh;
    thresh = [lowThresh highThresh];
  elseif length(thresh)==1
    highThresh = thresh;
    if thresh>=1
      eid = sprintf('Images:%s:thresholdMustBeLessThanOne', mfilename);
      msg = 'The threshold must be less than 1.'; 
      error(eid,'%s',msg);
    end
    lowThresh = ThresholdRatio*thresh;
    thresh = [lowThresh highThresh];
  elseif length(thresh)==2
    lowThresh = thresh(1);
    highThresh = thresh(2);
    if (lowThresh >= highThresh) || (highThresh >= 1)
      eid = sprintf('Images:%s:thresholdOutOfRange', mfilename);
      msg = 'Thresh must be [low high], where low < high < 1.'; 
      error(eid,'%s',msg);
    end
  end
  idxStrong = [];  
  for dir = 1:4
    idxLocalMax = cannyFindLocalMaxima(dir,ax,ay,mag);
    idxWeak = idxLocalMax(mag(idxLocalMax) > lowThresh);
    e(idxWeak)=1;
    idxStrong = [idxStrong; idxWeak(mag(idxWeak) > highThresh)];
  end
  
  if ~isempty(idxStrong) % result is all zeros if idxStrong is empty
    rstrong = rem(idxStrong-1, m)+1;
    cstrong = floor((idxStrong-1)/m)+1;
    e = bwselect(e, cstrong, rstrong, 8);
    e = bwmorph(e, 'thin', 1);  % Thin double (or triple) pixel wide contours
  end 
end

if nargout==0,
  imshow(e);
else
  eout = e;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : cannyFindLocalMaxima
%
function idxLocalMax = cannyFindLocalMaxima(direction,ix,iy,mag)
%
% This sub-function helps with the non-maximum suppression in the Canny
% edge detector.  The input parameters are:
% 
%   direction - the index of which direction the gradient is pointing, 
%               read from the diagram below. direction is 1, 2, 3, or 4.
%   ix        - input image filtered by derivative of gaussian along x 
%   iy        - input image filtered by derivative of gaussian along y
%   mag       - the gradient magnitude image
%
%    there are 4 cases:
%
%                         The X marks the pixel in question, and each
%         3     2         of the quadrants for the gradient vector
%       O----0----0       fall into two cases, divided by the 45 
%     4 |         | 1     degree line.  In one case the gradient
%       |         |       vector is more horizontal, and in the other
%       O    X    O       it is more vertical.  There are eight 
%       |         |       divisions, but for the non-maximum suppression  
%    (1)|         |(4)    we are only worried about 4 of them since we 
%       O----O----O       use symmetric points about the center pixel.
%        (2)   (3)        


[m,n] = size(mag);

% Find the indices of all points whose gradient (specified by the 
% vector (ix,iy)) is going in the direction we're looking at.  

switch direction
 case 1
  idx = find((iy<=0 & ix>-iy)  | (iy>=0 & ix<-iy));
 case 2
  idx = find((ix>0 & -iy>=ix)  | (ix<0 & -iy<=ix));
 case 3
  idx = find((ix<=0 & ix>iy) | (ix>=0 & ix<iy));
 case 4
  idx = find((iy<0 & ix<=iy) | (iy>0 & ix>=iy));
end

% Exclude the exterior pixels
if ~isempty(idx)
  v = mod(idx,m);
  extIdx = find(v==1 | v==0 | idx<=m | (idx>(n-1)*m));
  idx(extIdx) = [];
end

ixv = ix(idx);  
iyv = iy(idx);   
gradmag = mag(idx);

% Do the linear interpolations for the interior pixels
switch direction
 case 1
  d = abs(iyv./ixv);
  gradmag1 = mag(idx+m).*(1-d) + mag(idx+m-1).*d; 
  gradmag2 = mag(idx-m).*(1-d) + mag(idx-m+1).*d; 
 case 2
  d = abs(ixv./iyv);
  gradmag1 = mag(idx-1).*(1-d) + mag(idx+m-1).*d; 
  gradmag2 = mag(idx+1).*(1-d) + mag(idx-m+1).*d; 
 case 3
  d = abs(ixv./iyv);
  gradmag1 = mag(idx-1).*(1-d) + mag(idx-m-1).*d; 
  gradmag2 = mag(idx+1).*(1-d) + mag(idx+m+1).*d; 
 case 4
  d = abs(iyv./ixv);
  gradmag1 = mag(idx-m).*(1-d) + mag(idx-m-1).*d; 
  gradmag2 = mag(idx+m).*(1-d) + mag(idx+m+1).*d; 
end
idxLocalMax = idx(gradmag>=gradmag1 & gradmag>=gradmag2); 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : parse_inputs
%
function [I,Method,Thresh,Sigma,Thinning,H,kx,ky] = parse_inputs(varargin)
% OUTPUTS:
%   I      Image Data
%   Method Edge detection method
%   Thresh Threshold value
%   Sigma  standard deviation of Gaussian
%   H      Filter for Zero-crossing detection
%   kx,ky  From Directionality vector

error(nargchk(1,5,nargin,'struct'));

I = varargin{1};

iptcheckinput(I,{'numeric','logical'},{'nonsparse','2d'},mfilename,'I',1);

% Defaults
Method='sobel';
Thresh=[];
Direction='both';
Thinning=true;
Sigma=2;
H=[];
K=[1 1];

methods = {'canny','prewitt','sobel','marr-hildreth','log','roberts','zerocross'};
directions = {'both','horizontal','vertical'};
options = {'thinning','nothinning'};

% Now parse the nargin-1 remaining input arguments

% First get the strings - we do this because the interpretation of the 
% rest of the arguments will depend on the method.
nonstr = [];   % ordered indices of non-string arguments
for i = 2:nargin
  if ischar(varargin{i})
    str = lower(varargin{i});
    j = strmatch(str,methods);
    k = strmatch(str,directions);
    l = strmatch(str,options);
    if ~isempty(j)
      Method = methods{j(1)};
      if strcmp(Method,'marr-hildreth')  
        wid = sprintf('Images:%s:obsoleteMarrHildrethSyntax', mfilename);
        msg = '''Marr-Hildreth'' is an obsolete syntax, use ''LoG'' instead.';
        warning(wid,'%s',msg);
      end
    elseif ~isempty(k)
      Direction = directions{k(1)};
    elseif ~isempty(l)
      if strcmp(options{l(1)},'thinning')
        Thinning = true;
      else
        Thinning = false;
      end
    else
      eid = sprintf('Images:%s:invalidInputString', mfilename);
      msg = sprintf('%s%s%s', 'Invalid input string: ''', varargin{i},'''.');
      error(eid,'%s',msg);
    end
  else
    nonstr = [nonstr i];
  end
end

% Now get the rest of the arguments 

eid_invalidArgs = sprintf('Images:%s:invalidInputArguments', mfilename);
msg_invalidArgs = 'Invalid input arguments';

  Sigma = 1.0;          % Default Std dev of gaussian for canny
  threshSpecified = 0;  % Threshold is not yet specified
  for i = nonstr
    if numel(varargin{i})==2 && ~threshSpecified
      Thresh = varargin{i};
      threshSpecified = 1;
    elseif numel(varargin{i})==1 
      if ~threshSpecified
        Thresh = varargin{i};
        threshSpecified = 1;
      else
        Sigma = varargin{i};
      end
    elseif isempty(varargin{i}) && ~threshSpecified
      threshSpecified = 1;
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end
  

if Sigma<=0
  eid = sprintf('Images:%s:sigmaMustBePositive', mfilename);
  msg = 'Sigma must be positive'; 
  error(eid,'%s',msg);
end

switch Direction
 case 'both',
  kx = K(1); ky = K(2); 
 case 'horizontal',
  kx = 0; ky = 1; % Directionality factor
 case 'vertical',
  kx = 1; ky = 0; % Directionality factor
 otherwise
  eid = sprintf('Images:%s:badDirectionString', mfilename);
  msg = 'Unrecognized direction string'; 
  error(eid,'%s',msg);
end
end
