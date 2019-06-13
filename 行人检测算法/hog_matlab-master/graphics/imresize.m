function [rout,g,b] = imresize(varargin)
%IMRESIZE Resize image.
%   B = IMRESIZE(A,M,'method') returns an image matrix that is 
%   M times larger (or smaller) than the image A.  The image B
%   is computed by interpolating using the method in the string
%   'method'.  Possible methods are 'nearest' (nearest neighbor),
%   'bilinear' (binlinear interpolation), or 'bicubic' (bicubic 
%   interpolation). B = IMRESIZE(A,M) uses 'nearest' as the 
%   default interpolation scheme.
%
%   B = IMRESIZE(A,[MROWS NCOLS],'method') returns a matrix of 
%   size MROWS-by-NCOLS.
%
%   RGB1 = IMRESIZE(RGB,...) resizes the RGB truecolor image 
%   stored in the 3-D array RGB, and returns a 3-D array (RGB1).
%
%   When the image size is being reduced, IMRESIZE lowpass filters
%   the image before interpolating to avoid aliasing. By default,
%   this filter is designed using FIR1, but can be specified 
%   using IMRESIZE(...,'method',H).  The default filter is 11-by-11.
%   IMRESIZE(...,'method',N) uses an N-by-N filter.
%   IMRESIZE(...,'method',0) turns off the filtering.
%   Unless a filter H is specified, IMRESIZE will not filter
%   when 'nearest' is used.
%   
%   See also IMZOOM, FIR1, INTERP2.

%   Grandfathered Syntaxes:
%
%   [R1,G1,B1] = IMRESIZE(R,G,B,M,'method') or 
%   [R1,G1,B1] = IMRESIZE(R,G,B,[MROWS NCOLS],'method') resizes
%   the RGB image in the matrices R,G,B.  'bilinear' is the
%   default interpolation method.

%   Clay M. Thompson 7-7-92
%   Copyright (c) 1992 by The MathWorks, Inc.
%   $Revision: 5.4 $  $Date: 1996/10/16 20:33:27 $

[A,m,method,classIn,h] = parse_inputs(varargin{:});

threeD = (ndims(A)==3); % Determine if input includes a 3-D array

if threeD,
   r = resizeImage(A(:,:,1),m,method,h);
   g = resizeImage(A(:,:,2),m,method,h);
   b = resizeImage(A(:,:,3),m,method,h);
   if nargout==0, 
      imshow(r,g,b);
      return;
   elseif nargout==1,
      if strcmp(classIn,'uint8');
         rout = repmat(uint8(0),[size(r),3]);
         rout(:,:,1) = uint8(round(r*255));
         rout(:,:,2) = uint8(round(g*255));
         rout(:,:,3) = uint8(round(b*255));
      else
         rout = zeros([size(r),3]);
         rout(:,:,1) = r;
         rout(:,:,2) = g;
         rout(:,:,3) = b;
      end
   else % nargout==3
      if strcmp(classIn,'uint8')
         rout = uint8(round(r*255)); 
         g = uint8(round(g*255)); 
         b = uint8(round(b*255)); 
      else
         rout = r;        % g,b are already defined correctly above
      end
   end
else 
   r = resizeImage(A,m,method,h);
   if nargout==0,
      imshow(r);
      return;
   end
   if strcmp(classIn,'uint8')
      r = uint8(round(r*255)); 
   end
   rout = r;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: resizeImage
%

function b = resizeImage(A,m,method,h)
% Inputs:
%         A       Input Image
%         m       resizing factor or 1-by-2 size vector
%         method  'nearest','bilinear', or 'bicubic'
%         h       the anti-aliasing filter to use.
%                 if h is zero, don't filter
%                 if h is an integer, design and use a filter of size h
%                 if h is empty, use default filter

if prod(size(m))==1,
   bsize = floor(m*size(A));
else
   bsize = m;
end

if any(size(bsize)~=[1 2]),
   error('M must be either a scalar multiplier or a 1-by-2 size vector.');
end

% values in bsize must be at least 1.
bsize = max(bsize, 1);

if (any((bsize < 4) & (bsize < size(A))) & ~strcmp(method, 'nea'))
   fprintf('Input is too small for bilinear or bicubic method;\n');
   fprintf('using nearest-neighbor method instead.\n');
   method = 'nea';
end

if isempty(h),
   nn = 11; % Default filter size
else
   if prod(size(h))==1, 
      nn = h; h = []; 
   else 
      nn = 0;
   end
end

[m,n] = size(A);

