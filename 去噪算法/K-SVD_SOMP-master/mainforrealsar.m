addpath('ppbNakagami');
addpath('fastsar');
clear all
for flag=[0 ]
if flag==0
[N_image]=double((imread('yellow.png')));%%%%读一幅图
else
    [N_image]=double((imread('H-3.bmp')));%%%%读一幅图
N_image=double(N_image(1:256,257:512));
end

%  N_image=N_image(:,:,1);
%%%%%%%%%%%%%%加噪声

    L=4; %%%%视数

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%yicilvbo
hW = [1 3 5 10];
hD = [0 1 2 3];
alpha = 0.92;
T = 0.2;
nbit = [1 2 3 4];
ima_fil_2 = ppb_nakagami(N_image, L, ...
                         hW, hD, ...
                         alpha, T, ...
                         nbit);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mean_noise=gamma(L+0.5)*(1/L)^(1/2)/gamma(L);%%%%%%%噪声的均值
  %%%%%%%%%%%归一化
  SN_image=N_image/mean_noise;
  
  %%%%%%%%%%求权值矩阵
[m,n]=size(N_image);
 p_image=padarray(N_image,[3 3],'symmetric');
 e_image=zeros(m,n);
 for  ii=1:m
     for j=1:n
         e_image(ii,j)=mean(mean( p_image(ii:ii+6,j:j+6)));
     end
 end  
% matrix_sigma=e_image./L.^0.5;
matrix_sigma=((e_image/mean_noise).*(4/pi-1)^0.5)./L.^0.5;
%%%%显示
%  PSNRIn = 20*log10(255/sqrt(mean((N_image(:)-O_image(:)).^2)));
%  [ima_fil_2 ] = denoiseImageKSVDNONH_DCT( SN_image,matrix_sigma,10,256,1.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load DCT
%%%%%%%%%%%%%%%
f = 10;
t = 4;
[output Dictionary] =BlockPNDfast(SN_image,ima_fil_2,f,t,DCT,matrix_sigma);
%   PSNROut = 20*log10(255/sqrt(mean((output(:)-O_image(:)).^2)))
  save ( ['C:\Users\panqiufeng\Desktop\paper2_SOMP_TSSC重叠\',num2str(4),'.mat'], 'output');
   save ( ['C:\Users\panqiufeng\Desktop\paper2_SOMP_TSSC重叠\\DCT','DIC',num2str(4),'.mat'], 'Dictionary');

%  figure(2)
% I = displayDictionaryElementsAsImage(Dictionary, floor(sqrt(256)), floor(size(Dictionary,2)/floor(sqrt(256))),9,9,0);
end
%  title('The dictionary trained on patches from the noisy image');
