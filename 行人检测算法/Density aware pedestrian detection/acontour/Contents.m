%Active Contour Toolbox
%By Eric Debreuve
%http://www.i3s.unice.fr/~debreuve/
%
%Toolbox dependency:
%   Polygon Toolbox (by the same author),
%   Images & Splines Toolboxes (The MathWorks, Inc.).
%
%Scope:
%   This toolbox provides some functions for manipulating planar, closed splines
%   to implement image or video segmentation by means of deformable (or active)
%   contours. Contour topology is managed in a way that should allow changes
%   similar to what can be observed with level sets (merging and splitting but
%   no hole creation). Several objects can be segmented simultaneously in
%   several frames.
%
%Naming conventions:
%   The functions of this toolbox all have the prefix ac_. Optional arguments,
%   either input or output, have the prefix o_ (private function, subfunctions
%   and nested functions have the prefix p_, s_, and n_, respectively, and
%   callback functions have the prefix c_).
%   Nothing in the active contour representation (see below) makes it active. It
%   is active only because functions are provided to deform it (typically,
%   ac_deformation). The expression "active contour" is used even in cases where
%   the fact that the contour is intended to evolve is irrelevant (e.g.,
%   ac_length).
%
%Active contour representation:
%   An active contour is a struct array of closed, 2-D-valued, 1-D, non
%   self-intersecting splines in pp-form. The splines must not intersect each
%   other either. Each structure composing an active contour is called a single
%   (active) contour. Several active contours can be grouped together in a cell
%   array. If 'a' is a cell array, then length(a) is the number of active
%   contours contained in 'a'. Otherwise, 'a' is a struct array and length(a) is
%   the number of single active contours composing 'a'.
%
%Instantiation:
%   ac_isocontour   - active contour describing a level set of a frame
%
%Property:
%   ac_validity     - check for validity of an active contour
%   ac_length       - length of an active contour
%   ac_area         - signed area of an active contour
%   ac_sampling     - sampling of an active contour: breaks, samples, tangents,
%                     normals, and curvatures available
%
%   ac_energy       - storage and plot of the energy of a set of active contours
%                     and evaluation of a stopping criterion
%   ac_evolution    - storage, properties, and plot of the evolution of a set of
%                     active contours
%
%Transformation:
%   ac_clipping     - clipping of an active contour
%   ac_resampling   - approximately regular resampling of an active contour
%                     using a given number of samples or a sample every some
%                     pixels
%   ac_deformation  - deformation of an active contour with topology management
%
%Plot:
%   ac_plot         - active contour plot: samples, edges, sample indices,
%                     tangents, and normals available
%
%Conversion:
%   ac_mask         - binary mask of an active contour
%
%Segmentation:
%   ac_segmentation - segmentation of a (set of) frame(s) by a (set of) active
%                     contour(s)
%   ac_usage_mean   - sample functions implementing segmentation/evolution
%   ac_usage_mean_basic - 
%   ac_usage_minlength  - 
%
%Interface:
%   gi_shape        - graphical interface for instantiating a polygon, a spline,
%                     or a mask
%   gi_acontour     - graphical interface for ac_segmentation
%
%
%Last update: July 4, 2006
