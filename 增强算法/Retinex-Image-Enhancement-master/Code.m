function res123 = Code(arg)
close all;
clc; 
I=imread(arg);
Ir=I(:,:,1); 
Ig=I(:,:,2); 
Ib=I(:,:,3); 

%%%%%%%%%%Set the required parameters%%%%%% 
G = 192; 
b = -30; 
alpha = 125; 
beta = 46; 
Ir_double=double(Ir); 
Ig_double=double(Ig); 
Ib_double=double(Ib); 

%%%%%%%%%%Set the Gaussian parameter%%%%%% 
sigma_1=15;   %Three Gaussian Kernels
sigma_2=80; 
sigma_3=250; 
[x, y]=meshgrid((-(size(Ir,2)-1)/2):(size(Ir,2)/2),(-(size(Ir,1)-1)/2):(size(Ir,1)/2));   
gauss_1=exp(-(x.^2+y.^2)/(2*sigma_1*sigma_1));  %Calculate the Gaussian function 
Gauss_1=gauss_1/sum(gauss_1(:));  %Normalization
gauss_2=exp(-(x.^2+y.^2)/(2*sigma_2*sigma_2)); 
Gauss_2=gauss_2/sum(gauss_2(:)); 
gauss_3=exp(-(x.^2+y.^2)/(2*sigma_3*sigma_3)); 
Gauss_3=gauss_3/sum(gauss_3(:)); 
 
%%%%%%%%%%Operates on R component%%%%%%% 
% MSR Section
Ir_log=log(Ir_double+1);  %Converts an image to a logarithm field 
f_Ir=fft2(Ir_double);  %The image is Fourier transformed and converted to the frequency domain 

%sigma = 15 processing results
fgauss=fft2(Gauss_1,size(Ir,1),size(Ir,2)); 
fgauss=fftshift(fgauss);  %Move the center of the frequency domain to zero 
Rr=ifft2(fgauss.*f_Ir);  %After convoluting, transform back into the airspace 
min1=min(min(Rr)); 
Rr_log= log(Rr - min1+1); 
Rr1=Ir_log-Rr_log;  

%sigma=80 
fgauss=fft2(Gauss_2,size(Ir,1),size(Ir,2)); 
fgauss=fftshift(fgauss); 
Rr= ifft2(fgauss.*f_Ir); 
min1=min(min(Rr)); 
Rr_log= log(Rr - min1+1); 
Rr2=Ir_log-Rr_log;  

 %sigma=250 
fgauss=fft2(Gauss_3,size(Ir,1),size(Ir,2)); 
fgauss=fftshift(fgauss); 
Rr= ifft2(fgauss.*f_Ir); 
min1=min(min(Rr)); 
Rr_log= log(Rr - min1+1); 
Rr3=Ir_log-Rr_log; 

Rr=0.33*Rr1+0.34*Rr2+0.33*Rr3;   %Weighted summation 
MSR1 = Rr;
SSR1 = Rr2;
%Calculate CR 
CRr = beta*(log(alpha*Ir_double+1)-log(Ir_double+Ig_double+Ib_double+1)); 

%SSR
min1 = min(min(SSR1)); 
max1 = max(max(SSR1)); 
SSR1 = uint8(255*(SSR1-min1)/(max1-min1)); 

%MSR
min1 = min(min(MSR1)); 
max1 = max(max(MSR1)); 
MSR1 = uint8(255*(MSR1-min1)/(max1-min1)); 

%MSRCR 
Rr = G*(CRr.*Rr+b); 
min1 = min(min(Rr)); 
max1 = max(max(Rr)); 
Rr_final = uint8(255*(Rr-min1)/(max1-min1)); 
 

%%%%%%%%%%On g component operation%%%%%%% 
%Ig_double=double(Ig); 
Ig_log=log(Ig_double+1);  %Converts an image to a logarithm field 
f_Ig=fft2(Ig_double);  %The image is Fourier transformed and converted to the frequency domain 

fgauss=fft2(Gauss_1,size(Ig,1),size(Ig,2)); 
fgauss=fftshift(fgauss);  %Move the center of the frequency domain to zero 
Rg= ifft2(fgauss.*f_Ig);  %After convoluting, transform back into the airspace 
min2=min(min(Rg)); 
Rg_log= log(Rg-min2+1); 
Rg1=Ig_log-Rg_log;  %sigma = 15 processing results 

fgauss=fft2(Gauss_2,size(Ig,1),size(Ig,2)); 
fgauss=fftshift(fgauss); 
Rg= ifft2(fgauss.*f_Ig); 
min2=min(min(Rg)); 
Rg_log= log(Rg-min2+1); 
Rg2=Ig_log-Rg_log;  %sigma=80 


fgauss=fft2(Gauss_3,size(Ig,1),size(Ig,2)); 
fgauss=fftshift(fgauss); 
Rg= ifft2(fgauss.*f_Ig); 
min2=min(min(Rg)); 
Rg_log= log(Rg-min2+1); 
Rg3=Ig_log-Rg_log;  %sigma=250 

Rg=0.33*Rg1+0.34*Rg2+0.33*Rg3;   %Weighted summation 
SSR2 = Rg2;
MSR2 = Rg;
%Calculate CR 
CRg = beta*(log(alpha*Ig_double+1)-log(Ir_double+Ig_double+Ib_double+1)); 

%SSR:
min2 = min(min(SSR2)); 
max2 = max(max(SSR2)); 
SSR2 = uint8(255*(SSR2-min2)/(max2-min2)); 

%MSR
min2 = min(min(MSR2)); 
max2 = max(max(MSR2)); 
MSR2 = uint8(255*(MSR2-min2)/(max2-min2)); 

