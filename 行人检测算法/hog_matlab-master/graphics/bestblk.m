function [mb,nb] = bestblk(siz,k)
%BESTBLK Best block size for block processing.
%	BLK = BESTBLK([M N],K) returns the 1-by-2 block size BLK
%	closest to but smaller than K-by-K for block processing.
%
%	[MB,NB] = BESTBLK([M N],K) returns the best block size
%	as the two scalars MB and NB.
%
%	[...] = BESTBLK([M N]) returns the best block size smaller
%	than 100-by-100.
%
%	BESTBLK returns the M or N when they are already smaller
%	than K.
%
%	See also BLKPROC, SIZE.

%	Clay M. Thompson
%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1994/03/04 19:54:04 $

if nargin==1, k = 100; end % Default block size

%
% Find possible factors of siz that make good blocks
%

% Define acceptable block sizes
m = floor(k):-1:floor(min(ceil(siz(1)/10),k/2));
n = floor(k):-1:floor(min(ceil(siz(2)/10),k/2));

% Choose that largest acceptable block that has the minimum padding.
[dum,ndx] = min(ceil(siz(1)./m).*m-siz(1)); blk(1) = m(ndx);
[dum,ndx] = min(ceil(siz(2)./n).*n-siz(2)); blk(2) = n(ndx);

if nargout==2,
  mb = blk(1); nb = blk(2);
else
  mb = blk;
end