%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Cumulative_sum：计算指定半径的累积和
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cumulative_sum = My_cumulative_sum(input, r)

    % output(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
    % 和colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum)函数实现一样的功能，但是速度非常快;
   

    [height, width] = size(input);
    Cumulative_sum = zeros(size(input));

    % 计算列的累积和
    cumulative = cumsum(input, 1);
    % 计算列的导数
    Cumulative_sum(1:r+1, :) = cumulative(1+r:2*r+1, :);
    Cumulative_sum(r+2:height-r, :) = cumulative(2*r+2:height, :) - cumulative(1:height-2*r-1, :);
    Cumulative_sum(height-r+1:height, :) = repmat(cumulative(height, :), [r, 1]) ...
                                            - cumulative(height-2*r:height-r-1, :);

    % 计算行的累积和
    cumulative = cumsum(Cumulative_sum, 2);
    % 计算行的导数
    Cumulative_sum(:, 1:r+1) = cumulative(:, 1+r:2*r+1);
    Cumulative_sum(:, r+2:width-r) = cumulative(:, 2*r+2:width) - cumulative(:, 1:width-2*r-1);
    Cumulative_sum(:, width-r+1:width) = repmat(cumulative(:, width), [1, r])...
                                            - cumulative(:, width-2*r:width-r-1);
end

