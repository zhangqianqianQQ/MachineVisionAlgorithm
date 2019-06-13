%MSE Im_original为原始未经污染的图，Im_modified为去噪后的图
function Image_MSE=MSE(Im_original,Im_modified)

if (size(Im_original)~=size(Im_modified))
    error ('error:image sizes do not agree')
end

[m,n]=size(Im_modified);
A=double(Im_original);
B=double(Im_modified);
sumaDif=0;
for u=1:m
    for v=1:n
        sumaDif=sumaDif+(A(u,v)-B(u,v))^2;
    end
end
Image_MSE=sumaDif/(m*n);
