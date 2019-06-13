function snakedisp(x,y,style)
%--------Display the snake model contour-----------

hold on

% convert to column data
x = x(:); y = y(:);

if nargin == 3          %nargin returns the number of input arguments specified for a function
   plot([x;x(1,1)],[y;y(1,1)],style);
   hold off
else
   disp('snakedisp.m: The input parameter is not correct!'); 
end
