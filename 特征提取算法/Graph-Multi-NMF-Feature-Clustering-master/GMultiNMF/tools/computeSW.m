function SsW=computeSW(distance,nearnumber,yTr)
    [~,indx]=sort(distance,2);
    sampleNum=size(distance,1);
    NN=zeros(size(sampleNum));
    SW=zeros(1,sampleNum);
    for i=1:sampleNum
        NN(i,indx(i,1:nearnumber+1))=1;
        inum=sum(sum(yTr(:,indx(i,1:nearnumber+1))));
        SW(i)=1/max(inum,1);
    end
    SW=SW./mean(SW);
    SsW=sparse(diag(SW));
end