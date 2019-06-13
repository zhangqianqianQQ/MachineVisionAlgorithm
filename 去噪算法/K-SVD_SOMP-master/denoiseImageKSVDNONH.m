function [IOut Dictionary] = denoiseImageKSVDNONH(Image,denoise_first,matrix_sigma,bb,K,C,L)
%==========================================================================
[NN1,NN2] = size(Image);hD0=floor(bb/2);D0=2*hD0;hW0=10;T0=60;width=NN1;height=NN2;D1=2*hD0+1;
% h0 = quantile_nakagami(L, D1, 0.88) .* D1.^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%hW0和hD0分别是搜索窗和块径。D0=2*hD0

    ima_nse2 = padarray(Image,[hD0 hD0],'symmetric'); 
    ima_nse3 = padarray(Image,[hW0+hD0 hW0+hD0],'symmetric'); 
    ima_nse4 = padarray(denoise_first,[hD0 hD0],'symmetric'); 
    ima_nse5 = padarray(denoise_first,[hW0+hD0 hW0+hD0],'symmetric');
  i=0;
  for m = -hW0:hW0
           i=i+1;
           j=0;
            for n = -hW0:hW0
                j=j+1;
                if(m==0 && n==0) 
                    w{i,j} = zeros(NN1,NN2);
                    continue; 
                end;    %保证搜索窗比较窗不重叠
%                 R1 = min(ima_nse2./ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0),ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0)./ima_nse2);
%                 R1 = ima_nse2.*ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0);
%                 R12 = ima_nse2.^2+ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0).^2;
%                 Sd1 = (2*L-1)*log(R1)-(2*L-1/2)*log(R12);  
                 R1 = ima_nse4-ima_nse5(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0);
                Sd1 =R1.*R1;
                Sd1 = cumsum(Sd1,1);
                Sd1 = cumsum(Sd1,2);   
                [Sd1width,Sd1height] = size(Sd1);
                Sd1_temp  = zeros(Sd1width+1,Sd1height+1);
                Sd1_temp(2:Sd1width+1,2:Sd1height+1)=Sd1;
                temp1 = Sd1_temp(D0+2:D0+width+1,D0+2:D0+height+1)+ Sd1_temp(1:width,1:height)-Sd1_temp(D0+2:D0+width+1,1:height)-Sd1_temp(1:width,D0+2:D0+height+1);
               
%                     w{i,j} =1e28*exp(-temp1./h0);
                 w{i,j}=temp1;
            end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%
    blkMatrix=zeros(bb*bb,NN1*NN2);arrow_idx=1;
    for col=1:NN2
        for arrow=1:NN1
             blkMatrix(:,arrow_idx)=reshape(ima_nse2(arrow:arrow+bb-1,col:col+bb-1),[bb*bb 1]);
             arrow_idx=arrow_idx+1;
        end
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  sigma=min(matrix_sigma(:));
  errorGoal = sigma*C;
  BETA_sig=sigma*(ones(size(matrix_sigma))./matrix_sigma);
  BETA_sig1 = padarray(BETA_sig,[hD0 hD0],'symmetric'); 
  BETA_sig2 = padarray( BETA_sig,[hW0+hD0 hW0+hD0],'symmetric'); 
  BETA=im2col(BETA_sig,[bb,bb],'sliding');
  idx=1;
 for col=1:NN2
        for arrow=1:NN1
             BETA(:,idx)=reshape(BETA_sig1(arrow:arrow+bb-1,col:col+bb-1),[bb*bb 1]);
             idx=idx+1;
        end
 end

%3 得到初始的DCT冗余字典
  %3.1 得到初始DCT
    Pn=ceil(sqrt(K));
    DCT=zeros(bb,Pn);
    for k=0:1:Pn-1,
        V=cos([0:1:bb-1]'*k*pi/Pn);
        if k>0, V=V-mean(V); 
        end;
        DCT(:,k+1)=V/norm(V);
    end;
    DCT=kron(DCT,DCT);
%3.2 对DCT进行均值处理
     reduceDC =0;
    if (reduceDC)
        vecOfMeans = mean(blkMatrix);
        blkMatrix = blkMatrix-ones(size(blkMatrix,1),1)*vecOfMeans;
    end


% 4 对字典DCT进行训练
[Dictionary]=KSVDNONH(blkMatrix,DCT,BETA,errorGoal, ima_nse3,BETA_sig2,w,NN1,NN2,hW0,hD0,T0);
DCT=Dictionary;
disp('finished Trainning dictionary');
  Dictionary=DCT;

%5 用训练好的字典DCT进行去噪
% slidingDis = 1;
errT = sigma*C;



% [blocks,idx] = my_im2col(Image,[bb,bb],slidingDis);%%%%%%%%%%%%%%对像素点取块进行列化
% [blocksbeta,idxbeta] = my_im2col(BETA_sig,[bb,bb],slidingDis);%%%%%%对像素点的方差取块进行列化
 if (reduceDC)
        vecOfMeans = mean(blkMatrix);
      blkMatrix = blkMatrix- repmat(vecOfMeans,size(blkMatrix,1),1);
 end
  Coefs = OMPerrNONHtest(DCT,blkMatrix,BETA,errT);%%%%%%%%%求对应的系数
  if (reduceDC)
         blkMatrix= DCT*Coefs + ones(size(blkMatrix,1),1) * vecOfMeans;
    else
       blkMatrix= DCT*Coefs ;%%%%%%%%%%%%%得到去噪后的块
  end

idx=[1:NN1*NN2];

count = 1;
Weight = zeros(NN1+2*floor(bb/2),NN2+2*floor(bb/2));
IMout = zeros(NN1+2*floor(bb/2),NN2+2*floor(bb/2));
[rows,cols] = ind2sub([NN1,NN2],idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%对每个像素进行平均
for i  = 1:length(cols)
    col = cols(i); row = rows(i);        
   blkMatrix00=reshape(blkMatrix(:,count),[bb,bb]);
    IMout(row:row+bb-1,col:col+bb-1)=IMout(row:row+bb-1,col:col+bb-1)+blkMatrix00;
    Weight(row:row+bb-1,col:col+bb-1)=Weight(row:row+bb-1,col:col+bb-1)+ones(bb);  
    count = count+1;
end;

 IOut0 = IMout./Weight;%%%%%%%%%去噪后的图
 IOut=IOut0(floor(bb/2)+1:end-floor(bb/2),floor(bb/2)+1:end-floor(bb/2));




