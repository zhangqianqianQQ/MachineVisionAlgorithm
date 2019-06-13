function [ cen ] = Center_I(F_sel)
%Center_I 确定每一类的中心，用于k均值分类
%全局变量 M_g，图像的所有Gabor特征1x52，
%输入参数F_sel表示被选中的特征1xn，输出cen表示类别中心
%由kmeans_I函数调用,145x145x200维的特征分类

global indian_pines_gaborall;


cen=zeros(1,145,145,200);  %cen的第一维不作为数据，仅仅为何与数据结构相符而设置
for k=1:2
    if(find(F_sel==k))
        cen=cen+indian_pines_gaborall(k,:,:,:);   %如果该特征属于被选范围，则累加
    end
end

cen=cen./length(F_sel);

end

