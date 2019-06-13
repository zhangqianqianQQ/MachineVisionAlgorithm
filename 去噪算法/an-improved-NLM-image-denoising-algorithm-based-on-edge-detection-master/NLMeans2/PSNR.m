%PSNR
function S=PSNR(Im_original,Im_modified)

if (size(Im_original)~=size(Im_modified))
    error ('error:image sizes do not agree')
end


[m,n]=size(Im_original);
A=double(Im_original);
B=double(Im_modified);
sumaDif=0;
maxI=m*n*max(max(A.^2));
for u=1:m
    for v=1:n
        sumaDif=sumaDif+(A(u,v)-B(u,v))^2;
    end
end
if (sumaDif==0)
    sumaDif=1;
end
S=maxI/sumaDif;
S=10*log10(S);
