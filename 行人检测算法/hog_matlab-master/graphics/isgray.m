function y = isgray(x)
%ISGRAY True for intensity images.
%	ISGRAY(A) returns 1 if A is an intensity image and 0 otherwise.
%	An intensity image contains values between 0.0 and 1.0.
%
%	See also ISIND, ISBW.

%	Clay M. Thompson 2-25-93
%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 1993/08/18 03:11:32 $

y = min(min(x))>=0 & max(max(x))<=1;