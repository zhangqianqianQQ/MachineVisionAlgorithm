function integralImage = computeIntegralImage(image, norm)
% This function computes the integralImage given an image in input and
% evntually normalize it if the flag norm is true.

% First we pad the image this is tricky because when we compute the area of
% the a patch using the size we don't stick to the corner coordinates.
% 
%
%     000000000000000000000000000000
%     0#############################
%     0#           |               #
%     0#   SUM     |               #
%     0#           |               #
%     0#-----------x               #
%     0#                           #
%     0#############################
% 
% 

image = padarray(image, [1 1], 0, 'pre');
[rows, columns, dimensions] = size(image);
integralImage = zeros(size(image));
image=double(image);


% For each row we compute the cumulative sum 
% so for example if our row is : 1 1 1
% the cumulative sum is going to be: 1 2 3
for i = 1:rows
    cumulative_row_sum = cumsum(double(image(i, :)));
    if i == 1
       integralImage(i, :) = cumulative_row_sum;
    else
        for j = 1:columns
           integralImage(i, j) = integralImage(i-1, j) + cumulative_row_sum(j) ;
        end
    end
end

% We normalize if the flag is true (this is done if we want to display the result)
if norm==true
    integralImage = 255*(integralImage - min(integralImage(:))) / (max(integralImage(:)) - min(integralImage(:)));
    integralImage = uint8(integralImage);
end

end