function x=inverse_multistep(N,b,ld)
x=b;
[m n]=size(b);
for k=1:N
    R=getcorner(x,m/2^(N-k),n/2^(N-k));
    I=wave_inv_transform(R,ld);
%     isnan(I)
    x=putcorner(x,I);
end
end
function r=getcorner(C,m,n)
    r=C(1:m,1:n);
end
function x=putcorner(c,a)
    [m n]=size(a);
    c(1:m,1:n)=a;
    x=c;
end