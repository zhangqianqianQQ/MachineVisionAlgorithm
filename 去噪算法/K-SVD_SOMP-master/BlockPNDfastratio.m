function [mseblk timeout imageper output0 Dictionary Coefoutput Dout] =BlockPNDfastratio(O_image,input,second_input,hW0,hD0,Dictionary,matrix_sigma,L,Cu2)
%{ 

%}
%%%
Dout = zeros(64,256,15);
persuitnum = 8;
imageper = zeros(256*256,15);
if size(O_image,1) == 256
    blockresize = 256-8+1;
else
    blockresize = 512-8+1;
end
[Tfor1,Tfor2,Tfor3,Tinv1,Tinv2,Tinv3]   = nonsumple_wavelet_matrix(8);
sigma_ap       =    sqrt((4/pi-1)/L);
% sigma_ap       = 1/sqrt(L);
mean_noise     = gamma(L+0.5)*(1/L)^(1/2)/gamma(L);
% mean_noise = 1;
% sigma_ap       = sigma_ap/mean_noise;
[width height]=size(input);
% if L <=2
%     blocknum = 32;
% else
    blocknum = 16;
% end
% D0=2*hD0;
%%%%%%%%%%%%%%%%%%%%%%%%%BETA    hW0和hD0分别是搜索窗和块径。D0=2*hD0
 %1.1找出最小的标准差sigma
  sigma_BEAT=min(matrix_sigma(:));
  errorGoal =  sigma_BEAT*0.95;
  %1.2 用sigma对每个像素点的方差进行归一化
  BETA_sigma= sigma_BEAT*(ones(size(matrix_sigma))./matrix_sigma);
  
%     alpha = 0.92;D1 = 2*hD0+1;
%     h = quantile_nakagami(L, D1, alpha) .* D1.^2;h0 = h;
%     second_input_pad1 = padarray(second_input,[hD0 hD0],'symmetric'); 
%     second_input_pad2 = padarray(second_input,[hW0+hD0 hW0+hD0],'symmetric');
% BETA_sigma_pad2=padarray(BETA_sigma,[hW0+hD0 hW0+hD0],'symmetric'); 
BETA_sigma_pad2 = BETA_sigma;
tempbetablks=zeros(8*8,blocknum);temp=zeros(8*8,blocknum);


[pos_arr,wei_arr]   =  Block_matching(second_input,L,1,second_input,blocknum);
% save pos_arr;
%%%%%%%%%%%%%%%%%%%learning dictinary
%%%%%%%%%%%%%%%%%%%%
 blocks=zeros(8*8,width*height/4);
betamatrix=zeros(8*8,width*height/4);
blkfirstsdenoise=zeros(8*8,width*height/4);
cof_matrix=zeros(256,width*height/4);
Residual = zeros(8*8,width*height/4);
% 
% 
tic
for iter=1:15
      kkk=1;
      disp(iter)
      
%%    
    for opi = 1:size(pos_arr,2)
    idx_matrix = pos_arr(:,opi);
    for mmmm=1:size(idx_matrix,1);
                    idp = idx_matrix(mmmm);
                    if mod(idp,blockresize) == 0
                        idx = blockresize;idy = idp/blockresize;
                    else
                        idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
                    end
                   tempblk=input(idx:idx+7,idy:idy+7);
                   temp(:,mmmm)=tempblk(:);
                   tempbeta=BETA_sigma_pad2(idx:idx+7,idy:idy+7);
                   tempbetablks(:,mmmm)=tempbeta(:);
    end
    
    %%
% for ii=1:2:width
%     for jj=1:2:height
%         %%%%%%%%%%%%%%%%%%%%%%%%%%
%          idx_matrix= simidxs{ii,jj};
%          for mmmm=1:size(idx_matrix,1);
%                     idx=idx_matrix(mmmm,1); idy=idx_matrix(mmmm,2);
%                    tempblk=input_pad2(idx:idx+2*hD0,idy:idy+2*hD0);
%                    temp(:,mmmm)=tempblk(:);
%                    tempbeta=BETA_sigma_pad2(idx:idx+2*hD0,idy:idy+2*hD0);
%                    tempbetablks(:,mmmm)=tempbeta(:);
%                   
%                   
%          end        
     %%
        tempsimblocks= temp;
        tempsimbeta= tempbetablks;
        BETA=mean(tempsimbeta,2);%%注意
        BETAnew = tempsimbeta;
        
        blocks(:,kkk)=tempsimblocks(:,1);
