%I = imread('CLRIS012.jpg');
clear;clc;
img = imread('D:\MATLAB源程序\DRIVE\test\images\01_test.tif');%CLRIS002.jpg');%
mask = imread('D:\MATLAB源程序\DRIVE\test\mask\01_test_mask.gif');
[lm,ln,lq]=size(img);
for q=1:3
for i=1:lm
   for j=1:ln
       if mask(i,j)== 0
           img(i,j,q)=img(i,j,q)&mask(i,j);
       end
   end
end
end
figure;
imshow(img);
img2=img(:,:,1);
%may=img;
img=rgb2hsv(img);
img1=img;
% %cform2lab = makecform('srgb2lab');
% %LAB = applycform(img, cform2lab);
% L = LAB(:,:,1);
% LAB(:,:,1) = adapthisteq(L);
% cform2srgb = makecform('lab2srgb');
% J = applycform(LAB, cform2srgb);
%figure;
img = img(:,:,1);
img3=img;
imshow(img);
%img=J;
%img=rgb2gray(J);

cluster_num = 2;%设置分类数
maxiter = 60;%最大迭代次数
%-------------随机初始化标签----------------
%label = randi([1,cluster_num],size(img));
%-----------kmeans最为初始化预分割----------
label = kmeans(img(:),cluster_num);
label = reshape(label,size(img));
iter = 0;
b=label;
while iter < maxiter
    %-------计算先验概率---------------
    %这里我采用的是像素点和3*3领域的标签相同
    %与否来作为计算概率
    %------收集上下左右斜等八个方向的标签--------
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    p_c = zeros(cluster_num,size(label,1)*size(label,2));
    %计算像素点8领域标签相对于每一类的相同个数
    for i = 1:cluster_num
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ...
            ~(label_i - label_l) + ~(label_i - label_r) + ...
            ~(label_i - label_ul) + ~(label_i - label_ur) + ...
            ~(label_i - label_dl) +~(label_i - label_dr);
        p_c(i,:) = temp(:)/8;%计算概率
    end
    p_c(find(p_c == 0)) = 0.001;%防止出现0
    %---------------计算似然函数----------------
    mu = zeros(1,cluster_num);
    sigma = zeros(1,cluster_num);
    %求出每一类的的高斯参数--均值方差
    for i = 1:cluster_num
        index = find(label == i);%找到每一类的点
        data_c = double(img(index));
        mu(i) = mean(data_c);%均值
        sigma(i) = var(data_c);%方差
    end
    p_sc = zeros(cluster_num,size(label,1)*size(label,2));
%     for i = 1:size(img,1)*size(img,2)
%         for j = 1:cluster_num
%             p_sc(j,i) = 1/sqrt(2*pi*sigma(j))*...
%               exp(-(img(i)-mu(j))^2/2/sigma(j));
%         end
%     end
    %------计算每个像素点属于每一类的似然概率--------
    %------为了加速运算，将循环改为矩阵一起操作--------
    for j = 1:cluster_num
        MU = repmat(mu(j),size(img,1)*size(img,2),1);
        p_sc(j,:) = 1/sqrt(2*pi*sigma(j))*...
            exp(-(double(img(:))-MU).^2/2/sigma(j));
    end 
    %找到联合一起的最大概率最为标签，取对数防止值太小
    [~,label] = max(log(p_c) + log(p_sc));
    %改大小便于显示
    label = reshape(label,size(img));
    %---------显示----------------
    %if ~mod(iter,6) 
        %figure;
        %n=1;
    %end
    %subplot(2,3,n);
    %imshow(label,[]);
    t=label;
    %title(['iter = ',num2str(iter)]);
    %pause(0.1);
    %n = n+1;
    iter = iter + 1;
end
m=numel(t);
x=length(find(t==1));
y=min(x,m-x);
figure;
imshow(t,[]);
BW0 = t;
%BW0 =bwareaopen(t, 50,26); %删除二值图像BW中面积小于50的对象，默认情况下使用8邻域，参数可调

