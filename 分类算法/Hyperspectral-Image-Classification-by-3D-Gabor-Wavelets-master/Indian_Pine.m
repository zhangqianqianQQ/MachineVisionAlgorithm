%此脚本是Indian_Pine的最外层脚本
%此脚本完成数据的格式建立，标记/测试样本的建立与大小设置
%最后此脚本完成一系列统计工作

%directed by: Xiangrong Zhang,associate professor, Xidian University
%created by: Jackson Lee,Xidian Universit, 2013.4.22
%contact: schmidt.liez@gmail.com
%--------------------------------------------------------------------------

%% 预展示部分，不涉及计算与分类操作
clc;
clear all;

IO_I; %数据已经读入，indian_pines_corrected是145x145x200的三维矩阵，indian_pines_gt是145x145的标签矩阵，0类表示不是样本点
Sample_display; %先展示没有Gabor变换的16类信号能量曲线，图像的结构信息
Sample_Gabor100_show; %详细展示（1,0,0）方向的小波，与频率响应
Sample_gaborshow_52; %简单展示所有用到的52方向小波的形状

%% 计算部分，计算gabor特征并且存储结果
clear all;
clc;   %清除展示中生成的变量，重新准备工作空间，准备计算与分类
IO_I;
%Gabor_I_new;  %得到所有52的方向的Gabor特征  （此步骤耗时较长，可以预先执行）
load Indian_pines_gaborall52;

%% 不经过特征选择的分类与展示

%展示每个小波的选择能力,每个结果取十次平均，样本率分别为5%，10%，25%，50%，75%
random_rate=[0.05,0.1,0.25,0.5,0.75];
knn_result_gabor52alone=zeros(52,5);
for dir=1:52
    for rr=1:5
        accuracy=0;
        for time=1:10
            %针对每一个小波进行分类，取结果平均
            accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborall(:,:,:,dir),random_rate(rr),1);  %使用Kmeans_I_pixel的第三个参数，启用独立小波测试
        end
        knn_result_gabor52alone(dir,rr)=accuracy/10;  %得到一个小波在一个比例样本上的平均正确率
        fprintf('%0.2f',rr);
    end
    fprintf('\n');
    disp(knn_result_gabor52alone(dir,:));
end

save('knn_result_gabor52alone.mat','knn_result_gabor52alone');