%         CoefMatrix = SOMPerr_L(Dictionary,tempsimblocks,persuitnum,BETA);
         CoefMatrix =  SOMPerr(Dictionary,tempsimblocks, errorGoal,BETA,persuitnum );
%          CoefMatrix_1=SOMPerr(Dictionary,tempsimblocks,0.65*errorGoal,BETA );
         %%%%%%%%%%%%
%          data=tempsimblocks-Dictionary* CoefMatrix;
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%          CoefMatrix_1 =  SOMPerr_L(Dictionary,data,8,BETA );
%          CoefMatrix_1 =  SOMPerr(Dictionary,data, 0.65*errorGoal,BETA,53 );
%%   ncsr
         da1  = Dictionary * CoefMatrix;
         data = tempsimblocks-Dictionary* CoefMatrix;
         
%% 10.28 PND
         [vvv ddd ccc] = svd(da1);
         vvv = abs(vvv);
         if opi == 42025
             save('smalldic.mat','vvv');
         end
%          aaa = data*pinv(vvv);
%          aaa =  SOMPerr(vvv,data, errorGoal,BETA,4 );
         aaa =  OMPerrNONHtest(vvv,data,BETA,errorGoal );
         Residual(:,kkk) = mean(vvv*aaa,2);
%          Residual(:,kkk) = mean(data,2);
         
         
%          Residual_temp = data(:,1);
%          Residual_temp = zeros(size(data,1),1);
%          da_temp = zeros(size(data,1),1);
% 
%          centralblock = data(:,1);weight = zeros(1,16);
%          for i3 = 1:size(data,2)
%              weight(1,i3) = mean((data(:,i3)-centralblock).^2);
%              weight(1,1) = 0;
%          end
%          [numb3 indx3] = sort(weight);
%          newdat = data(:,indx3(1:8));
%          Residual_temp = mean(newdat,2);
         
