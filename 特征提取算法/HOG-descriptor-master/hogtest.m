% clear all; close all; clc;

img1=imread('lena.jpg');
imshow(img1,[]);
[m n]=size(img1);

img=sqrt(double(img1));      %伽马校正
% figure;hold on;
figure;
a = min(min(min(img)));
b = max(max(max(img)));
% can not directly operator on a matrix more than three dimensions
c = 255/(b-a);
for i = 1:3
    img2(:,:,i) =img(:,:,i) * c;
end

imshow(uint8(img2));

%下面是求边缘
fy=[-1 0 1];        %定义竖直模板,用于计算y方向上的梯度值，向右为正方向
fx=fy';             %定义水平模板,用于计算x方向上的梯度值
Iy=imfilter(img,fy,'replicate');    %竖直边缘/梯度
Ix=imfilter(img,fx,'replicate');    %水平边缘/梯度
Ied=sqrt(Ix.^2+Iy.^2);              %边缘强度/梯度
Iphase=Iy./Ix;              %边缘斜率，有些为inf,-inf,nan，其中nan需要再处理一下


%下面是求cell
step=16;                %step*step个像素作为一个cell
orient=9;               %方向直方图的方向个数
jiao=360/orient;        %每个方向包含的角度数
Cell=cell(1,1);              %所有的角度直方图,cell是可以动态增加的，所以先设了一个
ii=1;                      
jj=1;
for i=1:step:m          %如果处理的m/step不是整数，最好是i=1:step:m-step， no overlapping
    ii=1;
    for j=1:step:n      %注释同上
        tmpx=Ix(i:i+step-1,j:j+step-1);
        tmped=Ied(i:i+step-1,j:j+step-1);
        tmped=tmped/sum(sum(tmped));        %局部边缘强度归一化
        tmpphase=Iphase(i:i+step-1,j:j+step-1);
        Hist=zeros(1,orient);               %当前step*step像素块统计角度直方图,就是cell
        for p=1:step
            for q=1:step
                if isnan(tmpphase(p,q))==1  %0/0会得到nan，如果像素是nan，重设为0
                    tmpphase(p,q)=0;
                end
                ang=atan(tmpphase(p,q));    %atan求的是[-90 90]度之间
                ang=mod(ang*180/pi,360);    %全部变正，[0,360), -90变270
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
feature=cell(1,(m-1)*(n-1));%step = size(Cell,1),而且每个block由2*2的cell组成
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
