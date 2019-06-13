function [ average_result ] = average( inputcell )
%计算输入元组的平均值
times = numel(inputcell);
temp = 0;
for iter = 1:times
    temp = temp + inputcell{iter}(1);
end
average_result = temp / times;
end

