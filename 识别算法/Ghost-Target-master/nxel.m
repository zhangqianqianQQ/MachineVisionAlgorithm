function [ new_images ] = nxel( n, old_image )
%Nxel - takes image and pixelizes into n * n array
    [a,b,~] = size(old_image);
    new_images = cell(n,n);
    for i = 1:n
        for j = 1:n
            new_images{i,j} = old_image((1+(i-1)*floor(a/n)):(floor(i*a/n)-1),...
                                        (1+(j-1)*floor(b/n)):(floor(j*b/n)-1),...
                                   :);
        end
    end
end



