function varargout = plotellipse(varargin)
%PLOTELLIPSE   Plot parametrically specified ellipse
%
%   PLOTELLIPSE(Z, A, B, ALPHA) Plots the ellipse specified by Z, A, B,
%       ALPHA (as returned by FITELLIPSE)
%
%       A, B are positive scalars, Z a 2x1 column vector, and
%       ALPHA a rotation angle, such that the equation of the ellipse is:
%           X = Z + Q(ALPHA) * [A * cos(phi); B * sin(phi)]
%       where Q(ALPHA) is the rotation matrix
%           Q(ALPHA) = [cos(ALPHA) -sin(ALPHA);
%                       sin(AlPHA) cos(ALPHA)]
%
%   PLOTELLIPSE(..., LineSpec) passes the LineSpec string to the plot
%       command (e.g. 'r--')
%   
%   H = PLOTELLIPSE(...) returns a handle to the created lineseries object
%       created by the plot command
%   
%   Example:
%       % Ellipse centred at 10,10, with semiaxes 5 and 3, rotated by pi/4
%       a = 5;
%       b = 3;
%       z = [10; 10]
%       alpha = pi/4;
%       plotellipse(z, a, b, alpha)
%
%   See also FITELLIPSE

% Copyright Richard Brown. This code can be freely reused and modified so
% long as it retains this copyright clause

error(nargchk(4, 6, nargin, 'struct'));
error(nargchk(0, 1, nargout, 'struct'));

% Ellipse centre
z = varargin{1};
z = z(:); 
if length(z) ~= 2
    error('plotellipse:InvalidCentre', ...
        'Ellipse center must be a 2 element column vector');
end

a = varargin{2};
b = varargin{3};
if ~isscalar(a) || ~isscalar(b) || a < 0 || b < 0
    error('plotellipse:InvalidAxes', ...
        'A, B must be real, positive scalars');
end

alpha = varargin{4};
if ~isscalar(alpha)
    error('plotellipse:InvalidConstant', ...
        'Rotation angle alpha must be a real scalar, in radians');
end
varargin(1:4) = [];

% See if a linespec is supplied
if ~isempty(varargin)
    linespec = varargin{1};
else
    linespec = '';
end

% form the parameter vector
npts = 100;
t = linspace(0, 2*pi, npts);

% Rotation matrix
Q = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
% Ellipse points
X = Q * [a * cos(t); b * sin(t)] + repmat(z, 1, npts);

% The actual plotting one-liner
h = plot(X(2,:), X(1,:), linespec, 'LineWidth', 1);

% Return the handle if asked for
if nargout == 1
    varargout = {h};
end