%使用全部52特征的分类能力
knn_result_gaborall=zeros(1,5);
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborall,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_gaborall(rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
save('knn_result_gaborall.mat','result52');


figure;
plot(knn_result_gabor52alone(:,1),'-b*');
hold on;
plot(knn_result_gabor52alone(:,2),'-rx');
hold on;
plot(knn_result_gabor52alone(:,3),'-k+');
hold on;
plot(knn_result_gabor52alone(:,4),'-cs');
hold on;
plot(knn_result_gabor52alone(:,5),'-m^');
hold on;
for k=1:5
    fplot(@(x)result_gaborall(k),[0,52,0,1],'--r');
    hold on;
end
title('52个小波各自的分类能力(取十次平均)');
axis([0,52,0.5,1]);
legend('5%','10%','25%','50%','75%','全部特征的分类水平');
clear dir rr accuracy time random_rate kk;
clear k x;



%% 特征选择部分,分别选择不同的规模，进行3次，储存结果

%该过程较慢，可以选择加载结果矩阵
for t=1:3
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(3); 
fileName1=sprintf('indian_pines_gaborsel3_%s',num2str(t));   %产生文件名字符串
fileName2=sprintf('indian_pines_gaborsel3_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');  %储存结果
save(fileName2,'f_sel_gt');
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(5);
fileName1=sprintf('indian_pines_gaborsel5_%s',num2str(t));   %产生文件名字符串
fileName2=sprintf('indian_pines_gaborsel5_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');
save(fileName2,'f_sel_gt');
[indian_pines_gaborsel,f_sel_gt]=Feature_sel_I(10);
fileName1=sprintf('indian_pines_gaborsel10_%s',num2str(t));   %产生文件名字符串
fileName2=sprintf('indian_pines_gaborsel10_%s_gt',num2str(t));
save(fileName1,'indian_pines_gaborsel');
save(fileName2,'f_sel_gt');
end
clear t;
clc;  

%% 经过特征选择的分类

%替代直接产生的数据
load indian_pines_gaborsel3_1;
load indian_pines_gaborsel3_1_gt;
load indian_pines_gaborsel3_2;
load indian_pines_gaborsel3_2_gt;
load indian_pines_gaborsel3_3;
load indian_pines_gaborsel3_3_gt;
load indian_pines_gaborsel5_1;
load indian_pines_gaborsel5_1_gt;
load indian_pines_gaborsel5_2;
load indian_pines_gaborsel5_2_gt;
load indian_pines_gaborsel5_3;
load indian_pines_gaborsel5_3_gt;
load indian_pines_gaborsel10_1;
load indian_pines_gaborsel10_1_gt;
load indian_pines_gaborsel10_2;
load indian_pines_gaborsel10_2_gt;
load indian_pines_gaborsel10_3;
load indian_pines_gaborsel10_3_gt;


%用特征选择的结果进行分类
knn_result_sel=zeros(9,5);
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_1,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(1,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_2,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(2,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel3_3,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(3,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_1,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(4,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_2,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(5,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel5_3,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(6,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_1,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(7,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_2,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(8,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end
for rr=1:5
    accuracy=0;
    for kk=1:10
        accuracy=accuracy+Kmeans_I_pixel(indian_pines_gaborsel10_3,random_rate(rr)); %使用全部特征进行分类
    end
    knn_result_sel(9,rr)=accuracy/10;
    fprintf('%0.2f\n',k);
end

save('knn_result_sel.mat','knn_result_sel');

%% 经过选择的结果与未经选择的结果对比

load knn_result_gaborall;
load knn_result_sel.mat;
%画未经选择的特征的曲线
for k=1:5
    fplot(@(x)knn_result_gaborall(k),[1,5,0.65,1],'--r');
    hold on;
end
set(gca,'XTickLabel',{'0.05','','0.1','','0.25','','0.5','','0.75'});  %调整x轴显示坐标
xlabel('样本比例');
ylabel('正确率');
title('特征选择前后的正确率对比');
hold on;

%画经过选择的样本的分类正确率曲线
x=1:5;
plot(x,knn_result_gaborsel,'--x');
hold on;

%% SVM部分

%测试原始波段的SVM分类
clear all;
IO_I;
accuracy=zeros(1,4);
sample_rate=[0.05,0.1,0.25,0.5];

for k=1:4
    for kk=1:10  %十次取平均
        accuracy(k)=accuracy(k)+SVM_I_perdir(sample_rate(k),indian_pines_gt,indian_pines_corrected);
    end
    accuracy(k)=accuracy(k)./10;
end
save('svm_accuracy_spec.mat','acccuracy');
disp(accuracy);

%测试每个方向的SVM分类

clear all;
IO_I;
load indian_pines_gaborall52;
load indian_pines_gaborall52;
global indian_pines_gaborall;
accuracy=zeros(4,52);
sample_rate=[0.05,0.1,0.25,0.5];

for k=1:4
    for kk=1:52  
        for kkk=1:10
        accuracy(k,kk)=accuracy(k,kk)+SVM_I_perdir_52(sample_rate(k),indian_pines_gt,kk);
        end
    end
end
accuracy=accuracy./10;

save('svm_accuracy_perband.mat','accuracy');


%测试特征简化后的分类（共有9个数据集合)

accuracy=zeros(9,5);
sample_rate=[0.05,0.1,0.25,0.5,0.75];
load indian_pines_gaborsel3-1;
for k=1:5
    for kk=1:10
        accuracy(1,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel3-2;
for k=1:5
    for kk=1:10
        accuracy(2,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel3-3;
for k=1:5
    for kk=1:10
        accuracy(3,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-1;
for k=1:5
    for kk=1:10
        accuracy(4,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-2;
for k=1:5
    for kk=1:10
        accuracy(5,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel5-3;
for k=1:5
    for kk=1:10
        accuracy(6,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-1;
for k=1:5
    for kk=1:10
        accuracy(7,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-2;
for k=1:5
    for kk=1:10
        accuracy(8,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end

load indian_pines_gaborsel10-3;
for k=1:5
    for kk=1:10
        accuracy(9,k)=accuracy(2,k)+SVM_I_perdir_sel(sample_rate(k),indian_pines_gt,indian_pines_gaborsel);
    end
    disp(k);
end
accuracy=accuracy./10;
%保存结果
save('svm_accuracy_sel.mat','accuracy');
clc;
clear all;
%% SVM与KNN比较

%使用全部52特征的SVM分类能力
load svm_accuracy_perband.mat;
figure;

x=[1:52];
plot(x,accuracy(1,:),'-*b');
hold on;
plot(x,accuracy(2,:),'-*c');
hold on;
plot(x,accuracy(3,:),'-*g');
hold on;
plot(x,accuracy(4,:),'-*r');
hold on;


title('SVM下52个小波各自的分类能力(取十次平均)');
axis([0,52,0,1]);
legend('5%','10%','25%','50%');
clear x;


%SVM与KNN在特征选择之后的比较
load knn_result_gaborsel;
load svm_accuracy_sel;

knn(1,:)=sum(knn_result_gaborsel(1:3,:));
knn(2,:)=sum(knn_result_gaborsel(4:6,:));
knn(3,:)=sum(knn_result_gaborsel(7:9,:));

svm(1,:)=sum(accuracy(1:3,:));
svm(2,:)=sum(accuracy(4:6,:));
svm(3,:)=sum(accuracy(7:9,:));
knn=knn./3;
svm=svm./3;

x=[1:5];
figure;
plot(x,knn(1,:),'-*k');
hold on;
plot(x,svm(1,:),'-sr');
hold on;
plot(x,knn(2,:),'-*k');
hold on;
plot(x,knn(3,:),'-*k');
hold on;
plot(x,svm(2,:),'-sr');
hold on;
plot(x,svm(3,:),'-sr');
hold on;

title('经过特征选择后SVM与KNN的分类能力比较');
axis([1,5,0.65,1]);
set(gca,'XTickLabel',{'0.05','','0.1','','0.25','','0.5','','0.75'});
legend('knn','svm');
clear k x knn svm;