%              Residual_temp = newdat;
%              
%              shrinktemp = data(i3,:);
%              avg = mean(shrinktemp,2);
% %              lambda = 2*sqrt(2)*(sigma_ap^2)/(sqrt(var((shrinktemp-avg),1)));
%              shrinktemp1 = (shrinktemp-avg).^2;
%              Cof = shrinktemp1/(sum(shrinktemp1,2));
%              Residual_temp(i3,1) = avg+mean(Cof.*(shrinktemp-avg),2);
% %              
% % %              dashrinktemp = da1(i3,:);
% % %              daavg = mean(dashrinktemp,2);
% % % %              lambda = 2*sqrt(2)*(sigma_ap^2)/(sqrt(var((shrinktemp-avg),1)));
% % %              dashrinktemp1 = (dashrinktemp-daavg).^2;
% % %              daCof = dashrinktemp1/(sum(dashrinktemp1,2));
% % %              da_temp(i3,1) = daavg+mean(daCof.*(dashrinktemp-daavg),2);
% % %              Residual_temp(i3,1) = mean(Cof.*shrinktemp,2);
%          end
%          Residual_temp = mean(data,2);
% %          Residual_temp = Residual_temp.*BETAnew(:,indx3(1:16));
%          Residual_temp = Residual_temp.*BETA;
% %          Residual_temp = mean(Residual_temp,2);
%          Residual_temp = reshape(Residual_temp,[8 8]);
% %          [k1 k2 k3 k4] = dwt2(Residual_temp,'db8','mode','sym');
% %          [k11 k22 k33 k44] = dwt2(k1,'db8','mode','sym');
% %          [k111 k222 k333 k444] = dwt2(k11,'db8','mode','sym');
% %          Med1 = median(k4(:))/0.6745;
%           cof1                            = 2*(Tfor1*Residual_temp*Tinv1); %第一层小波分解系数
%           cof2                            = 2*(Tfor2*cof1(1:8,1:8)*Tinv2);%第二层小波分解系数
%           cof3                            = 2*(Tfor3*cof2(1:8,1:8)*Tinv3); %第三层小波分解系数
%           LL3=cof3(1:8,1:8);
% %   LL3 = cof1(1:8,1:8);
%   LH1=cof1(9:16,1:8);HL1=cof1(1:8,9:16);HH1=cof1(9:16,9:16);
%   LH2=cof2(9:16,1:8);HL2=cof2(1:8,9:16);HH2=cof2(9:16,9:16);
%   LH3=cof3(9:16,1:8);HL3=cof3(1:8,9:16);HH3=cof3(9:16,9:16);
%   %% HardThresholding
% %   sigma_ap = median(HH1(:))/0.6745;
%   HT  = sqrt(2*log10(64))*sigma_ap;
%   LH1 = SoftThreshold(LH1,HT);
%   LH2 = SoftThreshold(LH2,HT);LH3 = SoftThreshold(LH3,HT);
%   HL1 = SoftThreshold(HL1,HT);
%   HL2 = SoftThreshold(HL2,HT);HL3 = SoftThreshold(HL3,HT);
%   HH1 = SoftThreshold(HH1,HT);
%   HH2 = SoftThreshold(HH2,HT);HH3 = SoftThreshold(HH3,HT);
%   LL3 = SoftThreshold(LL3,HT);
%   cof3(1:8,1:8)=LL3;
%   cof1(9:16,1:8)=LH1;cof1(1:8,9:16)=HL1;cof1(9:16,9:16)=HH1;
%   cof2(9:16,1:8)=LH2;cof2(1:8,9:16)=HL2;cof2(9:16,9:16)=HH2;
%   cof3(9:16,1:8)=LH3;cof3(1:8,9:16)=HL3;cof3(9:16,9:16)=HH3;
%         cof2(1:8,1:8)                   =    (Tinv3*cof3*Tfor3)/2;
%         cof1(1:8,1:8)                   =    (Tinv2*cof2*Tfor2)/2;
%         inv_Block                       =    (Tinv1*cof1*Tfor1)/2;
%         Residual(:,kkk)                 =    reshape(inv_Block,[64 1])./BETA;
%           HT1  = 3*sigma_ap;
%           HT2  = 3*sigma_ap;
%           HT3  = 3*sigma_ap;
%           k222 = SoftThreshold(k222,HT3);k333 = SoftThreshold(k333,HT3);k444 = SoftThreshold(k444,HT3);
%           k22 = SoftThreshold(k22,HT2);k33 = SoftThreshold(k33,HT2);k44 = SoftThreshold(k44,HT2);
%           k2 = SoftThreshold(k2,HT1);k3 = SoftThreshold(k3,HT1);k4 = SoftThreshold(k4,HT1);
%           k11 = idwt2(k111,k222,k333,k444,'db8','mode','sym');k11 = k11(1:end-1,1:end-1);
%           k1  = idwt2(k11,k22,k33,k44,'db8','mode','sym');
%           residual_new                 = idwt2(k1,k2,k3,k4,'db8','mode','sym');
%           residual_new                 = reshape(residual_new(1:9,1:9),[81 1]);
%           Residual(:,kkk)              = residual_new./BETA;
%           
% %%   dwt2
%                %%%%%%%%
% %                data = (mean(tempsimblocks,2)-Dictionary*mean(CoefMatrix,2)).*BETA;
% %                data = (tempsimblocks(:,1)-Dictionary*CoefMatrix(:,1)).*BETA;
% %                data = reshape(data,[9 9]);
% %                [k1 k2 k3 k4] = dwt2(data,'db8','mode','sym');
% %                [k11 k22 k33 k44] = dwt2(k1,'db8','mode','sym');
% %                [k111 k222 k333 k444] = dwt2(k11,'db8','mode','sym');
% %                Med1 = median(k4(:))/0.6745;
% %                Med2 = median(k44(:))/0.6745;
% %                Med3 = median(k444(:))/0.6745;
% %           HT1  = 3*Med1;
% %           HT2  = 3*Med2;
% %           HT3  = 3*Med3;
% %           k111 = SoftThreshold(k111,HT3);
% %           k222 = SoftThreshold(k222,HT3);k333 = SoftThreshold(k333,HT3);k444 = SoftThreshold(k444,HT3);
% %           k22 = SoftThreshold(k22,HT2);k33 = SoftThreshold(k33,HT2);k44 = SoftThreshold(k44,HT2);
% %           k2 = SoftThreshold(k2,HT1);k3 = SoftThreshold(k3,HT1);k4 = SoftThreshold(k4,HT1);
% %           k11 = idwt2(k111,k222,k333,k444,'db8','mode','sym');k11 = k11(1:end-1,1:end-1);
% %           k1  = idwt2(k11,k22,k33,k44,'db8','mode','sym');
% %                Med = median(k4(:))/0.6745;
% %           HT  = 3*Med;
% %           k1 = SoftThreshold(k1,HT);
% %           k2 = SoftThreshold(k2,HT);k3 = SoftThreshold(k3,HT);k4 = SoftThreshold(k4,HT);
% %           
% %           
% %           
% %           residual_new                 = idwt2(k1,k2,k3,k4,'db8','mode','sym');
% %           residual_new                 = reshape(residual_new(1:9,1:9),[81 1]);
% %           Residual(:,kkk)              =      residual_new./BETA;
%                %% UDWT
% %                data = (tempsimblocks(:,1)-Dictionary*CoefMatrix(:,1)).*BETA;
% %                data = (mean(tempsimblocks,2)-Dictionary*mean(CoefMatrix,2)).*BETA;
% %                  data = reshape(data,[9 9]);
% %                WT = ndwt2(data,3,'db3','mode','per');
% %                Med3 = median(WT.dec{10}(:))/0.6745;
% %                Med2 = median(WT.dec{7}(:))/0.6745;
% %                Med1 = median(WT.dec{4}(:))/0.6745;
% %                HT1 = 3*Med1;
% %                HT2 = 3*Med2;
% %                HT3 = 3*sigma_ap;
% %                WT.dec{8} = SoftThreshold(WT.dec{8},HT3);WT.dec{9} = SoftThreshold(WT.dec{9},HT3);WT.dec{10} = SoftThreshold(WT.dec{10},HT3);
% %                WT.dec{5} = SoftThreshold(WT.dec{5},HT2);WT.dec{6} = SoftThreshold(WT.dec{6},HT2);WT.dec{7} = SoftThreshold(WT.dec{7},HT2);
% %                WT.dec{2} = SoftThreshold(WT.dec{2},HT1);WT.dec{3} = SoftThreshold(WT.dec{3},HT1);WT.dec{4} = SoftThreshold(WT.dec{4},HT1);
% %                WT.dec{1} = SoftThreshold(WT.dec{1},HT1);
% %           residual_new                 = indwt2(WT);
% %           residual_new                 = reshape(residual_new(1:9,1:9),[81 1]);
% %           Residual(:,kkk)              = residual_new./BETA;
%                %%
%                Residual = [];
                 blkfirstsdenoise = [];
           betamatrix(:,kkk)=BETA;
           cof_matrix(:,kkk)= CoefMatrix(:,1);
