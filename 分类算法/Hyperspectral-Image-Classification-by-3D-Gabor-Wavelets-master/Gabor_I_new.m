%对Indian_Pine中的点进行Gabor小波变换，并且存储结果矩阵
%变换窗为12x12（取每个窗的（6,6）为中心变换点），不能构成窗的边缘点去除，每次生成一个点的G对于一个Gabor小波的Gabor响应
%若中心点是背景点，则不参与此次计算
%逐波段进行变换
%本程序在Indian_Pine.m中运行，使用之前首先要调用IO程序导入图像矩阵
%本程序的生成
%sigma=1

clc;
global indian_pines_gaborall;
%52个方向的小波

for dir=1:52
    indian_pines_gaborall(1:145,1:145,1:200,dir)=G_I(dir);   %indian_pines_gaborall存储所有的gabor特征，数据结构为（x,y,b,dir）
    fprintf('band %2.0f is completed!\n',dir);
end

%M为建立的数据结构，是1x52的向量
%M{dir}表示对应dir方向的Gabor响应，是145x145x200的立方体
%M{dir}(x,y,:)是1x200的向量（论文中的m），表示在一个点 在各个波段上 对于一个方向的小波 的响应，如此访问
%接下来就行方向层面的特征选择
save('indian_pines_gaborall.mat','indian_pines_gaborall');

clear dir; %清除变量