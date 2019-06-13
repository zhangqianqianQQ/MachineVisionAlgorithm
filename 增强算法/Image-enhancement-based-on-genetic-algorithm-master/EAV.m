
function L=EAV(f)
f=double(f);
[m,n]=size(f);
f=[zeros(m,1) f zeros(m,1)];
f=[zeros(1,n+2);f;zeros(1,n+2)];

for i=2:m  %i代表行
    for j=2:n   %j代表列
        H=(4+2*sqrt(2))*f(i,j)-f(i,j-1)-f(i,j+1)-f(i-1,j)-f(i+1,j)-sqrt(2)/2*f(i+1,j+1)-sqrt(2)/2*f(i+1,j-1)-sqrt(2)/2*f(i-1,j+1)-sqrt(2)/2*f(i-1,j-1);
        g(i,j)=abs(H);
    end 
end
 L=sum(sum(g));%得出评价函数L的值
