function [ rate ] = Error_I( indian_pines_gt2 )
%此函数统计错误率，用于k均值分类
%输入变量为依靠分类生成的标签矩阵，全局变量indian_pines_gt为标准的标签矩阵，都为145x145矩阵
%错误率计算方法：
%        分错+1，分对+0
%在均值分类中调用

global indian_pines_gt;


rate=0;
for k=1:145
    for kk=1:145
        if (indian_pines_gt(k,kk)~=indian_pines_gt2(k,kk))
            rate=rate+1;
        end
    end
end

rate=rate/(145*145);

end

