%==========================================================================
% 函数名:normalizing.m
% 功能：
%     实现数据的归一化，把数据,由[small_in,large_in]映射到[small_out,large_out]
% 参数：
%     data:数据
%     small_out,large_out：是原数据data通过映射得到y的范围
%     small_in,large_in：是原数据data输入的范围，可以是默认
% =========================================================================
function [data_out,small_in,large_in]=normalizing(data,small_out,large_out,small_in,large_in)
%判断维数
size_data=size(size(data));
if size_data(1,2)==4
    max_data=max(max(max(max(data))));
    min_data=min(min(min(min(data))));
end
if size_data(1,2)==3
    max_data=max(max(max(data)));
    min_data=min(min(min(data)));
end
if size_data(1,2)==2
    max_data=max(max(data));
    min_data=min(min(data));
end
if size_data(1,2)==1
     max_data=max(data);
     min_data=min(data);
end
if nargin==3
    small_in=min_data;
    large_in=max_data;
end
data_out=(data-small_in)*(large_out-small_out)/(large_in-small_in)+small_out;


