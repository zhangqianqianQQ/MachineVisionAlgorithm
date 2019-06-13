function th_img = map5(inp,s,n)
[row col]=size(inp);
th_img=zeros(row,col);
th_img(1:(row/2^n),1:(col/2^n))=inp(1:(row/2^n),1:(col/2^n));
for i=n:-1:1
    a=inp((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1))); %diagonal coefficients
    th_img((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1)))=th(a,s);
    a=inp(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)));   %horizontal coefficients
    th_img(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)))=th(a,s);
    a=inp((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)));     %vertical coefficients
    th_img((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)))=th(a,s);
end
end
function y=th(inp,s)
[row col]=size(inp);
test1=zeros(row+8,col+8);
test2=zeros(size(test1));
test1(5:end-4,5:end-4)=inp;
[row col]=size(test1);
for i=5:row-4
    for j=5:col-4
        b=test1(i-4:i+4,j-4:j+4);
        sigsq=max(0,((1/numel(b))*sum(sum(b.^2))-s));
        test2(i,j)=(sqrt(2)*s)./sqrt(sigsq);
    end
end
c=(abs(inp)-test2(5:row-4,5:col-4));
c(c<0)=0;
y=sign(inp).*c;
% [row col]=size(inp);
% y(1:row/2^n,1:col/2^n)=inp(1:row/2^n,1:col/2^n);
end
