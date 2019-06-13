close all;
clear all;
clc


A=imread('lowcc.jpg');
A=rgb2gray(A);

p=0:255;
C=hist(double(A(:)),256);
cuf=zeros(size(C));

for i=1:length(C)
    if i==1
        cuf(i)=C(i);
    else
        cuf(i)=cuf(i-1)+C(i);
    end
end
%For Histogram Matching give reference histogram to C2 variable
C2=(cuf(end)/length(cuf))*ones(size(C));
cuf2=zeros(size(C));
for i=1:length(C2)
    if i==1
        cuf2(i)=C2(i);
    else
        cuf2(i)=cuf2(i-1)+C2(i);
    end
end
q=zeros(size(p));
for i=1:length(C)
    t=closeone(cuf2,cuf(i));
    q(i)=p(t);
end
B=interp1(p,q,single(A(:)));
B=reshape(B,size(A));
figure;
imshow(A);
t=min(min(B));
h=max(max(B));
p=size(B);
B=floor(((B-t)/h)*255);        
B=uint8(B);
figure;
imshow(B);

