function [output0 Dictionary] =BlockPPBWEIGHT(input,second_input,hW0,hD0,Dictionary,matrix_sigma,L)

%%
 DCT1=Dictionary;
[width height]=size(input);D0=2*hD0;
%%%%%%%%%%%%%%%%%%%%%%%%%BETA    hW0和hD0分别是搜索窗和块径。D0=2*hD0
 %1.1找出最小的标准差sigma
  sigma_BEAT=min(matrix_sigma(:));
  errorGoal =  sigma_BEAT*1;
  %1.2 用sigma对每个像素点的方差进行归一化
  BETA_sigma= sigma_BEAT*(ones(size(matrix_sigma))./matrix_sigma);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 second_input_pad1 = padarray(second_input,[hD0 hD0],'symmetric'); 
 second_input_pad2 = padarray(second_input,[hW0+hD0 hW0+hD0],'symmetric');
 i=0;w=cell(2*hW0+1);
  for m = -hW0:hW0
           i=i+1;
           j=0;
            for n = -hW0:hW0
                j=j+1;
                if(m==0 && n==0) 
                    w{i,j} = zeros(width, height);
                    continue; 
                end;    
                 R1 = second_input_pad1-second_input_pad2(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0);
                Sd1 =R1.*R1;
                Sd1 = cumsum(Sd1,1);
                Sd1 = cumsum(Sd1,2);   
                [Sd1width,Sd1height] = size(Sd1);
                Sd1_temp  = zeros(Sd1width+1,Sd1height+1);
                Sd1_temp(2:Sd1width+1,2:Sd1height+1)=Sd1;
                temp1 = Sd1_temp(D0+2:D0+width+1,D0+2:D0+height+1)+ Sd1_temp(1:width,1:height)-Sd1_temp(D0+2:D0+width+1,1:height)-Sd1_temp(1:width,D0+2:D0+height+1);
                 w{i,j}=temp1;
            end
  end
%      input_pad1 = padarray(input,[hD0 hD0],'symmetric'); 
clear  second_input_pad1;
clear  second_input_pad2; clear Sd1_temp; clear  temp1; clear R1; clear Sd1;
%%%%%%%%
% w = ppbweight(input,hW0,hD0,L);
%%%%%%%%
     input_pad2 = padarray(input,[hW0+hD0 hW0+hD0],'symmetric'); 
     BETA_sigma_pad2=padarray(BETA_sigma,[hW0+hD0 hW0+hD0],'symmetric'); 
     temp=zeros((2*hD0+1)^2,31);weitht_2=zeros(2*hW0+1,2*hW0+1);idx_matrix=zeros(31,2); %#ok<NASGU>
     tempbetablks=zeros((2*hD0+1)^2,31);
     simidxs=cell(width,height); 
for idx=1:width
    for idy=1:height
        for i=1:2*hW0+1
            for j=1:2*hW0+1
                weight_2(i,j)=w{i,j}(idx,idy); %#ok<*AGROW>
            end
        end
        ddd=sort(weight_2(:));
        T0=ddd(30);%%%%%%%30个相似块mt
%         tempblk=input_pad2(idx+hW0+hD0-hD0:idx+hW0+hD0+2*hD0-hD0,idy+hW0+hD0-hD0:idy+hW0+hD0+2*hD0-hD0);
%         tempbeta=BETA_sigma_pad2(idx+hW0+hD0-hD0:idx+hW0+hD0+2*hD0-hD0,idy+hW0+hD0-hD0:idy+hW0+hD0+2*hD0-hD0);
%          temp(:,1)=tempblk(:);
%          tempbetablks(:,1)=tempbeta(:);
        idx_matrix(1,1)=idx+hW0+hD0; idx_matrix(1,2)=idy+hW0+hD0;
        kkk=2;    
        for i=-hW0:hW0
            for j=-hW0:hW0
               if weight_2(i+hW0+1,j+hW0+1)<=T0 
                  
%                    tempblk=input_pad2(idx+hW0+hD0+i-hD0:idx+hW0+hD0+i-hD0+2*hD0,idy+hW0+hD0+j-hD0:idy+hW0+hD0+j-hD0+2*hD0);
%                    temp(:,kkk)=tempblk(:);
%                    tempbeta=BETA_sigma_pad2(idx+hW0+hD0+i-hD0:idx+hW0+hD0+i-hD0+2*hD0,idy+hW0+hD0+j-hD0:idy+hW0+hD0+j-hD0+2*hD0);
%                    tempbetablks(:,kkk)=tempbeta(:);
                   idx_matrix(kkk,1)=idx+hW0+hD0+i;idx_matrix(kkk,2)=idy+hW0+hD0+j;
                   kkk=kkk+1;
               end
                 
            end
        end
%         simiblocks{idx,idy}=temp;
        simidxs{idx,idy}= idx_matrix;
%         simibetablks{idx,idy}=tempbetablks;
        
       
    end
