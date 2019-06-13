%Polygon Toolbox
%By Eric Debreuve
%http://www.i3s.unice.fr/~debreuve/
%
%Toolbox dependency:
%   None.
%
%Scope:
%   This toolbox is not a general-purpose toolbox for manipulating polygons. It
%   just provides a minimal set of functions dedicated to closed polygons to
%   support the Active contour toolbox (by the same author). Only the plotting
%   function also supports open polygons.
%
%Naming conventions:
%   The functions of this toolbox all have the prefix po_. Optional arguments,
%   either input or output, have the prefix o_ (private function, subfunctions
%   and nested functions have the prefix p_, s_, and n_, respectively, and
%   callback functions have the prefix c_).
%
%Polygon representation (system of coordinates):
%   A polygon p with n vertices is represented by a 2 x (n+1) matrix of class
%   double where isequal(p(:,1), p(:,end)) is true. There are 2 main choices for
%   the system of coordinates: the matrix row x column convention and the
%   classical (x,y) system of coordinates. Since a polygon is to be interpreted
%   as a contour segmenting an image or a video frame (typically a matrix), the
%   matrix convention was chosen to prevent any confusion between two different
%   systems of coordinates. That is, the first coordinate of the i^th vertex,
%   p(1,i), is taken along a vertical axis oriented positively from top to
%   bottom and ranging from 1 to size(f,1) if the polygon is to be superimposed
%   on a frame f. Its second coordinate, p(2,i), is taken along an horizontal
%   axis oriented positively from left to right and ranging from 1 to size(f,2).
%
%Instantiation:
%   po_square      - closed polygon sampling a square, possibly tilted
%   po_rectangle   - closed polygon sampling a rectangle, possibly tilted
%   po_rouctangle  - closed polygon sampling a rectangle with "rounded" corners,
%                    possibly tilted
%   po_circle      - closed polygon sampling a circle
%   po_ellipse     - closed polygon sampling an ellipse, possibly tilted
%   po_isocontour  - (set of) closed polygon(s) sampling a level set of a frame
%
%Property:
%   po_orientation - orientation of a closed polygon as a positive or negative
%                    real number
%   po_simple      - test of closed polygon (non) self-intersection
%
%Transformation:
%   po_orientation - setting of orientation of a closed polygon
%
%Plot:
%   po_plot        - open/closed polygon plot: vertices, edges, and vertex
%                    indices available
%
%Conversion:
%   po_mask        - binary mask of a closed polygon
%
%
%Last update: June 16, 2006
