clc;
clear;
img1 = imread('eye1.tif');%D:\MATLAB源程序\DRIVE\test\images\01_test.tif');%CLRIS002.jpg');%
img2 = imread('D:\MATLAB源程序\DRIVE\test\1st_manual\02_manual1.gif');
img3 = imread('D:\MATLAB源程序\DRIVE\test\2nd_manual\02_manual2.gif');
[lm,ln]=size(img1);
img=zeros(lm,ln);
cout1=0;
cout2=0;
for i=1:lm
   for j=1:ln
       if img1(i,j)==img2(i,j)
          img(i,j)=1;cout1=cout1+1;
       %else img3(i,j)=0;
       end
   end
end
for i=1:lm
   for j=1:ln
       if img1(i,j)==img3(i,j)
          cout2=cout2+1;
       %else img3(i,j)=0;
       end
   end
end
acct1=cout1/(lm*ln);
acct2=cout2/(lm*ln);
