function [ y_avg] = Sample_show1( indian_pines_gt,indian_pines_corrected,label )
%求一种地物的平均能量，200波段,返回平均能量1x200向量
x=1:200;
pos=1;
for kkk=1:145
    for kk=1:145
        if(indian_pines_gt(kkk,kk)==label)
            for k=1:200
                y(pos,k)=indian_pines_corrected(kkk,kk,k);
            end
            pos=pos+1;
        end
    end
end
pos=pos-1; %最后一个+1要减去,y为posx200的矩阵

for k=1:200
    y_avg(k)=mean(y(:,k));
end

clear k kk kkk;
end

