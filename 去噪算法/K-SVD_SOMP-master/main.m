% addpath('ppbNakagami');
% addpath('fastsar');
% clear all
% [O_image]=double((imread('5.tif')));%%%%读一幅图
% N_image=O_image(:,:,1);
%%%%%%%%%%%%%%加噪声
for image_index=[ 1301 ]
    image_index=[num2str(image_index),'.png'];     
for L=[  1  ]
%    L=4; %%%%视数
   psnrtemp=zeros(3,1);
   dictemp = zeros(64*256,1);coeftemp = zeros(256*249*249,1);
   psnrper = zeros(1,1);mseper = zeros(1,1);ssimper = zeros(1,1);imageper25 = [];mseblk = zeros(25,15625);
  for iteration=[1:1] ; %%%%视数
      save('index.mat','image_index','L','iteration','psnrtemp','dictemp','coeftemp','psnrper','mseper','ssimper','imageper25','mseblk');
      clear all;
      load index.mat;
      [O_image]=double((imread(num2str(image_index))));%%%%读一幅图
%       O_image = O_image(fix(512/4):fix(512/4)+255,fix(512/4):fix(512/4)+255);
  randn('seed',0)
s = zeros(size(O_image));
for k = 1:L
    s = s + abs(randn(size(O_image)) + 1i * randn(size(O_image))).^2 / 2;
end
N_image = O_image .* sqrt(s / L);%%%%%%%噪声图
% N_image = O_image .* (s / L);%%%%%%%噪声图
% N_image = O_image;
mean_noise=gamma(L+0.5)*(1/L)^(1/2)/gamma(L);%%%%%%%噪声的均值
% mean_noise = 1;
  %%%%%%%%%%%归一化
  SN_image=N_image/mean_noise;
%   SN_image=N_image;
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
% matrix_sigma=e_image./(L.^0.5);
% [ima_fil_2 ] = denoiseImageKSVDNONH_DCT( SN_image,matrix_sigma,10,256,1.1);
% [ima_fil_2]=imfilter(SN_image,ones(3,3)/9,'symmetric');
% ima_fil_2=SN_image;
%%
% hW = [1 3 5 10];
% hD = [0 1 2 3];
hW = 1;hD = 0;
alpha = 0.92;
% alpha = 0.88;
T = 0.2;
% nbit = [1 2 3 4];
nbit = 1;
ima_fil_2 = ppb_nakagamifastnon(SN_image, L, ...
                         hW, hD, ...
                         alpha, T, ...
                         nbit);
%                     
%%
%%%%显示
%  [ima_fil_2 ] = denoiseImageKSVDNONH_DCT( SN_image,matrix_sigma,10,256,1.1);
% ima_fil_2 = SN_image;
 PSNRIn = 20*log10(255/sqrt(mean((N_image(:)-O_image(:)).^2)));disp(PSNRIn);
 PSNRprefilt = 20*log10(255/sqrt(mean((ima_fil_2(:)-N_image(:)).^2)));disp(PSNRprefilt);
%  PSNRprefilt = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load DCT
%3 得到初始的DCT冗余字典
  %3.1 得到初始DCT
  K=256;bb=8;
    Pn=ceil(sqrt(K));
    DCT=zeros(bb,Pn);
    for k=0:1:Pn-1,
        V=cos([0:1:bb-1]'*k*pi/Pn);
        if k>0, V=V-mean(V); 
        end;
        DCT(:,k+1)=V/norm(V);
    end;
    DCT=kron(DCT,DCT);
%%%%%%%%%%%%%%%
Cu=std2(SN_image)/mean2(SN_image);       
Cu2 = Cu*Cu;


f = 10;
t = 4;
[mseblk0 timeout imageper output Dictionary CoefMatrix Dout] =BlockPNDfastratio(O_image,SN_image,ima_fil_2,f,t,DCT,matrix_sigma,L,Cu2);
time = timeout;
                K3 = [0.01 0.03];
                window3 = ones(8);
                L3 =max(output(:));
                
                
                ratioimg = output./SN_image;
% for number = 1:15
%     psnrper(iteration,number) = 20*log10(255/sqrt(mean((imageper(:,number)-O_image(:)).^2)));
%     mseper(iteration,number) = sqrt(mean((imageper(:,number)-O_image(:)).^2));
    [mssim, ssim_map] = ssim(O_image,output);
%     ssimper(iteration,number) = mssim;
% end
% imageper25(:,:,iteration) = imageper;


  PSNROut = 20*log10(255/sqrt(mean((output(:)-O_image(:)).^2)));disp(PSNROut);
  MSE = sqrt(mean((output(:)-O_image(:)).^2));
%   mseblk(iteration,:) = mseblk0;
                
  disp(time);
  disp('This iteration finished');
  
  psnrtemp(1,iteration)=PSNROut;
  psnrtemp(2,iteration)=time;
  psnrtemp(3,iteration)=mssim;
%   outputtemp(:,iteration) = output(:);
  dictemp(:,iteration) = Dictionary(:);
%   coeftemp(:,iteration) = CoefMatrix(:);
%   [tp1 tp2] = size(CoefMatrix);
  end
  psnrfinal = mean(psnrtemp(1,:),2);tfinal = mean(psnrtemp(2,:),2);
%   tempp1 = psnrtemp(1,:);
%   [num bes] = max(tempp1);
%   bestoutput = reshape(outputtemp(:,bes),[256 256]);
%   bestdic = reshape(dictemp(:,bes),[64 256]);
%   bestcoef = reshape(coeftemp(:,bes),[tp1 tp2]);
%   [coefplots] = coefplot(bestcoef);
%   save ( ['F:\MatlabWork\new\code\2013.8.20-重叠SOMP-1 - 副本0\data\',num2str(image_index),'\persuit8svdp4-C-0-95-per2-ppb1-16block-t8d32-svddic-sqrt2-iter1','--psnrin',num2str(PSNRIn),'--psnrprefilt',num2str(PSNRprefilt),'--psnravg',num2str(psnrfinal),'-ssim',num2str(mssim),'-mse',num2str(MSE),'--trainingtime',num2str(tfinal),'--L=',num2str(L),'.mat']','output','psnrtemp','Dictionary','CoefMatrix','dictemp','psnrper','imageper','imageper25','Dout','mseblk','ratioimg');
%% 这个跑完了跑三层的嗯
  % if iteration == 1
%             psnrtemp=psnrtemp/1;
% end
end
end
%   save ( ['C:\Users\panqiufeng\Desktop\paper2_SOMP_TSSC重叠\DATA\learnning\1\DCT',num2str(PSNROut),num2str(L),'.mat'], 'output');
%    save ( ['C:\Users\panqiufeng\Desktop\paper2_SOMP_TSSC重叠\DATA\learnning\1\DCT','DIC',num2str(L),'.mat'], 'Dictionary');
%  figure(1)
%  imshow(output,[0 255 ]);
%  figure(2)
% I = displayDictionaryElementsAsImage(Dictionary, floor(sqrt(256)), floor(size(Dictionary,2)/floor(sqrt(256))),9,9,0);
%  title('The dictionary trained on patches from the noisy image');
