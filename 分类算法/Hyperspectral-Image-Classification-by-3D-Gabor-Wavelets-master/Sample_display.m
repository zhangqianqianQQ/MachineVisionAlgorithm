%展示16个类别的平均能量曲线
clear energy x %避免上次生成的变量
xx=1:200;
for k=1:16
    energy(k,:)=Sample_show1(indian_pines_gt,indian_pines_corrected,k);
    x(k,:)=xx;
end
energy=energy';
 x=x';
plot(x,energy);
title('未经Gabor变换的16类地物的平均能量曲线');
legend('Alfalfa','Corn-notill','Corn-mintill','Corn','grass-pasture','Grass-trees,','Grass-pasture mowed','Hay-wndrowed','Oats','Soybean-notill','soybean-mintill','Soybean-clean','Wheat','Woods','Building-Grass-trees-drivers','Stone-Steel-Towers');
xlabel('频谱序号');
ylabel('能量均值');
clear k x xx;

                