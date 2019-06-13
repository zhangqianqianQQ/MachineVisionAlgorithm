function [ reduced ] = reduction(image, th)
h=size(image,1);
w=size(image,2);
reduced=zeros(h/2,w/2);

for i=1:h/2
    for j=1:w/2
        sum=image(2*i-1,2*j-1)+image(2*i-1,2*j)+image(2*i,2*j-1)+image(2*i,2*j);
        if sum>=th
            reduced(i,j)=1;
        else
            reduced(i,j)=0;
        end
    end
end

end