%             blkfirstsdenoise(:,kkk)=Dictionary* CoefMatrix_1(:,1);
%             blkfirstsdenoise(:,kkk)=Dictionary*( CoefMatrix_1(:,1)+CoefMatrix(:,1));
           kkk=kkk+1;
    end

 rPerm = randperm(size(Dictionary,2));
    
    for j = rPerm
        [betterDictionaryElement,cof_matrix] = I_findBetterDictionaryElement( blocks,Dictionary,betamatrix,j,cof_matrix, blkfirstsdenoise,Residual );
         Dictionary(:,j) = betterDictionaryElement;
       
    
    end
%     inputcol = input*mean_noise;


%     imagetemp = psnreach(input,pos_arr,BETA_sigma_pad2,Dictionary,errorGoal,blocknum,L);
%     imageper(:,iter) = imagetemp;
imageper = [];

%%%%%%%%%quzao
%   outputiter=zeros(size(input)); weightiter=zeros(size(input));
% for opi = 1:size(pos_arr,2)
%     idx_matrix = pos_arr(:,opi);
%     for mmmm=1:size(idx_matrix,1);
%                     idp = idx_matrix(mmmm);
%                     if mod(idp,blockresize) == 0
%                         idx = blockresize;idy = idp/blockresize;
%                     else
%                         idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
%                     end
%                    tempblkiter=input(idx:idx+7,idy:idy+7);
%                    tempiter(:,mmmm)=tempblkiter(:);
%                    tempbetaiter=BETA_sigma_pad2(idx:idx+7,idy:idy+7);
%                    tempbetablksiter(:,mmmm)=tempbetaiter(:);
%     end
%         tempsimblocksiter=tempiter;
%         tempsimbetaiter=tempbetablksiter;
%         BETAiter=mean(tempsimbetaiter,2);
%          CoefMatrixiter =  SOMPerr(Dictionary,tempsimblocksiter, errorGoal,BETAiter,8 );
%          denoiseblkiter=Dictionary*CoefMatrixiter;
% idx_matrix = pos_arr(:,opi);
%             for r=1:blocknum
%                 f2iter=denoiseblkiter(:,r);
%                  Witer = reshape(f2iter,[8 8]);
%                     idp = idx_matrix(r);
%                     if mod(idp,blockresize) == 0
%                         idx = blockresize;idy = idp/blockresize;
%                     else
%                         idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
%                     end
%                  outputiter(idx:idx+7,idy:idy+7)=outputiter(idx:idx+7,idy:idy+7)+Witer;
%                   weightiter(idx:idx+7,idy:idy+7)=weightiter(idx:idx+7,idy:idy+7)+1;
%             end
% end
% outputiter=outputiter./weightiter;
% output0iter = outputiter;
% O_image_ = input*mean_noise;
% psnrper(1:iter) = 20*log10(255/sqrt(mean((output0iter(:)-O_image_(:)).^2)));



