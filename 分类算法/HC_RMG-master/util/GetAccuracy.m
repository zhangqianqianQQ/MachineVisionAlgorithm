function [Pr,ConfMat]=GetAccuracy(gtLabel,testLabel)
NumClass=max(gtLabel(:));
ConfMat=zeros(NumClass,NumClass);
for ii=1:NumClass
    for jj=1:NumClass
        ConfMat(ii,jj)=length(find((testLabel==ii)&(gtLabel==jj)));
    end
end
Pr.OA=sum(diag(ConfMat))/sum(ConfMat(:));
Pr.UA=diag(ConfMat)./sum(ConfMat,2);
Pr.PA=diag(ConfMat)./sum(ConfMat,1)';
temp1=sum(ConfMat(:))*sum(diag(ConfMat))-sum(sum(ConfMat,2).*sum(ConfMat,1)');
temp2=sum(ConfMat(:))^2-sum(sum(ConfMat,2).*sum(ConfMat,1)');
Pr.Kappa=temp1/temp2;



