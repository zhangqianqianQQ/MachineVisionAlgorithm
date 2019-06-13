function [ expanded ] = expansion(image)
h=size(image,1);
w=size(image,2);
expanded=zeros(2*h,2*w);

for i=1:h
    for j=1:w
        expanded(2*i-1,2*j-1)=image(i,j);
        expanded(2*i-1,2*j)=image(i,j);
        expanded(2*i,2*j-1)=image(i,j);
        expanded(2*i,2*j)=image(i,j);        
    end
end

end