%       if mod(iter,8) == 0
%           [imagetemp output0] = psnreach(input,pos_arr,BETA_sigma_pad2,Dictionary,errorGoal,blocknum,L);
%           [pos_arr,wei_arr]   =  Block_matching(output0,L,1,output0,blocknum);
%       end

      Dout(:,:,iter) = Dictionary;

end
timeout = toc;

  %%%%%%%%%quzao
  output=zeros(size(input)); weight=zeros(size(input));
Coefoutput = zeros(256,[]);
ppppp = 1;
for opi = 1:size(pos_arr,2)
    idx_matrix = pos_arr(:,opi);
    for mmmm=1:size(idx_matrix,1);
                    idp = idx_matrix(mmmm);
                    if mod(idp,blockresize) == 0
                        idx = blockresize;idy = idp/blockresize;
                    else
                        idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
                    end
                   tempblk=input(idx:idx+7,idy:idy+7);
                   Otempblk=O_image(idx:idx+7,idy:idy+7);
                   temp(:,mmmm)=tempblk(:);
                   Otemp(:,mmmm)=Otempblk(:);
                   tempbeta=BETA_sigma_pad2(idx:idx+7,idy:idy+7);
                   tempbetablks(:,mmmm)=tempbeta(:);
    end
        tempsimblocks=temp;
        Otempsimblocks=Otemp;
        tempsimbeta=tempbetablks;
        BETA=mean(tempsimbeta,2);
         CoefMatrix =  SOMPerr(Dictionary,tempsimblocks, errorGoal,BETA,32 );
         coeftempp = CoefMatrix(:,1);
         Coefoutput(:,ppppp) = coeftempp(:);
         denoiseblk=Dictionary*CoefMatrix;
         mseblk0 = sqrt((denoiseblk-Otempsimblocks).^2);mseblk(1,opi) = mean(mean(mseblk0));
%          idxmatrix= simidxs{ii,jj};
idx_matrix = pos_arr(:,opi);
       %%%%%%%%
            for r=1:blocknum
                f2=denoiseblk(:,r);
                 W = reshape(f2,[8 8]);
%                  idx=idxmatrix(r,1);idy=idxmatrix(r,2);
                    idp = idx_matrix(r);
                    if mod(idp,blockresize) == 0
                        idx = blockresize;idy = idp/blockresize;
                    else
                        idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
                    end
                 output(idx:idx+7,idy:idy+7)=output(idx:idx+7,idy:idy+7)+W;
                  weight(idx:idx+7,idy:idy+7)=weight(idx:idx+7,idy:idy+7)+1;
            end
               
           ppppp = ppppp+1;
           
end


output=output./weight;
output0 = output;
% output0=output(1+hW0+hD0:1+hW0+hD0+width-1,1+hW0+hD0:1+hW0+hD0+height-1);
end

% function r = quantile_nakagami(L, ws, alphas)
%     L2=L*2;
%     L3=2*L-1;
%     for kw = 1:size(ws, 2);
%         w = ws(kw);
%         ima_nse = zeros(w * 256);
%         i = sqrt(-1);
%         for l = 1:L
%             ima_nse = ima_nse + abs(randn(size(ima_nse)) + i * randn(size(ima_nse))).^2 / 2;
%         end
%         ima_nse = sqrt(ima_nse / L);
% 
%         k = 1;
%         for i = 1:(2*w):(size(ima_nse,1) - 2*w)
%             for j = 1:w:(size(ima_nse,2) - w)
%                 sub_nse_1 = ima_nse(i:(i + w - 1), j:(j + w - 1));
%                 sub_nse_2 = ima_nse((i + w):(i + 2 * w - 1), j:(j + w - 1));
%                 
% %                 temp1 = sub_nse_1.*sub_nse_2;
% %                 temp2 = sub_nse_1.^2+sub_nse_2.^2;
% %                 lsl = (2*L-1)*log(temp1)-(2*L-1/2)*log(temp2);  
%                 
%                 lsl = log(sub_nse_1 ./ sub_nse_2 + sub_nse_2 ./ sub_nse_1);
%                 
%                 v(k) = mean(mean(lsl));
%                 k = k + 1;
%             end
%         end
% 
%         for q = 1:size(alphas, 2)
%             r(q, kw) = quantile(v, alphas(q)) - mean(v);
%         end
%     end
% 
% end