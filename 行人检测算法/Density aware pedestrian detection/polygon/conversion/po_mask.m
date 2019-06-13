function mask = po_mask(polygon, mask_size)
%po_mask: conversion of a closed polygon into a binary mask
%   m = po_mask(p, m_size) computes the binary mask, m, of a closed polygon, p.
%   Actually, since po_mask calls the Matlab function poly2mask, the polygon is
%   automatically closed if not already. The size of m is given by m_size.
%   m_size can be a 1x2 or a 2x1 matrix. Unlike poly2mask, the class of m is
%   double.
%
%   This function was written only to account for the interpretation of vertex
%   coordinates made by the polygon toolbox (type: 'help polygon' for more
%   information). The mask is actually computed by poly2mask.
%
%See also polygon, poly2mask.
%
%Polygon Toolbox by Eric Debreuve
%Last update: June 14, 2006

mask = double(poly2mask(polygon(2,:), polygon(1,:), mask_size(1), mask_size(2)));
