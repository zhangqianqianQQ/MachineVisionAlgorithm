%SNR
function Sn=SNR(Im_original,Im_modified)

if (size(Im_original)~=size(Im_modified))
    error ('error:image sizes do not agree')
end

else
    A=double(Im_original);
    B=double(Im_modified);
end

[m,n]=size(A);
sumaI=0;
sumaDif=0;
for u=1:m
    for v=1:n
        sumaI=sumaI+A(u,v)^2;
        sumaDif=sumaDif+(A(u,v)-B(u,v))^2;
    end
end

if (sumaDif==0)
    sumaDif=1;
end

Sn=sumaI/sumaDif;
Sn=10*log10(Sn);