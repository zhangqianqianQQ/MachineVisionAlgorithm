function [Tfor1,Tfor2,Tfor3,Tinv1,Tinv2,Tinv3] = nonsumple_wavelet_matrix(blocksize)
f1     =   2*blocksize;
[Tforward1, Tinverse1] = getTransfMatrix (blocksize, 'db8',1,0);%产生下采样第一层分解矩阵，大小为8*8
[Tforward2, Tinverse2] = getTransfMatrix (blocksize/2, 'db8',1,0);%产生下采样第二层分解矩阵，大小为4*4
[Tforward3, Tinverse3] = getTransfMatrix (blocksize/4, 'db8',1,0);%产生下采样第三层分解矩阵，大小为2*2

Tfor1  = zeros(f1,blocksize);%第一层分解矩阵，与图像块相乘，由下采样第一层分解矩阵循环平移得到
Tfor2  = zeros(f1,blocksize);%第二层分解矩阵，与LL1相乘，由下采样第二层分解矩阵补零、循环平移得到
Tfor3  = zeros(f1,blocksize);%第三层分解矩阵，与LL2相乘，由下采样第三层分解矩阵补零、循环平移得到
s1     = [1:2:blocksize];
s2     = [1:4:blocksize];
%以下是由下采样矩阵通过补零和循环平移得到非下采样矩阵
Tfor1(1,:)          =           Tforward1(1,:);
for k = 2:blocksize
    Tfor1(k,:)      =            circshift(Tfor1(k-1,:),[0 1]);
end
Tfor1(blocksize+1,:)          =            Tforward1(blocksize/2+1,:);
for p = 10:f1
    Tfor1(p,:)      =            circshift(Tfor1(p-1,:),[0 1]);
end
Tinv1               =             pinv(Tfor1);

Tfor2(1,s1)         =            Tforward2(1,:);
for k = 2:blocksize
    Tfor2(k,:)      =            circshift(Tfor2(k-1,:),[0 1]);
end
Tfor2(blocksize+1,s1)         =            Tforward2(blocksize/4+1,:);
for p = 10:f1
    Tfor2(p,:)      =            circshift(Tfor2(p-1,:),[0 1]);
end
Tinv2               =            pinv(Tfor2);

Tfor3(1,s2)         =            Tforward3(1,:);
for k = 2:blocksize
    Tfor3(k,:)      =            circshift(Tfor3(k-1,:),[0 1]);
end
Tfor3(blocksize+1,s2)         =            Tforward3(blocksize/8+1,:);
for p = 10:f1
    Tfor3(p,:)      =            circshift(Tfor3(p-1,:),[0 1]);
end
Tinv3               =            pinv(Tfor3);