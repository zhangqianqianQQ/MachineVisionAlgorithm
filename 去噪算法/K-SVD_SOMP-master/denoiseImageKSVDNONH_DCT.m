function [IOut ] = denoiseImageKSVDNONH_DCT(Image,matrix_sigma,bb,K,C)
%==========================================================================
[NN1,NN2] = size(Image);

%1 得到beta矩阵，每一列为一个像素点path的beta
  %1.1找出最小的标准差sigma
  sigma=min(matrix_sigma(:));
 
  %1.2 用sigma对每个像素点的方差进行归一化
  BETA_sig=sigma*(ones(size(matrix_sigma))./matrix_sigma);
  
  %1.3 对像素点的方差取块进行列化
%   BETA=im2col(BETA_sig,[bb,bb],'sliding');
% 
% %2 对像素点取块进行列化，得到数据矩阵blkmatrix,每一列为一个像素点的path
%   blkMatrix = im2col(Image,[bb,bb],'sliding');
% 
% [ BETA] = my_im2col(BETA_sig,[bb,bb],slidingDis);
% [blkMatrix]= my_im2col(Image,[bb,bb],slidingDis);


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
%      reduceDC = 0;
%     if (reduceDC)
%         vecOfMeans = mean(blkMatrix);
%         blkMatrix = blkMatrix-ones(size(blkMatrix,1),1)*vecOfMeans;
%     end


% 4 对字典DCT进行训练
% [Dictionary]=KSVDNONH(blkMatrix,DCT,BETA,errorGoal);
% DCT=Dictionary;
% disp('finished Trainning dictionary');
  

%5 用训练好的字典DCT进行去噪
slidingDis = 1;
errT = sigma*C;
reduceDC=1;
[blocks,idx] = my_im2col(Image,[bb,bb],slidingDis);%%%%%%%%%%%%%%对像素点取块进行列化
[blocksbeta,idxbeta] = my_im2col(BETA_sig,[bb,bb],slidingDis);%%%%%%对像素点的方差取块进行列化
 if (reduceDC)
        vecOfMeans = mean(blocks);
       blocks = blocks- repmat(vecOfMeans,size(blocks,1),1);
 end
  Coefs = OMPerrNONHtest(DCT,blocks,blocksbeta,errT);%%%%%%%%%求对应的系数
  if (reduceDC)
         blocks= DCT*Coefs + ones(size(blocks,1),1) * vecOfMeans;
    else
        blocks= DCT*Coefs ;%%%%%%%%%%%%%得到去噪后的块
  end



count = 1;
Weight = zeros(NN1,NN2);
IMout = zeros(NN1,NN2);
[rows,cols] = ind2sub(size(Image)-bb+1,idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%对每个像素进行平均
for i  = 1:length(cols)
    col = cols(i); row = rows(i);        
    block =reshape(blocks(:,count),[bb,bb]);
    IMout(row:row+bb-1,col:col+bb-1)=IMout(row:row+bb-1,col:col+bb-1)+block;
    Weight(row:row+bb-1,col:col+bb-1)=Weight(row:row+bb-1,col:col+bb-1)+ones(bb);  
    count = count+1;
end;

 IOut = IMout./Weight;%%%%%%%%%去噪后的图




