I=imread('couple256.bmp'); %原始图
[m,n] = size(I);         %图的大小
I=double(I);

%加噪声 
std_n=5; % 高斯噪声标准差
In = randn(size(I))*std_n; % 高斯随机噪声
IO = I + In;  % IO为含噪声图像

%%IO_eage=sobel4_grad(IO);
%%figure(1);
%%imshow(IO_edge);title('4方向边缘')

%fs=fspecial('gaussian');
%IO_=imfilter(IO,fs,'symmetric');
%figure(1);
%imshow(double(IO));title('噪声图')
%imwrite(double(IO),'edge0.bmp');

IO_edge=sobel8_grad(IO);
figure(2);
imshow(IO_edge);title('8方向边缘')
imwrite(IO_edge,'edge1.bmp');

IO_edge=edge(IO,'sobel');
figure(3);
imshow(IO_edge);title('sobel边缘')
imwrite(IO_edge,'edge2.bmp');