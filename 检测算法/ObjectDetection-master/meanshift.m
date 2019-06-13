close all;
clear all;
%writerObj=VideoWriter('haha.mp4');
%open(writerObj);
videoObj = VideoReader('111.mp4');%读视频文件
nframes = get(videoObj, 'NumberOfFrames');%获取视频文件帧个数
%%%%%%%%%%%%%%%%%%根据一幅目标全可见的图像圈定跟踪目标%%%%%%%%%%%%%%%%%%%%%%%
I= read(videoObj, 1);
figure(1);
imshow(I);
[temp,rect]=imcrop(I);
[a,b,c]=size(temp); 		%a:row,b:col
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算目标图像的权值矩阵%%%%%%%%%%%%%%%%%%%%%%%
y(1)=a/2;
y(2)=b/2;
tic_x=rect(1)+rect(3)/2;
tic_y=rect(2)+rect(4)/2;
m_wei=zeros(a,b);%权值矩阵
h=y(1)^2+y(2)^2 ;%带宽


for i=1:a
    for j=1:b
        dist=(i-y(1))^2+(j-y(2))^2;
        m_wei(i,j)=1-dist/h; %epanechnikov profile
    end
end
C=1/sum(sum(m_wei));%归一化系数


%计算目标权值直方图qu
%hist1=C*wei_hist(temp,m_wei,a,b);%target model
hist1=zeros(1,4096);
for i=1:a
    for j=1:b
        %rgb颜色空间量化为16*16*16 bins
        q_r=fix(double(temp(i,j,1))/16);  %fix为趋近0取整函数
        q_g=fix(double(temp(i,j,2))/16);
        q_b=fix(double(temp(i,j,3))/16);
        q_temp=q_r*256+q_g*16+q_b;            %设置每个像素点红色、绿色、蓝色分量所占比重
        hist1(q_temp+1)= hist1(q_temp+1)+m_wei(i,j);    %计算直方图统计中每个像素点占的权重
    end
end
hist1=hist1*C;
rect(3)=ceil(rect(3));
rect(4)=ceil(rect(4));




%%%%%%%%%%%%%%%%%%%%%%%%%读取序列图像
%myfile=dir('D:\chat\*.png');
%lengthfile=length(myfile);

lengthfile=nframes;
for l=1:800
    %Im=imread(myfile(l).name);
    Im = read(videoObj, l);%读取第i帧
    num=0;
    Y=[2,2];
    %%%%%%%mean shift迭代
    while((Y(1)^2+Y(2)^2>0.5)&num<10)   %迭代条件
        num=num+1;
        temp1=imcrop(Im,rect);
        %计算侯选区域直方图
        %hist2=C*wei_hist(temp1,m_wei,a,b);%target candidates pu
        hist2=zeros(1,4096);
        for i=1:a
            for j=1:b
                q_r=fix(double(temp1(i,j,1))/16);
                q_g=fix(double(temp1(i,j,2))/16);
                q_b=fix(double(temp1(i,j,3))/16);
                q_temp1(i,j)=q_r*256+q_g*16+q_b;
                hist2(q_temp1(i,j)+1)= hist2(q_temp1(i,j)+1)+m_wei(i,j);
            end
        end
        hist2=hist2*C;
        figure(2);
       subplot(1,2,1);
       plot(hist2);
        hold on;
        
        w=zeros(1,4096);
        for i=1:4096
            if(hist2(i)~=0) %不等于
                w(i)=sqrt(hist1(i)/hist2(i));
            else
                w(i)=0;
            end
        end
        
        
        
        %变量初始化
        sum_w=0;
        xw=[0,0];
        for i=1:a;
            for j=1:b
                sum_w=sum_w+w(uint32(q_temp1(i,j))+1);
                xw=xw+w(uint32(q_temp1(i,j))+1)*[i-y(1)-0.5,j-y(2)-0.5];
            end
        end
        Y=xw/sum_w;
        %中心点位置更新
        rect(1)=rect(1)+Y(2);
        rect(2)=rect(2)+Y(1);
    end
    
    
    %%%跟踪轨迹矩阵%%%
    tic_x=[tic_x;rect(1)+rect(3)/2];
    tic_y=[tic_y;rect(2)+rect(4)/2];
    
    v1=rect(1);
    v2=rect(2);
    v3=rect(3);
    v4=rect(4);
    %%%显示跟踪结果%%%
    %{
   
    title('目标跟踪结果及其运动轨迹');
    hold on;
    plot([v1,v1+v3],[v2,v2],[v1,v1],[v2,v2+v4],[v1,v1+v3],[v2+v4,v2+v4],[v1+v3,v1+v3],[v2,v2+v4],'LineWidth',2,'Color','r');
    
    %}
    % subplot(1,2,2);
     %end
     %%%显示跟踪结果%%%
    subplot(1,2,2);
    imshow(uint8(Im));
    title('目标跟踪结果及其运动轨迹');
    hold on;
    plot([v1,v1+v3],[v2,v2],[v1,v1],[v2,v2+v4],[v1,v1+v3],[v2+v4,v2+v4],[v1+v3,v1+v3],[v2,v2+v4],'LineWidth',2,'Color','r');
    plot(tic_x,tic_y,'LineWidth',2,'Color','b');
    f=getframe(gcf);
    %writeVideo(writerObj,f);
    %figure(3);
    mov(l).cdata=f.cdata;
    mov(l).colormap = [];
end
%figure(3)
movie(mov);
%close(writerObj);