if nn>0 & method(1)=='b',  % Design anti-aliasing filter if necessary
   if bsize(1)1 | length(h2)>1, h = h1'*h2; else h = []; end
   if length(h1)>1 | length(h2)>1, 
      a = filter2(h1',filter2(h2,A)); 
   else 
      a = A; 
   end
elseif method(1)=='b' & (prod(size(h)) > 1),
   a = filter2(h,A);
else
   a = A;
end

if method(1)=='n', % Nearest neighbor interpolation
   dx = n/bsize(2); dy = m/bsize(1); 
   uu = (dx/2+.5):dx:n+.5; vv = (dy/2+.5):dy:m+.5;
elseif all(method == 'bil') | all(method == 'bic'),
   uu = 1:(n-1)/(bsize(2)-1):n; vv = 1:(m-1)/(bsize(1)-1):m;
else
   error(['Unknown interpolation method: ',method]);
end

%
% Interpolate in blocks
%
nu = length(uu); nv = length(vv);
blk = bestblk([nv nu]);
nblks = floor([nv nu]./blk); nrem = [nv nu] - nblks.*blk;
mblocks = nblks(1); nblocks = nblks(2);
mb = blk(1); nb = blk(2);

rows = 1:blk(1); b = zeros(nv,nu);
for i=0:mblocks,
   if i==mblocks, rows = (1:nrem(1)); end
   for j=0:nblocks,
      if j==0, cols = 1:blk(2); elseif j==nblocks, cols=(1:nrem(2)); end
      if ~isempty(rows) & ~isempty(cols)
         [u,v] = meshgrid(uu(j*nb+cols),vv(i*mb+rows));
         % Interpolate points
         if method(1) == 'n', % Nearest neighbor interpolation
            b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'*nearest');
         elseif all(method == 'bil'), % Bilinear interpolation
            b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'*linear');
         elseif all(method == 'bic'), % Bicubic interpolation
            b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'*cubic');
         end
      end
   end
end

if nargout==0,
   if isgray(b), imshow(b,size(colormap,1)), else imshow(b), end
   return
end

if isgray(A)   % This should always be true
   b = max(0,min(b,1));  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [A,m,method,classIn,h] = parse_inputs(varargin)
% Outputs:  A       the input image
%           m       the resize scaling factor or the new size
%           method  interpolation method (nearest,bilinear,bicubic)
%           class   storage class of A
%           h       if 0, skip filtering; if non-zero scalar, use filter 
%                   of size h; otherwise h is the anti-aliasing filter.

switch nargin
case 2,                        % imresize(A,m)
   A = varargin{1};
   m = varargin{2};
   method = 'nearest';
   classIn = class(A);
   h = [];
case 3,                        % imresize(A,m,method)
   A = varargin{1};
   m = varargin{2};
   method = varargin{3};
   classIn = class(A);
   h = [];
case 4,
   if isstr(varargin{3})       % imresize(A,m,method,h)
      A = varargin{1};
      m = varargin{2};
      method = varargin{3};
      classIn = class(A);
      h = varargin{4};
   else                        % imresize(r,g,b,m)
      for i=1:3
         if isa(varargin{i},'uint8')
            error('Please use 3-d RGB array syntax with uint8 image data');
         end
      end
      A = zeros([size(varargin{1}),3]);
      A(:,:,1) = varargin{1};
      A(:,:,2) = varargin{2};
      A(:,:,3) = varargin{3};
      m = varargin{4};
      method = 'nearest';
      classIn = class(A);
      h = [];
   end
case 5,                        % imresize(r,g,b,m,'method')
   for i=1:3
      if isa(varargin{i},'uint8')
         error('Please use 3-d RGB array syntax with uint8 image data');
      end
   end
   A = zeros([size(varargin{1}),3]);
   A(:,:,1) = varargin{1};
   A(:,:,2) = varargin{2};
   A(:,:,3) = varargin{3};
   m = varargin{4};
   method = varargin{5};
   classIn = class(A);
   h = [];
case 6,                        % imresize(r,g,b,m,'method',h)
   for i=1:3
      if isa(varargin{i},'uint8')
         error('Please use 3-d RGB array syntax with uint8 image data');
      end
   end
   A = zeros([size(varargin{1}),3]);
   A(:,:,1) = varargin{1};
   A(:,:,2) = varargin{2};
   A(:,:,3) = varargin{3};
   m = varargin{4};
   method = varargin{5};
   classIn = class(A);
   h = varargin{6};
otherwise,
   error('Invalid input arguments.');
end

if isa(A, 'uint8'),     % Convert A to Double grayscale for filtering & interpolation
   A = double(A)/255;
end

method = [lower(method),'   ']; % Protect against short method
method = method(1:3);