end
% %%%%%%%%%%%%%%%%%%%learning dictinary
% %%%%%%%%%%%%%%%%%%%%
%  blocks=zeros((2*hD0+1)^2,width*height);
% betamatrix=zeros((2*hD0+1)^2,width*height);
% blkfirstsdenoise=zeros((2*hD0+1)^2,width*height);
% cof_matrix=zeros(size(Dictionary,2),width*height);
% residual=zeros((2*hD0+1)^2,width*height);
% save test-house-L=2.mat
% load test-house-L=2.mat
% for iter=1:10
%       kkk=1;
%       disp(iter)
% for ii=1:2:height
%     
%     for jj=1:2:width
%         %%%%%%%%%%%%%%%%%%%%%%%%%%
%          idx_matrix= simidxs{ii,jj};
%          for mmmm=1:size(idx_matrix,1);
%                     idx=idx_matrix(mmmm,1); idy=idx_matrix(mmmm,2);
%                    tempblk=input_pad2(idx-hD0:idx+hD0,idy-hD0:idy+hD0);
%                    temp(:,mmmm)=tempblk(:);
%                    tempbeta=BETA_sigma_pad2(idx-hD0:idx+hD0,idy-hD0:idy+hD0);
%                    tempbetablks(:,mmmm)=tempbeta(:);
%                   
%                   
%          end
%          
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%         tempsimblocks= temp;
%         tempsimbeta= tempbetablks;
%     BETA=mean(tempsimbeta,2);
% %            BETA=tempsimbeta(:,1);
%         blocks(:,kkk)=tempsimblocks(:,1);
%          CoefMatrix =  SOMPerr(Dictionary,tempsimblocks, errorGoal,BETA );
% %          [CoefMatrix]=OMPerrNONHtest(Dictionary,tempsimblocks(:,1),BETA, errorGoal); 
% %          CoefMatrix_1=SOMPerr(Dictionary,tempsimblocks,0.65*errorGoal,BETA );
%          %%%%%%%%%%%%
%          
%      data=tempsimblocks-Dictionary* CoefMatrix;
%      
% %          data1=tempsimblocks-Dictionary* CoefMatrix;
% %          data=mean(data1,2);
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%          
% %             CoefMatrix_1 =  SOMPerr_L(Dictionary,data,32,BETA );
%             residual(:,kkk)=data(:,1);
% %  CoefMatrix_1=  SOMPerr(Dictionary,data,0.65* errorGoal,BETA );
% %          [ CoefMatrix_1]=OMPerrNONHtest(Dictionary, data1(:,1),0.65*errorGoal,BETA); 
% %           [CoefMatrix_1]=OMPerrNONHtest(Dictionary,data,BETA,0.75*errorGoal);
%                %%%%%%%%
%                
%            betamatrix(:,kkk)=BETA;
%            cof_matrix(:,kkk)= CoefMatrix(:,1);
% %              blkfirstsdenoise(:,kkk)=Dictionary* CoefMatrix_1(:,1);
% 
%              blkfirstsdenoise=input;
%              
% %                blkfirstsdenoise(:,kkk)=Dictionary* CoefMatrix_1;
% %             blkfirstsdenoise(:,kkk)=Dictionary*( CoefMatrix_1(:,1)+CoefMatrix(:,1));
%            kkk=kkk+1;
%     end
% end
% 
%     shrink=1/2;
%     dcttemp=dct2(residual);
% [num ind] = sort(dcttemp(:),1,'ascend');
%                for i2 = 1:fix(numel(dcttemp)*shrink)
%                    if dcttemp(ind(i2)) == 0
%                        continue
%                    else
%                        dcttemp(ind(i2)) = 0;
%                    end
%                end
%                residual=idct2(dcttemp);
%                
%     rPerm = randperm(size(Dictionary,2));
%     for j = rPerm
%         [betterDictionaryElement,cof_matrix] = I_findBetterDictionaryElement( blocks,Dictionary,betamatrix,j,cof_matrix, blkfirstsdenoise,residual );
%          Dictionary(:,j) = betterDictionaryElement;
%        
%     
%     end
% end

  %%%%%%%%%quzao
  output=zeros(size(BETA_sigma_pad2)); weight=zeros(size(BETA_sigma_pad2));

 for ii=1:width
%      if mod(ii,10)==0
%     disp(ii)
%      end
    for jj=1:height
        %%%%%%%%%%
         idx_matrix= simidxs{ii,jj};
         for mmmm=1:size(idx_matrix,1);
                    idx=idx_matrix(mmmm,1); idy=idx_matrix(mmmm,2);
                   tempblk=input_pad2(idx-hD0:idx+hD0,idy-hD0:idy+hD0);
                   temp(:,mmmm)=tempblk(:);
                   tempbeta=BETA_sigma_pad2(idx-hD0:idx+hD0,idy-hD0:idy+hD0);
                   tempbetablks(:,mmmm)=tempbeta(:);
                  
                  
         end
        
        %%%%%%%
        
        tempsimblocks=temp;
        tempsimbeta=tempbetablks;
        BETA=mean(tempsimbeta,2);
%         blocks=tempsimblocks;
        CoefMatrix =  SOMPerr(Dictionary,tempsimblocks, errorGoal,BETA );
%          CoefMatrix =  SOMPerr(DCT1,tempsimblocks, errorGoal,BETA );
         denoiseblk=Dictionary*CoefMatrix;
         idxmatrix= simidxs{ii,jj};
       %%%%%%%%
            for r=1:31
                f2=denoiseblk(:,r);
                 W = reshape(f2,[2*hD0+1 2*hD0+1 ]);
                 idx=idxmatrix(r,1);idy=idxmatrix(r,2);
                 output(idx-hD0:idx+hD0,idy-hD0:idy+hD0)=output(idx-hD0:idx+hD0,idy-hD0:idy+hD0)+W;
                  weight(idx-hD0:idx+hD0,idy-hD0:idy+hD0)=weight(idx-hD0:idx+hD0,idy-hD0:idy+hD0)+1;
            end
               
           
           
    end
end

output=output./weight;

output0=output(1+hW0+hD0:1+hW0+hD0+width-1,1+hW0+hD0:1+hW0+hD0+height-1);
