function [ m ] = NonZeroMean( arr )
h=size(arr,1);
w=size(arr,2);
c=0;
m=0;
for i=1:h
    for j=1:w
        if arr(i,j)~=0
            c=c+1;
            m=m+arr(i,j);        
        end
    end
end
if m~=0
    m=m/c*1.0;
end
end