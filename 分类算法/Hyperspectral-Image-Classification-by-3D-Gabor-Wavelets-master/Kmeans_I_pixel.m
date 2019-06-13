function [ correct_rate,label_gt ] =Kmeans_I_pixel( sample,sample_rate,varargin )
%Kmeans_I_pixel对indian_pines图像中的样本点进行k均值分类，维数为200xn维(n为选择的方向数)
%类别数（一般16类，不包括背景）
%在测试准确率时时调用，也可直接对全部Gabor特征调用
%输入分类矩阵sample，是a（x,y,b,dir）结构，一般为145x145x200x(选取的方向数),sample_rate为样本sample中选取的比例
%返回错误率error_rate（1x1）,和分类标签矩阵label_gt(145x145)
%调用error函数确定错误率，Random_I函数随机生成样本
%!!!!!!!varargin模式仅在对每个小波分别进行分类能力测试时使用，此时dir=1
%分类的样本数为145x145，维数为200xn（n为选择的方向数),需要预先生成
%-------------------------------------------------------------------------

global indian_pines_gt;  %声明标准标签矩阵，用于比对
dir_num=min(size(sample));%获取样本使用小波的方向数目
if (nargin==3) %单独小波测试模式
    dir_num=1;
end

[sample_selected,sample_num]=Random_I(sample_rate);  %调用Random_I函数以rate比例随机生成样本，sample_seleced为选取样本的标签矩阵145x145，sample_num为每类样本的数目1x16
distance=zeros(1,16);

%根据选择样本初始化每类中心
center=zeros(16,200,dir_num);
label_gt=zeros(145, 145);

for x=1:145
    for y=1:145
        if (sample_selected(x,y)==1)  %是选中的样本
            label_gt(x,y)=indian_pines_gt(x,y);  %不用分类,直接写标签
            center(indian_pines_gt(x,y),:,:)=reshape(center(indian_pines_gt(x,y),:,:),200,dir_num)+reshape(sample(x,y,:,:),200,dir_num); 
        end
    end
end

for k=1:16
center(k,:,:)=reshape(center(k,:,:),200,dir_num)./sample_num(k);  %平均得到中心
end

class_num=zeros(1,16);

for x=1:145
    for y=1:145
       %对于每一个点
       if (indian_pines_gt(x,y)~=0  && ~sample_selected(x,y)) %不是背景点,不是样本点
       for kkk=1:16
           %计算与每一类中心的距离
           temp1=reshape(center(kkk,:,:),200,dir_num);
           temp2=reshape(sample(x,y,:,:),200,dir_num);
           temp3=temp1-temp2;
           distance(kkk)=sum(sum(temp3.^2))/(200*dir_num);
       end
       label=find(distance==min(distance));  %记录最小距离所属的标签号
       label_gt(x,y)=label;   %将该类分到所属类别的标签中去
        %确定新一类的中心(加权平均)
       sum_temp=reshape(center(label,:,:),200,dir_num).*class_num(label)+reshape(sample(x,y,:,:),200,dir_num);
       class_num(label)=class_num(label)+1;  %该类数目+1
       center(label,:,:)=sum_temp./class_num(label);
       end
       %下一点
    end
%     fprintf('%0.2f\n',x);
end

error_rate=Error_I(label_gt);
correct_rate=1-error_rate;



end