%I=imread('D:\下载\978-7-302-46774-8MATLAB智能算法代码\Intelligent algorithm\10\s10_4\rice_noise.tif');
BW1=edge(BW0,'Roberts',0.04);    	%Roberts算子
BW2=edge(BW0,'Sobel',0.04);    	%Sobel算子
BW6=edge(b,'Sobel',0.04);    	%Sobel算子
BW3=edge(BW0,'Prewitt',0.04);        	%Prewitt算子
BW4=edge(BW0,'LOG',0.004);         	% LOG算子
BW5=edge(BW0,'Canny',0.04);         	% Canny算子
figure;
subplot(2,3,1),
imshow(BW0,[])
title('分割后图像')
subplot(2,3,2),
imshow(BW1,[])
title('Roberts ')
subplot(2,3,3),
imshow(BW2)
title(' Sobel ')
subplot(2,3,4),
imshow(BW3)
title(' Prewitt ')
subplot(2,3,5),
imshow(BW4)
title(' LOG ')
subplot(2,3,6),
imshow(BW5)
title('Canny ')
g1=length(find(BW1==1))/2;
g2=length(find(BW2==1))/2;
g3=length(find(BW3==1))/2;
g4=length(find(BW4==1))/2;
g5=length(find(BW5==1))/2;
g6=length(find(BW6==1))/2;
h1=y/g1
h2=y/g2
h3=y/g3
h4=y/g4
h5=y/g5
h6=y/g6


% % clear all; close all; clc;
% % 
% % img=double(imread('lena.jpg'));
% % imshow(img,[]);
[m n]=size(img);

img=sqrt(img);      %伽马校正

%下面是求边缘
fy=[-1 0 1];        %定义竖直模板
fx=fy';             %定义水平模板
Iy=imfilter(img,fy,'replicate');    %竖直边缘
Ix=imfilter(img,fx,'replicate');    %水平边缘
Ied=sqrt(Ix.^2+Iy.^2);              %边缘强度
Iphase=Iy./Ix;              %边缘斜率，有些为inf,-inf,nan，其中nan需要再处理一下


%下面是求cell
step=16;                %step*step个像素作为一个单元
step1=m/step;
step2=n/step;
orient=9;               %方向直方图的方向个数
jiao=360/orient;        %每个方向包含的角度数
Cell=cell(1,1);              %所有的角度直方图,cell是可以动态增加的，所以先设了一个
ii=1;                      
jj=1;
for i=1:step1:m          %如果处理的m/step不是整数，最好是i=1:step:m-step
    ii=1;
    for j=1:step2:n      %注释同上
        tmpx=Ix(i:i+step1-1,j:j+step2-1);
        tmped=Ied(i:i+step1-1,j:j+step2-1);
        tmped=tmped/sum(sum(tmped));        %局部边缘强度归一化
        tmpphase=Iphase(i:i+step1-1,j:j+step2-1);
        Hist=zeros(1,orient);               %当前step*step像素块统计角度直方图,就是cell
        for p=1:step1
            for q=1:step2
                if isnan(tmpphase(p,q))==1  %0/0会得到nan，如果像素是nan，重设为0
                    tmpphase(p,q)=0;
                end
                ang=atan(tmpphase(p,q));    %atan求的是[-90 90]度之间
                ang=mod(ang*180/pi,360);    %全部变正，-90变270
                if tmpx(p,q)<0              %根据x方向确定真正的角度
                    if ang<90               %如果是第一象限
                        ang=ang+180;        %移到第三象限
                    end
                    if ang>270              %如果是第四象限
                        ang=ang-180;        %移到第二象限
                    end
                end
                ang=ang+0.0000001;          %防止ang为0
                Hist(ceil(ang/jiao))=Hist(ceil(ang/jiao))+tmped(p,q);   %ceil向上取整，使用边缘强度加权
            end
        end
        Hist=Hist/sum(Hist);    %方向直方图归一化
        Cell{ii,jj}=Hist;       %放入Cell中
        ii=ii+1;                %针对Cell的y坐标循环变量
    end
    jj=jj+1;                    %针对Cell的x坐标循环变量
end

%下面是求feature,2*2个cell合成一个block,没有显式的求block
[m n]=size(Cell);
feature=cell(1,(m-1)*(n-1));
for i=1:m-1
   for j=1:n-1           
        f=[];
        f=[f Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];
        feature{(i-1)*(n-1)+j}=f;
   end
end

%到此结束，feature即为所求
%下面是为了显示而写的
l=length(feature);
f=[];
for i=1:l
    f=[f;feature{i}(:)'];  
end 
figure
mesh(f)