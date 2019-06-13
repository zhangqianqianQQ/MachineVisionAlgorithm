%函数sobel8_grad的结果M为边缘二值矩阵
%采用sobel算子八方向3*3模板
function M=sobel8_grad(f)
f=double(f);
[m,n]=size(f);
%对原图进行一行一列扩充
f=[zeros(m,1) f zeros(m,1)];
f=[zeros(1,n+2);f;zeros(1,n+2)];
new=f;

%0,45,90,135,180,225,270,315八个方向的sobel算子卷积矩阵
h1=[-1,-2,-1;0,0,0;1,2,1];
h2=[-2,-1,0;-1,0,1;0,1,2];
h3=[-1,0,1;-2,0,2;-1,0,1];
h4=[0,1,2;-1,0,1;-2,-1,0];
h5=[1,2,1;0,0,0;-1,-2,-1];
h6=[2,1,0;1,0,-1;0,-1,-2];
h7=[1,0,-1;2,0,-2;1,0,-1];
h8=[0,-1,-2;1,0,-1;2,-1,0];

for i=2:m+1 %i代表行
    for j=2:n+1   %j代表列
		f0=[f(i-1,j-1),f(i-1,j),f(i-1,j+1);%f0为以f(i,j)为中心的3*3灰度矩阵
		f(i,j-1),f(i,j),f(i,j+1);
		f(i+1,j-1),f(i+1,j),f(i+1,j+1)];
		%8个方向不同卷积
        H1=sum(sum(h1.*f0));
        H2=sum(sum(h2.*f0));
        H3=sum(sum(h3.*f0));
        H4=sum(sum(h4.*f0));
        H5=sum(sum(h5.*f0));
        H6=sum(sum(h6.*f0));
        H7=sum(sum(h7.*f0));
        H8=sum(sum(h8.*f0));
       %% h=H1+H2+H3+H4+H5+H6+H7+H8;
		h=[H1,H2,H3,H4,H5,H6,H7,H8];%取最大梯度值
        delta_g(i,j)=max(h); %将最大梯度值赋给delta_g矩阵
    end 
end

%%以下是为了求阈值T对梯度矩阵进行阈值分割
T0=sum(sum(delta_g(2:m+1,2:n+1)))/(m*n);%初值阈值为梯度矩阵的平均值
u1=0;%u1为大于T0的部分的矩阵元素的平均值
c1=0;%统计大于T0的元素个数
u2=0;%u2为小于等于T0的部分的矩阵元素的平均值
c2=0;%统计小于等于T0的元素个数
sig=150;%限定系数
for i=1:m+1
	for j=2:n+1
		if(delta_g(i,j)>T0) 
			u1=u1+delta_g(i,j);
			c1=c1+1;
		else
			u2=u2+delta_g(i,j);
			c2=c2+1;
		end
	end
end
u1=u1/c1;
u2=u2/c2;
T=(u1+u2)/2;

u1=0;
c1=0;
u2=0;
c2=0;
while(abs(T0-T)>sig)
	T0=T
	for i=1:m+1
		for j=2:n+1
			if(delta_g(i,j)>T0)
				u1=u1+delta_g(i,j);
				c1=c1+1;
			else
				u2=u2+delta_g(i,j);
				c2=c2+1;
			end
		end
	end
	u1=u1/c1;
	u2=u2/c2;
	T=(u1+u2)/2;
end

%%对梯度幅值图像进行阈值分割	
for i=2:m+1  %i代表行
    for j=2:n+1  %j代表列
		if(delta_g(i,j)>T) %判断梯度值是否大于阈值
			new(i,j)=1;
		else
			new(i,j)=0;
		end
	end
end		

M=new(2:m+1,2:n+1);%输出new中需要的矩阵部分

