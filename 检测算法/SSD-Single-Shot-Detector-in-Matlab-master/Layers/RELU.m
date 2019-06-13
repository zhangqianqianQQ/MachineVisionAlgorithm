%% 
%------------------RELU------------------
%作  者：杨帆
%公  司：BJTU
%功  能：RELU激活函数。
%输  入：
%       in_array    -----> 输入高维数组（dim = 3）。
%输  出：
%       out_array   -----> 输出高维数组（dim = 3）。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function out_array = RELU(in_array)
    out_array = max(0, in_array);
end