function [betterDictionaryElement,CoefMatrix] = I_findBetterDictionaryElement(Data,Dictionary,BETA,j,CoefMatrix,DA2,Residual)

%找出用了字典中的该列表达的那几列数据
relevantDataIndices = find(CoefMatrix(j,:));
if (length(relevantDataIndices)<1)
    ERR=BETA.*(Data-Dictionary*CoefMatrix);
    sumerr=sum(ERR.^2);
    [indx]=find(sumerr==max(sumerr));
    pos=indx(1);
    betterDictionaryElement=(Data(:,pos)./BETA(:,pos))/norm((Data(:,pos)./BETA(:,pos)));
    
%      betterDictionaryElement=(Dictionary(:,j));

     CoefMatrix(j,:) = 0;

    return;
end


%得到这几列数据对应于相应字典中该列的系数
% tmpCoefMatrix = CoefMatrix(:,relevantDataIndices); 
% 
% %求出当去掉这几列数据的表达中的该列的成分后，这几列数据与它们的表达之间的误差
% tmpCoefMatrix(j,:) = 0;
% Error =(Data(:,relevantDataIndices) - Dictionary*tmpCoefMatrix); 
% Error=imfilter(Error,ones(1,18)/9,'symmetric');
% denoise_blk= blkfirstsdenoise(:,relevantDataIndices)-Dictionary*tmpCoefMatrix;
Error= Residual(:,relevantDataIndices)+Dictionary(:,j)* CoefMatrix(j,relevantDataIndices); 
%求新的该列，使误差在减去该列的表达后最小。并求出对应的系数。
% tmpBETA=BETA(:,relevantDataIndices);
% Error= DA2(:,relevantDataIndices)+Dictionary(:,j)* CoefMatrix(j,relevantDataIndices);
[u,s,v]=svds(Error,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%聚类
% [IDX C]=kmeans(denoise_blk',3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idx1= IDX==1;
% idx2= IDX==2;
% idx3= IDX==3;
% de1=denoise_blk(:,idx1);
% de2=denoise_blk(:,idx2);
% de3=denoise_blk(:,idx3);
% [u1,s1,v1]=svds(de1,1);
% [u2,s2,v2]=svds(de2,1);
% [u3,s3,v3]=svds(de3,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
betterDictionaryElement=u;
          betaVector=s*v;
% a=CoefMatrix(j,relevantDataIndices) ;
% [betterDictionaryElement,betaVector]=weirank(tmpBETA,errors,errorGoal,DCT);

%更新系数矩阵
CoefMatrix(j,relevantDataIndices) =betaVector';% *signOfFirstElem
% disp(j)
end    
