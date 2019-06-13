function th_img = mmse7(inp,inp_map,s,n)
[row col]=size(inp);
th_img=zeros(row,col);
th_img(1:(row/2^n),1:(col/2^n))=inp(1:(row/2^n),1:(col/2^n));
for i=n:-1:1
    a=inp((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1))); %diagonal coefficients
    b=inp_map((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1)));
    th_img((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1)))=th(a,b,s);
    a=inp(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)));   %horizontal coefficients
    b=inp(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)));
    th_img(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)))=th(a,b,s);
    a=inp((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)));     %vertical coefficients
    b=inp((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)));
    th_img((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)))=th(a,b,s);
end
end
function y=th(inp,inp1,s)
[row col]=size(inp);
lambda=1/var(inp1(:));
test1=zeros(row+6,col+6);
test2=zeros(size(test1));
test1(4:end-3,4:end-3)=inp;
[row col]=size(test1);
for i=4:row-3
    for j=4:col-3
        b=test1(i-3:i+3,j-3:j+3);
%         sigsq=max(0,((1/numel(b))*sum(sum(b.^2))-s));
%         lambda=1/sqrt(sigsq);
        A=numel(b)*(-1+sqrt(1+(8*lambda/numel(b)^2)*sum(sum(b.^2))));
        sig_cap_sq=max(0,(A/(4*lambda)-s));
        %test2(i,j)=(sqrt(2)*s)./sqrt(sigsq);
        test2(i,j)=(sig_cap_sq.*test1(i,j))./(sig_cap_sq+s);
    end
end
y=test2(4:row-3,4:col-3);
% % c=(abs(inp)-test2(4:row-3,4:col-3));
% % c(c<0)=0;
% % y=sign(inp).*c;
% [row col]=size(inp);
% y(1:row/2^n,1:col/2^n)=inp(1:row/2^n,1:col/2^n);
end
