function [ indian_pines_sample_gt, num_class_rate ] = Random_I( rate )
%此函数负责随机选取一定比例的indian_pine样本
%输入rate为选取的比例,输出indian_pines_sample_gt为样本集合的标签,为145x145矩阵，num_class为每一类的个数(16x1)
%先执行IO.m，除外部输入参数外不再依赖其他函数或文件

%统计每类样本的个数
global indian_pines_gt;
indian_pines_sample_gt=zeros(145,145);
num_class=zeros(1,16);
for k=1:145 
    for kk=1:145
        if (indian_pines_gt(k,kk))
        num_class(indian_pines_gt(k,kk))=num_class(indian_pines_gt(k,kk))+1;
        end
    end
end

num_class_rate=fix(num_class.*rate);  %确定每一类样本需要选取的个数

for k=1:16
    %在每类的总数中随机抽取几个数，作为选中样本的序号
    temp=randperm(num_class(k));
    r=[];
    r=temp(1:num_class_rate(k));
    num_class_rate(k)=length(unique(r));
    order(k,:)={r};  %order存储了所有选取样本的序号

    
end


sample_record=zeros(1,16);  %计数变量，记录样本出现的次序

    for kk=1:145
        for kkk=1:145  %将标签矩阵中相应类的序号样本的定为1
            if (indian_pines_gt(kk,kkk)) %不是背景点
                tag=sample_record(indian_pines_gt(kk,kkk));%该类中此样本出现的序号
                if (any(tag==order{indian_pines_gt(kk,kkk),:})) %此号为随机选中的样本
                    indian_pines_sample_gt(kk,kkk)=1;
                end
                sample_record(indian_pines_gt(kk,kkk))=sample_record(indian_pines_gt(kk,kkk))+1;
            end
        end
    end
  
    
end

