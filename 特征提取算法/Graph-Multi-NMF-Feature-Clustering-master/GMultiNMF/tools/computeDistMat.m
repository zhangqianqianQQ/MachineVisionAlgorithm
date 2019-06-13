function dist = computeDistMat(matFtrs,distType)
%matFtrs为图像特征，一列一个图像

numOfSamples = size(matFtrs,2);

dist = zeros(numOfSamples);
for i=1:numOfSamples
    vecFtrPart=matFtrs(:,i);
    if( distType==1 ) % chi-square distance
        nr = (bsxfun(@minus,matFtrs,vecFtrPart)).^2;
        dr = bsxfun(@plus,matFtrs,vecFtrPart);
        dr=max(dr,eps);
        distTemp = sum(nr./dr);
    elseif( distType==2 ) % l2 distance
        nr = (bsxfun(@minus,matFtrs,vecFtrPart)).^2;
        distTemp = sqrt(sum(nr));
    elseif( distType==3 ) % l1 distance
        nr = abs(bsxfun(@minus,matFtrs,vecFtrPart));
        distTemp = sum(nr);
    end
    dist(i,:)=distTemp;
end
