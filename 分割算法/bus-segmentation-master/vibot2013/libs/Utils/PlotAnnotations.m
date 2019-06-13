function PlotAnnotations(GT_IMG,ALG_IMG,FileName)
nRows=size(GT_IMG,1);
nCols=size(GT_IMG,2);
O=zeros(nRows,nCols,3);
for n=1:nRows
    for k=1:nCols
        if(GT_IMG(n,k)~=0&&ALG_IMG(n,k)~=0)
            O(n,k,:)=[255 255 255];
        elseif(GT_IMG(n,k)==0&&ALG_IMG(n,k)==0)
            O(n,k,:)=[0 0 0];
        elseif(GT_IMG(n,k)~=0&&ALG_IMG(n,k)==0)
            O(n,k,:)=[255 0 0];
        else
            O(n,k,:)=[0 255 0];
        end
    end
end
[~,name,~] = fileparts(FileName);
imwrite(O,['./Results/OutAnnotation/' name '_Diff.jpg'],'jpg');