function th_img = bayesian_th(inp,s,n)
[row col]=size(inp);
th_img=zeros(row,col);
th_img(1:(row/2^n),1:(col/2^n))=inp(1:(row/2^n),1:(col/2^n));
for i=n:-1:1
    a=inp((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1))); %diagonal coefficients
    th_img((row/2^i)+1:(row/2^(i-1)),(col/2^i)+1:(col/2^(i-1)))=th(a,s,n);
    a=inp(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)));   %horizontal coefficients
    th_img(1:(row/2^(i)),(col/2^i)+1:(col/2^(i-1)))=th(a,s,n);
    a=inp((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)));     %vertical coefficients
    th_img((row/2^i)+1:(row/2^(i-1)),1:(col/2^(i)))=th(a,s,n);
end
end
function th_subband=th(inp_mtx,s,n)
N=numel(inp_mtx);
c=inp_mtx.^2;
sigmasq_y=(1/N)*sum(c(:));
sigma_x=sqrt(max((sigmasq_y-s),0));
% Tb1=sqrt(log10(N/n))*(s/(sigma_x));
Tb1=(s/(sigma_x));
% th_subband=sign(inp_mtx).*max(0,abs(inp_mtx)-Tb1);
th_subband=inp_mtx.*(abs(inp_mtx)>Tb1);
end