%MSRCR 
Rg = G*(CRg.*Rg+b); 
min2 = min(min(Rg)); 
max2 = max(max(Rg)); 
Rg_final = uint8(255*(Rg-min2)/(max2-min2)); 
 
%%%%%%%%%%The B component is manipulated with the R component%%%%%%% 
%Ib_double=double(Ib); 
Ib_log=log(Ib_double+1); 
f_Ib=fft2(Ib_double); 

fgauss=fft2(Gauss_1,size(Ib,1),size(Ib,2)); 
fgauss=fftshift(fgauss); 
Rb= ifft2(fgauss.*f_Ib); 
min3=min(min(Rb)); 
Rb_log= log(Rb-min3+1); 
Rb1=Ib_log-Rb_log; 

fgauss=fft2(Gauss_2,size(Ib,1),size(Ib,2)); 
fgauss=fftshift(fgauss); 
Rb= ifft2(fgauss.*f_Ib); 
min3=min(min(Rb)); 
Rb_log= log(Rb-min3+1); 
Rb2=Ib_log-Rb_log; 


fgauss=fft2(Gauss_3,size(Ib,1),size(Ib,2)); 
fgauss=fftshift(fgauss); 
Rb= ifft2(fgauss.*f_Ib); 
min3=min(min(Rb)); 
Rb_log= log(Rb-min3+1); 
Rb3=Ib_log-Rb_log; 

Rb=0.33*Rb1+0.34*Rb2+0.33*Rb3; 

%计算CR 
CRb = beta*(log(alpha*Ib_double+1)-log(Ir_double+Ig_double+Ib_double+1)); 
SSR3 = Rb2;
MSR3 = Rb;
%SSR:
min3 = min(min(SSR3)); 
max3 = max(max(SSR3)); 
SSR3 = uint8(255*(SSR3-min3)/(max3-min3));

%MSR
min3 = min(min(MSR3)); 
max3 = max(max(MSR3)); 
MSR3 = uint8(255*(MSR3-min3)/(max3-min3));

%MSRCR
Rb = G*(CRb.*Rb+b); 
min3 = min(min(Rb)); 
max3 = max(max(Rb)); 
Rb_final = uint8(255*(Rb-min3)/(max3-min3)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MSRCP
Int = (Ir_double + Ig_double + Ib_double) / 3.0;
Int_log = log(Int+1);  %Converts an image to a logarithm field 
f_Int=fft2(Int_log);  %The image is Fourier transformed and converted to the frequency domain 

%sigma = 15 processing results
fgauss=fft2(Gauss_1,size(Int,1),size(Int,2)); 
fgauss=fftshift(fgauss);  %Move the center of the frequency domain to zero 
RInt=ifft2(fgauss.*f_Int);  %After convoluting, transform back into the airspace 
min1=min(min(RInt)); 
RInt_log= RInt - min1+1; 
RInt1=Int_log-RInt_log;  

%sigma=80 
fgauss=fft2(Gauss_2,size(Int,1),size(Int,2)); 
fgauss=fftshift(fgauss); 
RInt= ifft2(fgauss.*f_Int); 
min1=min(min(RInt)); 
RInt_log= RInt - min1+1; 
RInt2=Int_log-RInt_log;  

 %sigma=250 
fgauss=fft2(Gauss_3,size(Int,1),size(Int,2)); 
fgauss=fftshift(fgauss); 
RInt= ifft2(fgauss.*f_Int); 
min1=min(min(RInt)); 
RInt_log= RInt - min1+1; 
RInt3=Int_log-RInt_log; 

RInt=0.33*RInt1+0.34*RInt2+0.33*RInt3;   %Weighted summation 

minInt = min(min(RInt)); 
maxInt = max(max(RInt)); 
Int1 = uint8(255*(RInt-minInt)/(maxInt-minInt));

MSRCPr = zeros(size(I, 1), size(I, 2));
MSRCPg = zeros(size(I, 1), size(I, 2));
MSRCPb = zeros(size(I, 1), size(I, 2));

for ii = 1 : size(I, 1)
    for jj = 1 : size(I, 2) 
        C =  max(Ig_double(ii, jj), Ib_double(ii, jj));
        B = max(Ir_double(ii, jj), C);
        A = min(255.0 / B, Int1(ii, jj) / Int(ii, jj));
        MSRCPr(ii, jj) = A * Ir_double(ii, jj);
        MSRCPg(ii, jj) = A * Ig_double(ii, jj);
        MSRCPb(ii, jj) = A * Ib_double(ii, jj);
    end
end

minInt = min(min(MSRCPr)); 
maxInt = max(max(MSRCPr)); 
MSRCPr = uint8(255*(MSRCPr-minInt)/(maxInt-minInt));

minInt = min(min(MSRCPg)); 
maxInt = max(max(MSRCPg)); 
MSRCPg = uint8(255*(MSRCPg-minInt)/(maxInt-minInt));

minInt = min(min(MSRCPb)); 
maxInt = max(max(MSRCPb)); 
MSRCPb = uint8(255*(MSRCPb-minInt)/(maxInt-minInt));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ssr = cat(3,SSR1,SSR2,SSR3);
msr = cat(3,MSR1,MSR2,MSR3);
msrcr=cat(3,Rr_final,Rg_final,Rb_final);  %Combine the three-channel image 
MSRCP = cat(3, MSRCPr, MSRCPg, MSRCPb);

subplot(3,2,1);imshow(I);title('Original')  %Show the original image 
subplot(3,2,2);imshow(ssr);title('SSR')
subplot(3,2,3);imshow(msr);title('MSR')
subplot(3,2,4);imshow(msrcr);title('MSRCR')  %Displays the processed image 
subplot(3,2,5);imshow(MSRCP);title('MSRCP')
